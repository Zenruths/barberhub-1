import bcrypt from 'bcryptjs'
import { promisify } from 'node:util'

import db from '../db.js'

const dbp = typeof db.promise === 'function' ? db.promise() : db

let checkedSchema = false
let hasUsuarioIdColumn = false

async function ensureProfissionaisSchema() {
  if (checkedSchema) {
    if (!hasUsuarioIdColumn) {
      const err = new Error(
        'Banco desatualizado: falta a coluna profissionais.usuario_id. Execute: ALTER TABLE profissionais ADD COLUMN usuario_id INT NULL; ALTER TABLE profissionais ADD UNIQUE KEY usuario_id (usuario_id); ALTER TABLE profissionais ADD CONSTRAINT fk_prof_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id);'
      )
      err.status = 500
      throw err
    }
    return
  }

  try {
    const [rows] = await dbp.query(
      `SELECT 1 AS ok
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE()
         AND TABLE_NAME = 'profissionais'
         AND COLUMN_NAME = 'usuario_id'
       LIMIT 1`
    )

    hasUsuarioIdColumn = Boolean(rows?.length)
    checkedSchema = true
  } catch {
    // Se não conseguimos consultar information_schema, não travamos aqui.
    checkedSchema = true
    hasUsuarioIdColumn = true
  }

  if (!hasUsuarioIdColumn) {
    const err = new Error(
      'Banco desatualizado: falta a coluna profissionais.usuario_id. Execute: ALTER TABLE profissionais ADD COLUMN usuario_id INT NULL; ALTER TABLE profissionais ADD UNIQUE KEY usuario_id (usuario_id); ALTER TABLE profissionais ADD CONSTRAINT fk_prof_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id);'
    )
    err.status = 500
    throw err
  }
}

const bcryptHash = promisify(bcrypt.hash)

export async function getProfissionalByUserId(userId) {
  if (!userId) return null

  await ensureProfissionaisSchema()

  const [rows] = await dbp.query(
      `SELECT p.id, p.nome, p.apelido, p.ativo, p.usuario_id
       FROM profissionais p
       WHERE p.usuario_id = ?
       LIMIT 1`,
      [userId]
    )

  return rows[0] || null
}

export async function getGoogleConnectionByUserId(userId) {
  if (!userId) return { connected: false }

  const [rows] = await dbp.query(
      `SELECT google_email, calendar_id, connected_at, updated_at
       FROM user_google_calendar_tokens
       WHERE user_id = ?
       LIMIT 1`,
      [userId]
    )

  if (!rows.length) return { connected: false }

  const row = rows[0]
  return {
    connected: true,
    googleEmail: row.google_email,
    calendarId: row.calendar_id,
    connectedAt: row.connected_at,
    updatedAt: row.updated_at,
  }
}

export async function listProfissionais() {
  await ensureProfissionaisSchema()

  const [rows] = await dbp.query(
      `SELECT
         p.id,
         p.nome,
         p.apelido,
         p.ativo,
         p.usuario_id,
         u.username,
         u.email,
         CASE WHEN ugc.user_id IS NULL THEN 0 ELSE 1 END AS google_connected,
         ugc.google_email AS google_email,
         ugc.calendar_id AS google_calendar_id
       FROM profissionais p
       LEFT JOIN usuarios u ON u.id = p.usuario_id
       LEFT JOIN user_google_calendar_tokens ugc ON ugc.user_id = p.usuario_id
       ORDER BY p.nome ASC`
    )

  return rows
}

export async function createProfissionalWithUser({ nome, apelido, username, email, password }) {
  await ensureProfissionaisSchema()

  if (!nome) {
    const error = new Error('Nome é obrigatório')
    error.status = 400
    throw error
  }

  if (!email || !password) {
    const error = new Error('Email e senha são obrigatórios')
    error.status = 400
    throw error
  }

  const resolvedUsername = (username || apelido || nome || '').toString().trim()
  if (!resolvedUsername) {
    const error = new Error('Username é obrigatório')
    error.status = 400
    throw error
  }

  const passwordHash = await bcryptHash(password, 10)

  const conn = await dbp.getConnection()
  try {
    await conn.beginTransaction()

    const [userInsert] = await conn.query(
      `INSERT INTO usuarios (username, email, password_hash, created_at)
       VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
      [resolvedUsername, email, passwordHash]
    )

    const userId = userInsert.insertId

    const [profInsert] = await conn.query(
      `INSERT INTO profissionais (usuario_id, nome, apelido, ativo)
       VALUES (?, ?, ?, 1)`,
      [userId, nome, apelido || null]
    )

    await conn.commit()

    return {
      userId,
      profissionalId: profInsert.insertId,
    }
  } catch (err) {
    try {
      await conn.rollback()
    } catch {
      // ignore
    }

    // Erros comuns: email/username duplicados
    if (err && (err.code === 'ER_DUP_ENTRY' || err.errno === 1062)) {
      const error = new Error('Email ou username já cadastrado')
      error.status = 409
      throw error
    }

    throw err
  } finally {
    conn.release()
  }
}

export async function ensureProfissionalForUser({ userId, nome, apelido }) {
  if (!userId) {
    const error = new Error('userId é obrigatório')
    error.status = 400
    throw error
  }

  await ensureProfissionaisSchema()

  const existing = await getProfissionalByUserId(userId)
  if (existing?.id) return existing

  const resolvedNome = (nome || '').toString().trim() || null
  const resolvedApelido = (apelido || '').toString().trim() || null

  const conn = await dbp.getConnection()
  try {
    // Evita duplicar se houver corrida em chamadas simultâneas
    const [rows] = await conn.query(
      `SELECT p.id, p.nome, p.apelido, p.ativo, p.usuario_id
       FROM profissionais p
       WHERE p.usuario_id = ?
       LIMIT 1`,
      [userId]
    )

    if (rows?.length) return rows[0]

    const [ins] = await conn.query(
      `INSERT INTO profissionais (usuario_id, nome, apelido, ativo)
       VALUES (?, ?, ?, 1)`,
      [userId, resolvedNome || 'Profissional', resolvedApelido]
    )

    return {
      id: ins.insertId,
      nome: resolvedNome || 'Profissional',
      apelido: resolvedApelido,
      ativo: 1,
      usuario_id: userId,
    }
  } catch (err) {
    // Se estourou UNIQUE(usuario_id) por corrida, apenas re-consulta
    if (err && (err.code === 'ER_DUP_ENTRY' || err.errno === 1062)) {
      const again = await getProfissionalByUserId(userId)
      if (again?.id) return again
    }
    throw err
  } finally {
    conn.release()
  }
}

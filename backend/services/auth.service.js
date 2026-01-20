import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import crypto from 'crypto'
import db from '../db.js'
import {
  JWT_SECRET,
  ACCESS_TOKEN_EXPIRES_IN,
  REFRESH_TOKEN_IDLE_MINUTES,
  REFRESH_TOKEN_IDLE_MINUTES_PERSISTENT,
} from '../config/env.js'

export async function login({ email, password, keepLoggedIn, ip, userAgent }) {
  if (!email || !password) {
    const error = new Error('Email e senha são obrigatórios')
    error.status = 400
    throw error
  }

  const sql = 'SELECT * FROM usuarios WHERE email = ? LIMIT 1'

  const [results] = await db.query(sql, [email])

  if (!results.length) {
    // registra tentativa de login falha (sem user_id)
    const logSql =
      'INSERT INTO user_login_logs (user_id, username, email, ip_address, device_info, success, user_agent) VALUES (NULL, NULL, ?, ?, ?, FALSE, ?)'
    const deviceInfo = userAgent

    await db.query(logSql, [email, ip, deviceInfo, userAgent])

    const error = new Error('Usuário ou senha inválidos')
    error.status = 401
    throw error
  }

  const user = results[0]

  const match = await bcrypt.compare(password, user.password_hash)
  if (!match) {
    // registra tentativa de login falha com user_id conhecido
    const logSql =
      'INSERT INTO user_login_logs (user_id, username, email, ip_address, device_info, success, user_agent) VALUES (?, ?, ?, ?, ?, FALSE, ?)'
    const deviceInfo = userAgent

    await db.query(logSql, [user.id, user.username, user.email, ip, deviceInfo, userAgent])

    const error = new Error('Usuário ou senha inválidos')
    error.status = 401
    throw error
  }

  // Gerar access token curto
  const accessToken = jwt.sign(
    { id: user.id, username: user.username, email: user.email },
    JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
  )

  // Gerar refresh token aleatório e salvar hash no banco
  const refreshToken = crypto.randomBytes(40).toString('hex')
  const refreshTokenHash = await bcrypt.hash(refreshToken, 10)

  // Define o tempo de idle do refresh token conforme a opção 'Mantenha-me conectado'
  const idleMinutes = keepLoggedIn
    ? REFRESH_TOKEN_IDLE_MINUTES_PERSISTENT
    : REFRESH_TOKEN_IDLE_MINUTES

  try {
    await db.query(
      `INSERT INTO user_refresh_tokens (user_id, token_hash, created_at, last_used_at, expires_at)
         VALUES (?, ?, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL ? MINUTE))`,
      [user.id, refreshTokenHash, idleMinutes]
    )

    // Opcional: invalidar outros refresh tokens ativos do mesmo usuário (sessão única)
    await db.query(
      `UPDATE user_refresh_tokens
         SET revoked = TRUE
         WHERE user_id = ? AND revoked = FALSE AND token_hash <> ?`,
      [user.id, refreshTokenHash]
    )
  } catch (tokenErr) {
    console.error('Erro ao registrar refresh token:', tokenErr)
    const error = new Error('Erro ao criar sessão de usuário')
    error.status = 500
    throw error
  }

  // registra login bem-sucedido
  const logSql =
    'INSERT INTO user_login_logs (user_id, username, email, ip_address, device_info, success, user_agent) VALUES (?, ?, ?, ?, ?, TRUE, ?)'
  const deviceInfo = userAgent

  try {
    await db.query(logSql, [user.id, user.username, user.email, ip, deviceInfo, userAgent])
  } catch (logErr) {
    console.error('Erro ao registrar log de login:', logErr)
    // não bloqueamos o login por causa de erro no log
  }

  return {
    accessToken,
    refreshToken,
    email: user.email,
    username: user.username,
  }
}

export async function refresh({ refreshToken }) {
  if (!refreshToken) {
    const error = new Error('Refresh token é obrigatório.')
    error.status = 400
    throw error
  }

  // Buscar todos os tokens não revogados
  const [rows] = await db.query('SELECT * FROM user_refresh_tokens WHERE revoked = FALSE')

  let tokenRow = null
  for (const row of rows) {
    const match = await bcrypt.compare(refreshToken, row.token_hash)
    if (match) {
      tokenRow = row
      break
    }
  }

  if (!tokenRow) {
    const error = new Error('Sessão expirada, faça login novamente.')
    error.status = 401
    throw error
  }

  // Verificar expiração por inatividade
  const [nowRows] = await db.query('SELECT NOW() AS now')
  const now = nowRows[0].now

  if (now > tokenRow.expires_at) {
    await db.query('UPDATE user_refresh_tokens SET revoked = TRUE WHERE id = ?', [tokenRow.id])
    const error = new Error('Sessão expirada, faça login novamente.')
    error.status = 401
    throw error
  }

  // Atualizar last_used_at e renovar expires_at (idle timeout)
  await db.query(
    `UPDATE user_refresh_tokens
       SET last_used_at = NOW(), expires_at = DATE_ADD(NOW(), INTERVAL ? MINUTE)
       WHERE id = ?`,
    [REFRESH_TOKEN_IDLE_MINUTES, tokenRow.id]
  )

  const userId = tokenRow.user_id

  const [userRows] = await db.query('SELECT id, username, email FROM usuarios WHERE id = ? LIMIT 1', [userId])

  if (!userRows.length) {
    const error = new Error('Usuário não encontrado.')
    error.status = 401
    throw error
  }

  const user = userRows[0]

  const accessToken = jwt.sign(
    { id: user.id, username: user.username, email: user.email },
    JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
  )

  return { accessToken }
}

export async function logout({ accessToken, refreshToken }) {
  try {
    if (accessToken) {
      let decoded
      try {
        decoded = jwt.verify(accessToken, JWT_SECRET)
      } catch (err) {
        decoded = null
      }

      if (decoded?.id) {
        const userId = decoded.id

        await db.query(
          `UPDATE user_login_logs
             SET logout_time = CURRENT_TIMESTAMP
             WHERE user_id = ?
               AND success = TRUE
               AND logout_time IS NULL
             ORDER BY login_time DESC
             LIMIT 1`,
          [userId]
        )
      }
    }

    // Revogar refresh token, se enviado
    if (refreshToken) {
      const [rows] = await db.query('SELECT * FROM user_refresh_tokens WHERE revoked = FALSE')

      for (const row of rows) {
        const match = await bcrypt.compare(refreshToken, row.token_hash)
        if (match) {
          await db.query('UPDATE user_refresh_tokens SET revoked = TRUE WHERE id = ?', [row.id])
          break
        }
      }
    }
  } catch (err) {
    console.error('Erro no logout (service):', err)
    // Não propagamos erro, apenas registramos e seguimos retornando success
  }

  return { success: true }
}

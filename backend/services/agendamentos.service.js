import db from '../db.js'

import { getProfissionalByUserId } from './profissionais.service.js'
import { getAuthenticatedGoogleClientForUser } from './googleCalendarClient.js'

const dbp = typeof db.promise === 'function' ? db.promise() : db

let checkedAgSchema = false
let hasGoogleEventId = false

async function ensureAgendamentosSchema() {
  if (checkedAgSchema) {
    if (!hasGoogleEventId) {
      const err = new Error(
        'Banco desatualizado: falta a coluna agendamentos.google_event_id. Execute: ALTER TABLE agendamentos ADD COLUMN google_event_id VARCHAR(255) NULL;'
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
         AND TABLE_NAME = 'agendamentos'
         AND COLUMN_NAME = 'google_event_id'
       LIMIT 1`
    )
    hasGoogleEventId = Boolean(rows?.length)
    checkedAgSchema = true
  } catch {
    checkedAgSchema = true
    hasGoogleEventId = true
  }

  if (!hasGoogleEventId) {
    const err = new Error(
      'Banco desatualizado: falta a coluna agendamentos.google_event_id. Execute: ALTER TABLE agendamentos ADD COLUMN google_event_id VARCHAR(255) NULL;'
    )
    err.status = 500
    throw err
  }
}

function toIsoDateTime(value) {
  if (!value) return null
  const d = value instanceof Date ? value : new Date(value)
  if (Number.isNaN(d.getTime())) return null
  return d.toISOString()
}

async function assertProfissionalDoUsuario(userId) {
  const profissional = await getProfissionalByUserId(userId)
  if (!profissional?.id) {
    const err = new Error('Usuário não possui barbeiro/profissional vinculado.')
    err.status = 409
    throw err
  }
  return profissional
}

async function requireGoogleConnected(userId) {
  try {
    return await getAuthenticatedGoogleClientForUser(userId)
  } catch (err) {
    // Mantém status do erro quando existir (ex: 409), mas garante uma mensagem clara.
    const status = err?.status || 409
    const msg = err?.message || 'Conecte sua conta Google para continuar.'
    const wrapped = new Error(msg)
    wrapped.status = status
    throw wrapped
  }
}

export async function listAgendamentosForLoggedUser({ userId, start, end }) {
  await ensureAgendamentosSchema()

  const profissional = await assertProfissionalDoUsuario(userId)

  const where = ['a.profissional_id = ?']
  const params = [profissional.id]

  if (start) {
    where.push('a.data_hora_inicio >= ?')
    params.push(start)
  }
  if (end) {
    where.push('a.data_hora_inicio < ?')
    params.push(end)
  }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

  const [rows] = await dbp.query(
    `SELECT
       a.id,
       a.cliente_id,
       c.nome AS cliente_nome,
       a.profissional_id,
       p.nome AS profissional_nome,
       a.servico_id,
       s.nome AS servico_nome,
       a.data_hora_inicio,
       a.data_hora_fim,
       a.status,
       a.observacoes,
       a.google_event_id
     FROM agendamentos a
     INNER JOIN clientes c ON c.id = a.cliente_id
     INNER JOIN profissionais p ON p.id = a.profissional_id
     INNER JOIN servicos s ON s.id = a.servico_id
     ${whereSql}
     ORDER BY a.data_hora_inicio ASC`,
    params
  )

  return { profissional, items: rows }
}

export async function createAgendamentoForLoggedUser({
  userId,
  clienteId,
  servicoId,
  dataHoraInicio,
  dataHoraFim,
  status = 'AGENDADO',
  observacoes = null,
  syncGoogle = false,
  timeZone = 'America/Sao_Paulo',
}) {
  await ensureAgendamentosSchema()

  const profissional = await assertProfissionalDoUsuario(userId)

  // Regra: para criar/gerenciar agendamentos, o usuário precisa estar conectado ao Google.
  // Mesmo que o frontend não envie syncGoogle, aqui a sincronização é mandatória.
  const { calendar, calendarId } = await requireGoogleConnected(userId)

  if (!clienteId || !servicoId || !dataHoraInicio || !dataHoraFim) {
    const err = new Error('clienteId, servicoId, dataHoraInicio e dataHoraFim são obrigatórios.')
    err.status = 400
    throw err
  }

  const conn = await dbp.getConnection()
  try {
    await conn.beginTransaction()

    // Busca nomes para montar evento do Google, se necessário
    const [[cliente]] = await conn.query('SELECT id, nome FROM clientes WHERE id = ? LIMIT 1', [
      clienteId,
    ])
    const [[servico]] = await conn.query('SELECT id, nome FROM servicos WHERE id = ? LIMIT 1', [
      servicoId,
    ])

    if (!cliente) {
      const err = new Error('Cliente não encontrado.')
      err.status = 404
      throw err
    }
    if (!servico) {
      const err = new Error('Serviço não encontrado.')
      err.status = 404
      throw err
    }

    const [insertRes] = await conn.query(
      `INSERT INTO agendamentos (
         cliente_id,
         profissional_id,
         servico_id,
         data_hora_inicio,
         data_hora_fim,
         status,
         observacoes,
         google_event_id
       ) VALUES (?, ?, ?, ?, ?, ?, ?, NULL)`,
      [
        clienteId,
        profissional.id,
        servicoId,
        dataHoraInicio,
        dataHoraFim,
        status,
        observacoes,
      ]
    )

    const agendamentoId = insertRes.insertId

    let googleEventId = null

    // Sync obrigatório (mantém parâmetro syncGoogle só por compatibilidade)
    void syncGoogle

    const startIso = toIsoDateTime(dataHoraInicio)
    const endIso = toIsoDateTime(dataHoraFim)
    if (!startIso || !endIso) {
      const err = new Error('Datas inválidas para sincronização com Google Calendar.')
      err.status = 400
      throw err
    }

    const summary = `${servico.nome} - ${cliente.nome}`

    const resp = await calendar.events.insert({
      calendarId,
      requestBody: {
        summary,
        description: observacoes || undefined,
        start: { dateTime: startIso, timeZone },
        end: { dateTime: endIso, timeZone },
      },
    })

    googleEventId = resp?.data?.id || null

    if (googleEventId) {
      await conn.query('UPDATE agendamentos SET google_event_id = ? WHERE id = ?', [
        googleEventId,
        agendamentoId,
      ])
    }

    await conn.commit()

    return {
      id: agendamentoId,
      googleEventId,
    }
  } catch (err) {
    try {
      await conn.rollback()
    } catch {
      // ignore
    }
    throw err
  } finally {
    conn.release()
  }
}

export async function updateAgendamentoForLoggedUser({
  userId,
  agendamentoId,
  patch,
  syncGoogle = false,
  timeZone = 'America/Sao_Paulo',
}) {
  await ensureAgendamentosSchema()

  const profissional = await assertProfissionalDoUsuario(userId)

  // Regra: para criar/gerenciar agendamentos, o usuário precisa estar conectado ao Google.
  const { calendar, calendarId } = await requireGoogleConnected(userId)

  if (!agendamentoId) {
    const err = new Error('agendamentoId é obrigatório.')
    err.status = 400
    throw err
  }

  const allowed = {
    cliente_id: patch?.clienteId,
    servico_id: patch?.servicoId,
    data_hora_inicio: patch?.dataHoraInicio,
    data_hora_fim: patch?.dataHoraFim,
    status: patch?.status,
    observacoes: patch?.observacoes,
  }

  const fields = Object.entries(allowed).filter(([, v]) => v !== undefined)
  if (!fields.length) {
    return { updated: false }
  }

  const conn = await dbp.getConnection()
  try {
    await conn.beginTransaction()

    const [rows] = await conn.query(
      `SELECT * FROM agendamentos WHERE id = ? AND profissional_id = ? LIMIT 1`,
      [agendamentoId, profissional.id]
    )

    if (!rows.length) {
      const err = new Error('Agendamento não encontrado.')
      err.status = 404
      throw err
    }

    const current = rows[0]

    const setSql = fields.map(([k]) => `${k} = ?`).join(', ')
    const params = fields.map(([, v]) => v)
    params.push(agendamentoId, profissional.id)

    await conn.query(
      `UPDATE agendamentos SET ${setSql} WHERE id = ? AND profissional_id = ?`,
      params
    )

    // Sync obrigatório (mantém parâmetro syncGoogle só por compatibilidade)
    void syncGoogle

    const nextClienteId = allowed.cliente_id ?? current.cliente_id
    const nextServicoId = allowed.servico_id ?? current.servico_id
    const nextInicio = allowed.data_hora_inicio ?? current.data_hora_inicio
    const nextFim = allowed.data_hora_fim ?? current.data_hora_fim
    const nextObs = allowed.observacoes ?? current.observacoes

    const [[cliente]] = await conn.query('SELECT id, nome FROM clientes WHERE id = ? LIMIT 1', [
      nextClienteId,
    ])
    const [[servico]] = await conn.query('SELECT id, nome FROM servicos WHERE id = ? LIMIT 1', [
      nextServicoId,
    ])

    const summary = `${servico?.nome || 'Serviço'} - ${cliente?.nome || 'Cliente'}`

    const startIso = toIsoDateTime(nextInicio)
    const endIso = toIsoDateTime(nextFim)

    if (!startIso || !endIso) {
      const err = new Error('Datas inválidas para sincronização com Google Calendar.')
      err.status = 400
      throw err
    }

    if (current.google_event_id) {
      await calendar.events.patch({
        calendarId,
        eventId: current.google_event_id,
        requestBody: {
          summary,
          description: nextObs || undefined,
          start: { dateTime: startIso, timeZone },
          end: { dateTime: endIso, timeZone },
        },
      })
    } else {
      const resp = await calendar.events.insert({
        calendarId,
        requestBody: {
          summary,
          description: nextObs || undefined,
          start: { dateTime: startIso, timeZone },
          end: { dateTime: endIso, timeZone },
        },
      })

      const googleEventId = resp?.data?.id || null
      if (googleEventId) {
        await conn.query('UPDATE agendamentos SET google_event_id = ? WHERE id = ?', [
          googleEventId,
          agendamentoId,
        ])
      }
    }

    await conn.commit()
    return { updated: true }
  } catch (err) {
    try {
      await conn.rollback()
    } catch {
      // ignore
    }
    throw err
  } finally {
    conn.release()
  }
}

export async function deleteAgendamentoForLoggedUser({ userId, agendamentoId, syncGoogle = false }) {
  await ensureAgendamentosSchema()

  const profissional = await assertProfissionalDoUsuario(userId)

  // Regra: para criar/gerenciar agendamentos, o usuário precisa estar conectado ao Google.
  const { calendar, calendarId } = await requireGoogleConnected(userId)

  const conn = await dbp.getConnection()
  try {
    await conn.beginTransaction()

    const [rows] = await conn.query(
      `SELECT id, google_event_id FROM agendamentos WHERE id = ? AND profissional_id = ? LIMIT 1`,
      [agendamentoId, profissional.id]
    )

    if (!rows.length) {
      const err = new Error('Agendamento não encontrado.')
      err.status = 404
      throw err
    }

    const current = rows[0]

    // Sync obrigatório (mantém parâmetro syncGoogle só por compatibilidade)
    void syncGoogle

    if (current.google_event_id) {
      try {
        await calendar.events.delete({ calendarId, eventId: current.google_event_id })
      } catch {
        // não bloqueia a exclusão local se já não existir no Google
      }
    }

    await conn.query('DELETE FROM agendamentos WHERE id = ? AND profissional_id = ?', [
      agendamentoId,
      profissional.id,
    ])

    await conn.commit()
    return { deleted: true }
  } catch (err) {
    try {
      await conn.rollback()
    } catch {
      // ignore
    }
    throw err
  } finally {
    conn.release()
  }
}

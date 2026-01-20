import db from '../db.js'

import { getAuthenticatedGoogleClientForUser } from './googleCalendarClient.js'
import { getProfissionalByUserId } from './profissionais.service.js'

const dbp = typeof db.promise === 'function' ? db.promise() : db

function normalizeBoolean(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue
  if (typeof value === 'boolean') return value
  const v = String(value).toLowerCase()
  return v === 'true' || v === '1' || v === 'yes'
}

export async function listGoogleEventsForUser({
  userId,
  timeMin,
  timeMax,
  maxResults = 250,
  singleEvents = true,
  orderBy = 'startTime',
  q,
}) {
  const { calendar, calendarId, googleEmail } = await getAuthenticatedGoogleClientForUser(userId)

  const resp = await calendar.events.list({
    calendarId,
    timeMin: timeMin || undefined,
    timeMax: timeMax || undefined,
    maxResults: Number(maxResults) || 250,
    singleEvents: normalizeBoolean(singleEvents, true),
    orderBy: orderBy || undefined,
    q: q || undefined,
  })

  return {
    calendarId,
    googleEmail,
    items: resp?.data?.items || [],
    nextPageToken: resp?.data?.nextPageToken || null,
    timeZone: resp?.data?.timeZone || null,
  }
}

export async function createGoogleEventForUser({
  userId,
  requestBody,
  timeZone,
  agendamentoId,
}) {
  const { calendar, calendarId } = await getAuthenticatedGoogleClientForUser(userId)

  const rb = { ...(requestBody || {}) }
  if (timeZone) {
    if (rb.start?.dateTime && !rb.start?.timeZone) rb.start = { ...rb.start, timeZone }
    if (rb.end?.dateTime && !rb.end?.timeZone) rb.end = { ...rb.end, timeZone }
  }

  const resp = await calendar.events.insert({
    calendarId,
    requestBody: rb,
  })

  const eventId = resp?.data?.id || null

  // Opcional: vincular ao agendamento do barbeiro logado
  if (eventId && agendamentoId) {
    const profissional = await getProfissionalByUserId(userId)
    if (!profissional?.id) {
      const err = new Error('Usuário não possui barbeiro/profissional vinculado.')
      err.status = 409
      throw err
    }

    await dbp.query(
      `UPDATE agendamentos
       SET google_event_id = ?
       WHERE id = ? AND profissional_id = ?`,
      [eventId, agendamentoId, profissional.id]
    )
  }

  return { calendarId, event: resp.data }
}

export async function patchGoogleEventForUser({ userId, eventId, requestBody }) {
  const { calendar, calendarId } = await getAuthenticatedGoogleClientForUser(userId)

  const resp = await calendar.events.patch({
    calendarId,
    eventId,
    requestBody: requestBody || {},
  })

  return { calendarId, event: resp.data }
}

export async function deleteGoogleEventForUser({ userId, eventId, detachAgendamento = true }) {
  const { calendar, calendarId } = await getAuthenticatedGoogleClientForUser(userId)

  // Tenta desvincular agendamentos locais (se houver)
  if (detachAgendamento) {
    const profissional = await getProfissionalByUserId(userId)
    if (profissional?.id) {
      await dbp.query(
        `UPDATE agendamentos
         SET google_event_id = NULL
         WHERE profissional_id = ? AND google_event_id = ?`,
        [profissional.id, eventId]
      )
    }
  }

  await calendar.events.delete({ calendarId, eventId })
  return { calendarId, deleted: true }
}

export async function queryFreebusyForUser({ userId, timeMin, timeMax, items }) {
  if (!timeMin || !timeMax) {
    const err = new Error('timeMin e timeMax são obrigatórios.')
    err.status = 400
    throw err
  }

  const { calendar, calendarId } = await getAuthenticatedGoogleClientForUser(userId)

  const requestItems = Array.isArray(items) && items.length ? items : [{ id: calendarId }]

  const resp = await calendar.freebusy.query({
    requestBody: {
      timeMin,
      timeMax,
      items: requestItems,
    },
  })

  return resp.data
}

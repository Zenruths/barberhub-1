import express from 'express'

import { authMiddleware } from '../middleware/authMiddleware.js'
import {
  createGoogleEventForUser,
  deleteGoogleEventForUser,
  listGoogleEventsForUser,
  patchGoogleEventForUser,
  queryFreebusyForUser,
} from '../services/googleCalendar.service.js'

const router = express.Router()

// Lista eventos do Google Calendar do usuário logado
router.get('/events', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id

    const { timeMin, timeMax, maxResults, singleEvents, orderBy, q } = req.query

    const result = await listGoogleEventsForUser({
      userId,
      timeMin: timeMin ? String(timeMin) : null,
      timeMax: timeMax ? String(timeMax) : null,
      maxResults,
      singleEvents,
      orderBy,
      q,
    })

    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

// Cria evento no Google Calendar (opcionalmente vincula a um agendamento local)
router.post('/events', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const { requestBody, timeZone, agendamentoId } = req.body || {}

    // Aceita payload direto (summary/start/end) ou encapsulado em requestBody
    const rb = requestBody || req.body

    const result = await createGoogleEventForUser({
      userId,
      requestBody: {
        ...rb,
        start: rb?.start,
        end: rb?.end,
      },
      timeZone,
      agendamentoId,
    })

    return res.status(201).json(result)
  } catch (err) {
    return next(err)
  }
})

// Atualiza evento no Google Calendar
router.patch('/events/:eventId', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const eventId = String(req.params.eventId)

    const { requestBody } = req.body || {}
    const rb = requestBody || req.body

    const result = await patchGoogleEventForUser({ userId, eventId, requestBody: rb })
    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

// Remove evento no Google Calendar (por padrão desvincula agendamentos locais)
router.delete('/events/:eventId', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const eventId = String(req.params.eventId)
    const detachAgendamento = String(req.query.detachAgendamento || 'true').toLowerCase() !== 'false'

    const result = await deleteGoogleEventForUser({ userId, eventId, detachAgendamento })
    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

// Consulta freebusy
router.post('/freebusy', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const { timeMin, timeMax, items } = req.body || {}

    const result = await queryFreebusyForUser({ userId, timeMin, timeMax, items })
    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

export default router

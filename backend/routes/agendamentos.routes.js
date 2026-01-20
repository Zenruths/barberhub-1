import express from 'express'

import { authMiddleware } from '../middleware/authMiddleware.js'
import {
  createAgendamentoForLoggedUser,
  deleteAgendamentoForLoggedUser,
  listAgendamentosForLoggedUser,
  updateAgendamentoForLoggedUser,
} from '../services/agendamentos.service.js'

const router = express.Router()

// Lista agendamentos do barbeiro logado
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const start = (req.query.start || '').toString().trim() || null
    const end = (req.query.end || '').toString().trim() || null

    const result = await listAgendamentosForLoggedUser({ userId, start, end })
    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

// Cria agendamento para o barbeiro logado
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const {
      clienteId,
      servicoId,
      dataHoraInicio,
      dataHoraFim,
      status,
      observacoes,
      syncGoogle,
      timeZone,
    } = req.body || {}

    const result = await createAgendamentoForLoggedUser({
      userId,
      clienteId,
      servicoId,
      dataHoraInicio,
      dataHoraFim,
      status,
      observacoes,
      syncGoogle: Boolean(syncGoogle),
      timeZone,
    })

    return res.status(201).json(result)
  } catch (err) {
    return next(err)
  }
})

// Atualiza agendamento do barbeiro logado
router.put('/:id', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const agendamentoId = Number(req.params.id)

    const { syncGoogle, timeZone, ...patch } = req.body || {}

    const result = await updateAgendamentoForLoggedUser({
      userId,
      agendamentoId,
      patch,
      syncGoogle: Boolean(syncGoogle),
      timeZone,
    })

    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

// Remove agendamento do barbeiro logado
router.delete('/:id', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const agendamentoId = Number(req.params.id)
    const syncGoogle = String(req.query.syncGoogle || '').toLowerCase() === 'true'

    const result = await deleteAgendamentoForLoggedUser({ userId, agendamentoId, syncGoogle })
    return res.json(result)
  } catch (err) {
    return next(err)
  }
})

export default router

import express from 'express'

import { authMiddleware } from '../middleware/authMiddleware.js'
import {
  createProfissionalWithUser,
  ensureProfissionalForUser,
} from '../services/profissionais.service.js'
import db from '../db.js'

const router = express.Router()

// Lista barbeiros/profissionais (com usuário vinculado quando existir)
// backend/routes/profissionais.routes.js

router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const [rows] = await db.query(
      `SELECT 
         p.id,
         p.nome,
         p.apelido,
         p.ativo,
         p.usuario_id,
         u.username,
         u.email,
         DATE_FORMAT(u.created_at, '%Y-%m-%d %H:%i:%s') AS usuario_created_at
       FROM profissionais p
       LEFT JOIN usuarios u ON u.id = p.usuario_id
       ORDER BY p.nome ASC`
    )

    return res.json({ items: rows })
  } catch (err) {
    console.error('Erro ao buscar profissionais:', err)
    return next(err)
  }
})

// Cria um barbeiro + usuário (login individual)
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const { nome, apelido, username, email, password } = req.body || {}

    const result = await createProfissionalWithUser({ nome, apelido, username, email, password })
    return res.status(201).json(result)
  } catch (err) {
    return next(err)
  }
})

// Cria (se não existir) o profissional vinculado ao usuário logado.
// Útil para ambientes onde já existe login, mas ainda não houve cadastro de profissional.
router.post('/me', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const { nome, apelido } = req.body || {}

    // Tenta usar dados do usuário se não vierem no body
    const resolvedNome = nome || req.user?.username || null
    const profissional = await ensureProfissionalForUser({ userId, nome: resolvedNome, apelido })

    return res.status(201).json({ profissional })
  } catch (err) {
    return next(err)
  }
})

export default router

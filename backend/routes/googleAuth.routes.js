import express from 'express'
import { authMiddleware } from '../middleware/authMiddleware.js'
import { getGoogleAuthUrlForUser, handleGoogleCallback } from '../services/googleAuth.service.js'
import { FRONTEND_URL } from '../config/env.js'

const router = express.Router()

// Inicia o fluxo OAuth2 (barbeiro autenticado)
router.get('/google', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    const redirect = (req.query.redirect || '').toString().trim() || null

    const url = getGoogleAuthUrlForUser({ userId, redirect })
    return res.json({ url })
  } catch (err) {
    return next(err)
  }
})

// Callback do Google (não usa authMiddleware porque o redirect não leva Bearer token)
router.get('/google/callback', async (req, res, next) => {
  try {
    const code = req.query.code
    const state = req.query.state

    const result = await handleGoogleCallback({ code, state })

    // Por padrão, redireciona o usuário de volta para o front.
    const base = result.redirect || FRONTEND_URL
    if (!base) {
      return res.json({ success: true, ...result })
    }

    const url = new URL(base)
    url.searchParams.set('google', 'connected')
    if (result.googleEmail) url.searchParams.set('googleEmail', result.googleEmail)

    // Se o frontend preferir, ele também pode consumir JSON via Accept.
    const accept = (req.headers.accept || '').toLowerCase()
    if (accept.includes('application/json')) {
      return res.json({ success: true, ...result })
    }

    return res.redirect(url.toString())
  } catch (err) {
    return next(err)
  }
})

export default router

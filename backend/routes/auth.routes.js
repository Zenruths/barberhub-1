import express from 'express'
import { login, refresh, logout } from '../services/auth.service.js'
import { authMiddleware } from '../middleware/authMiddleware.js'
import db from '../db.js'
import { getProfissionalByUserId, getGoogleConnectionByUserId } from '../services/profissionais.service.js'

const dbp = typeof db.promise === 'function' ? db.promise() : db

const router = express.Router()

// Rota de login por email com registro em user_login_logs
router.post('/login', async (req, res, next) => {
  try {
    const { email, password, keepLoggedIn } = req.body

    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || null
    const userAgent = req.headers['user-agent'] || null

    const result = await login({ email, password, keepLoggedIn, ip, userAgent })

    return res.json(result)
  } catch (err) {
    console.error('Erro no login:', err)
    if (err.status) {
      return res.status(err.status).json({ error: err.message })
    }
    return next(err)
  }
})

// Rota para renovar access token usando refresh token
router.post('/refresh', async (req, res, next) => {
  try {
    const { refreshToken } = req.body

    const result = await refresh({ refreshToken })

    return res.json(result)
  } catch (err) {
    console.error('Erro no refresh token (rota):', err)
    if (err.status) {
      return res.status(err.status).json({ error: err.message })
    }
    return next(err)
  }
})

// Rota de logout com atualização de user_login_logs e revogação de refresh tokens
router.post('/logout', async (req, res, next) => {
  try {
    const auth = req.headers.authorization || ''
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : null

    const { refreshToken } = req.body || {}

    const result = await logout({ accessToken: token, refreshToken })

    return res.json(result)
  } catch (err) {
    console.error('Erro no logout (rota):', err)
    return next(err)
  }
})

// Retorna dados do usuário logado + barbeiro vinculado + status Google
router.get('/me', authMiddleware, async (req, res, next) => {
  try {
    const userId = req.user?.id
    if (!userId) return res.status(401).json({ error: 'Sessão expirada, faça login novamente.' })

    const [userRows] = await dbp.query('SELECT id, username, email FROM usuarios WHERE id = ? LIMIT 1', [userId])

    if (!userRows.length) {
      return res.status(401).json({ error: 'Sessão expirada, faça login novamente.' })
    }

    const user = userRows[0]
    const profissional = await getProfissionalByUserId(userId)
    const google = await getGoogleConnectionByUserId(userId)

    return res.json({ user, profissional, google })
  } catch (err) {
    return next(err)
  }
})

export default router

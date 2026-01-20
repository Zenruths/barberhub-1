// TWONINE
// backend/server.js
import express from 'express'
import cors from 'cors'

import authRoutes from './routes/auth.routes.js'
import basictablesRoutes from './routes/basictables.routes.js'
import googleAuthRoutes from './routes/googleAuth.routes.js'
import vendasRoutes from './routes/vendas.routes.js'
import clientesRoutes from './routes/clientes.routes.js'
import profissionaisRoutes from './routes/profissionais.routes.js'
import agendamentosRoutes from './routes/agendamentos.routes.js'
import googleCalendarRoutes from './routes/googleCalendar.routes.js'
import { errorHandler } from './middleware/errorHandler.js'

const app = express()
const PORT = process.env.PORT ? Number(process.env.PORT) : 3000

// Se estiver atrás de Nginx/Proxy, isso ajuda a pegar IP/headers corretos
app.set('trust proxy', true)

// CORS: o frontend (ex: http://195.200.6.230:5173) chama a API em outro origin.
// `origin: true` reflete o Origin do request e adiciona `Access-Control-Allow-Origin`.
// `optionsSuccessStatus` evita alguns problemas com proxies/clients mais antigos.
const corsOptions = {
  origin: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  optionsSuccessStatus: 204,
}

app.use(cors(corsOptions))
// Express 5 (path-to-regexp v6) não aceita '*' como path aqui.
// Usamos RegExp para cobrir qualquer rota no preflight.
app.options(/.*/, cors(corsOptions))
app.use(express.json())

// Healthcheck (Docker / monitoramento)
app.get('/api/health', (_req, res) => {
  res.status(200).json({ ok: true })
})

// Registro das rotas com prefixo /api
app.use('/api', authRoutes)
app.use('/api', basictablesRoutes)
app.use('/api/auth', googleAuthRoutes)
app.use('/api', vendasRoutes)
app.use('/api/clientes', clientesRoutes)
app.use('/api/profissionais', profissionaisRoutes)
app.use('/api/agendamentos', agendamentosRoutes)
app.use('/api/google', googleCalendarRoutes)

// Middleware global de erros (deve ser registrado após as rotas)
app.use(errorHandler)

app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`)
})

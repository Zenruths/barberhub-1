// backend/server.js
import express from 'express'
import cors from 'cors'

import authRoutes from './routes/auth.routes.js'
import basictablesRoutes from './routes/basictables.routes.js'
import vendasRoutes from './routes/vendas.routes.js'
import clientesRoutes from './routes/clientes.routes.js'
import { errorHandler } from './middleware/errorHandler.js'

const app = express()
const PORT = 3000

app.use(cors())
app.use(express.json())

// Registro das rotas com prefixo /api
app.use('/api', authRoutes)
app.use('/api', basictablesRoutes)
app.use('/api', vendasRoutes)
app.use('/api/clientes', clientesRoutes)
app.use('/api/profissionais', profissionaisRoutes)

// Middleware global de erros (deve ser registrado após as rotas)
app.use(errorHandler)

app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`)
})

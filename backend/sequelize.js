import { Sequelize } from 'sequelize'

// Mantém compatibilidade com o projeto atual (que usa mysql2 direto).
// Para produção, prefira configurar via variáveis de ambiente.
const host = process.env.DB_HOST || 'localhost'
const port = process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306
const user = process.env.DB_USER || 'root'
const password = process.env.DB_PASSWORD || 'eusouomestredosmagos'
const database = process.env.DB_NAME || 'edenerp'

export const sequelize = new Sequelize(database, user, password, {
  host,
  port,
  dialect: 'mysql',
  logging: false,
})

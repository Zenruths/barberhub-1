// backend/db.js
// Conexão com MariaDB/MySQL usando pool e promises
import mysql from 'mysql2'

const host = process.env.DB_HOST || 'localhost'
const port = process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306
const user = process.env.DB_USER || 'root'
const password = process.env.DB_PASSWORD || 'eusouomestredosmagos'
const database = process.env.DB_NAME || 'edenerp'

const pool = mysql
  .createPool({
    host,
    port,
    user,
    password,
    database,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  })
  .promise()

export default pool

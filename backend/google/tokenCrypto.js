import crypto from 'node:crypto'
import { GOOGLE_TOKEN_ENCRYPTION_KEY } from '../config/env.js'

// AES-256-GCM
const ALGO = 'aes-256-gcm'
const IV_BYTES = 12
const TAG_BYTES = 16

function getKey() {
  if (!GOOGLE_TOKEN_ENCRYPTION_KEY) {
    const err = new Error(
      'Config ausente: defina GOOGLE_TOKEN_ENCRYPTION_KEY (32 bytes em base64) para criptografar tokens.'
    )
    err.status = 500
    throw err
  }

  const key = Buffer.from(GOOGLE_TOKEN_ENCRYPTION_KEY, 'base64')
  if (key.length !== 32) {
    const err = new Error('GOOGLE_TOKEN_ENCRYPTION_KEY inválida (precisa ter 32 bytes em base64).')
    err.status = 500
    throw err
  }

  return key
}

export function encryptToken(plainText) {
  if (!plainText) return null

  const iv = crypto.randomBytes(IV_BYTES)
  const cipher = crypto.createCipheriv(ALGO, getKey(), iv)

  const enc = Buffer.concat([cipher.update(String(plainText), 'utf8'), cipher.final()])
  const tag = cipher.getAuthTag()

  return {
    enc: enc.toString('base64'),
    iv: iv.toString('base64'),
    tag: tag.toString('base64'),
  }
}

export function decryptToken(payload) {
  if (!payload?.enc || !payload?.iv || !payload?.tag) return null

  const iv = Buffer.from(payload.iv, 'base64')
  const tag = Buffer.from(payload.tag, 'base64')
  const data = Buffer.from(payload.enc, 'base64')

  const decipher = crypto.createDecipheriv(ALGO, getKey(), iv)
  decipher.setAuthTag(tag)

  const dec = Buffer.concat([decipher.update(data), decipher.final()])
  return dec.toString('utf8')
}

export const TOKEN_CRYPTO_META = {
  IV_BYTES,
  TAG_BYTES,
}

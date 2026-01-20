import { google } from 'googleapis'
import { createOAuth2Client } from '../google/oauthClient.js'
import { UserGoogleCalendarToken } from '../models/UserGoogleCalendarToken.js'
import { decryptToken, encryptToken } from '../google/tokenCrypto.js'

/**
 * Retorna um OAuth2Client autenticado para o usuário/barbeiro.
 * O googleapis renova access_token automaticamente quando existe refresh_token.
 * Aqui nós também persistimos o novo access_token/expiry_date quando ele for rotacionado.
 */
export async function getAuthenticatedGoogleClientForUser(userId) {
  if (!userId) {
    const err = new Error('userId é obrigatório.')
    err.status = 400
    throw err
  }

  const row = await UserGoogleCalendarToken.findOne({ where: { userId } })
  if (!row?.refreshTokenEnc) {
    const err = new Error('Google Calendar não conectado para este usuário.')
    err.status = 409
    throw err
  }

  const refreshToken = decryptToken({
    enc: row.refreshTokenEnc,
    iv: row.refreshTokenIv,
    tag: row.refreshTokenTag,
  })

  const oauth2 = createOAuth2Client()
  oauth2.setCredentials({
    refresh_token: refreshToken,
    // Ajuda o client a evitar refresh desnecessário
    expiry_date: row.expiryDateMs ? Number(row.expiryDateMs) : undefined,
    access_token: row.accessTokenEnc
      ? decryptToken({ enc: row.accessTokenEnc, iv: row.accessTokenIv, tag: row.accessTokenTag })
      : undefined,
  })

  oauth2.on('tokens', async (tokens) => {
    try {
      const updates = { updatedAt: new Date() }

      if (tokens.access_token) {
        const enc = encryptToken(tokens.access_token)
        updates.accessTokenEnc = enc.enc
        updates.accessTokenIv = enc.iv
        updates.accessTokenTag = enc.tag
      }

      if (typeof tokens.expiry_date === 'number') {
        updates.expiryDateMs = tokens.expiry_date
      }

      // Em geral o Google NÃO manda refresh_token novamente, mas se mandar, persistimos.
      if (tokens.refresh_token) {
        const enc = encryptToken(tokens.refresh_token)
        updates.refreshTokenEnc = enc.enc
        updates.refreshTokenIv = enc.iv
        updates.refreshTokenTag = enc.tag
      }

      await UserGoogleCalendarToken.update(updates, { where: { userId } })
    } catch {
      // Não derruba a request por falha de persistência.
    }
  })

  return {
    oauth2,
    calendarId: row.calendarId || 'primary',
    googleEmail: row.googleEmail || null,
    calendar: google.calendar({ version: 'v3', auth: oauth2 }),
  }
}

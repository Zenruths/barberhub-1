import jwt from 'jsonwebtoken'
import { google } from 'googleapis'
import { createOAuth2Client } from '../google/oauthClient.js'
import {
  GOOGLE_SCOPES,
  JWT_SECRET,
  FRONTEND_URL,
  GOOGLE_DEFAULT_CALENDAR_ID,
} from '../config/env.js'
import { UserGoogleCalendarToken } from '../models/UserGoogleCalendarToken.js'
import { encryptToken } from '../google/tokenCrypto.js'

function signOAuthState({ userId, redirect }) {
  // State é assinado para vincular callback ao usuário autenticado.
  return jwt.sign({ userId, redirect }, JWT_SECRET, { expiresIn: '10m' })
}

export function getGoogleAuthUrlForUser({ userId, redirect }) {
  if (!userId) {
    const err = new Error('Usuário autenticado é obrigatório.')
    err.status = 401
    throw err
  }

  const oauth2 = createOAuth2Client()
  const state = signOAuthState({ userId, redirect })

  const url = oauth2.generateAuthUrl({
    access_type: 'offline',
    // prompt=consent força o Google a reemitir refresh_token se necessário.
    // Você pode trocar por 'select_account' após estabilizar.
    prompt: 'consent',
    scope: GOOGLE_SCOPES,
    include_granted_scopes: true,
    state,
  })

  return url
}

export async function handleGoogleCallback({ code, state }) {
  if (!code || !state) {
    const err = new Error('Parâmetros inválidos: code/state são obrigatórios.')
    err.status = 400
    throw err
  }

  let decoded
  try {
    decoded = jwt.verify(state, JWT_SECRET)
  } catch {
    const err = new Error('State inválido ou expirado. Inicie a conexão novamente.')
    err.status = 400
    throw err
  }

  const userId = decoded?.userId
  const redirect = decoded?.redirect

  if (!userId) {
    const err = new Error('State inválido: userId ausente.')
    err.status = 400
    throw err
  }

  const oauth2 = createOAuth2Client()
  const { tokens } = await oauth2.getToken(code)

  oauth2.setCredentials(tokens)

  // E-mail é opcional (depende do scope userinfo.email)
  let googleEmail = null
  try {
    const oauth2Api = google.oauth2({ version: 'v2', auth: oauth2 })
    const me = await oauth2Api.userinfo.get()
    googleEmail = me?.data?.email || null
  } catch {
    googleEmail = null
  }

  const accessEnc = tokens.access_token ? encryptToken(tokens.access_token) : null
  const refreshEnc = tokens.refresh_token ? encryptToken(tokens.refresh_token) : null

  const existing = await UserGoogleCalendarToken.findOne({ where: { userId } })

  // Se o Google não retornar refresh_token (comum em reconexões), mantemos o que já existe.
  const refreshToPersist =
    refreshEnc ||
    (existing?.refreshTokenEnc
      ? {
          enc: existing.refreshTokenEnc,
          iv: existing.refreshTokenIv,
          tag: existing.refreshTokenTag,
        }
      : null)

  const calendarId = googleEmail || GOOGLE_DEFAULT_CALENDAR_ID

  const payload = {
    userId,
    googleEmail,
    calendarId,
    accessTokenEnc: accessEnc?.enc ?? null,
    accessTokenIv: accessEnc?.iv ?? null,
    accessTokenTag: accessEnc?.tag ?? null,
    refreshTokenEnc: refreshToPersist?.enc ?? null,
    refreshTokenIv: refreshToPersist?.iv ?? null,
    refreshTokenTag: refreshToPersist?.tag ?? null,
    expiryDateMs: tokens.expiry_date ?? null,
    connectedAt: existing?.connectedAt ?? new Date(),
    updatedAt: new Date(),
  }

  if (existing) {
    await existing.update(payload)
  } else {
    await UserGoogleCalendarToken.create(payload)
  }

  return {
    userId,
    googleEmail,
    calendarId,
    redirect: redirect || FRONTEND_URL || null,
  }
}

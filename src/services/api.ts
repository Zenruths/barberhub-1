// src/services/api.ts
// Helper centralizado para chamadas à API com envio de token e renovação de sessão

let isRefreshing = false
let refreshPromise: Promise<void> | null = null

export function getApiBaseUrl() {
  const raw = (import.meta.env.VITE_API_BASE_URL ?? '').toString().trim()
  if (raw) return raw.replace(/\/+$/, '')

  // Em DEV, o frontend roda em 5173 e a API em 3000.
  if (import.meta.env.DEV) return 'http://localhost:3000'

  // Em produção (Docker + Nginx), o ideal é ficar same-origin.
  if (typeof window !== 'undefined' && window.location?.origin) {
    return window.location.origin
  }

  return 'http://localhost:3000'
}

async function refreshAccessToken() {
  if (isRefreshing && refreshPromise) {
    return refreshPromise
  }

  isRefreshing = true

  refreshPromise = (async () => {
    const refreshToken =
      localStorage.getItem('refresh_token') || sessionStorage.getItem('refresh_token')

    if (!refreshToken) {
      throw new Error('Sem refresh token')
    }

    const baseUrl = getApiBaseUrl()

    const resp = await fetch(`${baseUrl}/api/refresh`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ refreshToken }),
    })

    if (!resp.ok) {
      throw new Error('Falha ao renovar sessão')
    }

    const data = await resp.json()
    const newAccessToken = data.accessToken

    if (!newAccessToken) {
      throw new Error('Nenhum access token retornado')
    }

    // salvar novo access token mantendo onde o refresh está salvo
    if (localStorage.getItem('refresh_token')) {
      localStorage.setItem('auth_token', newAccessToken)
    } else {
      sessionStorage.setItem('auth_token', newAccessToken)
    }
  })()

  try {
    await refreshPromise
  } finally {
    isRefreshing = false
    refreshPromise = null
  }
}

export async function apiFetch(input: string, init: RequestInit = {}, retry = true) {
  const token =
    localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token') || undefined

  const headersObj: Record<string, string> = {
    ...(init.headers as Record<string, string> | undefined),
  }

  if (token) {
    headersObj['Authorization'] = `Bearer ${token}`
  }

  const response = await fetch(input, {
    ...init,
    headers: headersObj as HeadersInit,
  })

  if (!response.ok) {
    let errBody: any = {}
    try {
      errBody = await response.json()
    } catch {
      // ignore
    }

    if (response.status === 401 && retry) {
      try {
        await refreshAccessToken()
        // Tenta novamente uma única vez, sem recursão infinita
        return apiFetch(input, init, false)
      } catch (e) {
        // falhou o refresh -> limpar tokens e redirecionar para login
        localStorage.removeItem('auth_token')
        localStorage.removeItem('refresh_token')
        sessionStorage.removeItem('auth_token')
        sessionStorage.removeItem('refresh_token')

        if (typeof window !== 'undefined') {
          window.location.href = '/signin?session=ended'
        }

        const msg =
          errBody.error || 'Sessão expirada, faça login novamente para continuar.'
        throw new Error(msg)
      }
    }

    const msg = errBody.error || 'Erro na requisição'
    throw new Error(msg)
  }

  return response.json()
}

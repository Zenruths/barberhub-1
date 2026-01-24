<template>
  <AdminLayout>
    <PageBreadcrumb pageTitle="Agenda" />
    <div class="p-6 space-y-4">
      <h1 class="text-2xl font-semibold">Agenda</h1>

      <div v-if="loading" class="text-sm text-gray-500 dark:text-gray-400">
        Carregando...
      </div>

      <div v-else-if="googleConnected === false" class="space-y-3">
        <p class="text-sm text-gray-700 dark:text-gray-300">
          Para criar e gerenciar agendamentos, é obrigatório conectar sua conta do Google Calendar.
        </p>
        <button
          type="button"
          class="inline-flex items-center justify-center rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
          @click="handleConnectGoogle"
        >
          Conectar Google Calendar
        </button>
        <p v-if="errorMessage" class="text-sm text-red-600">
          {{ errorMessage }}
        </p>
      </div>

      <div v-else class="space-y-2">
        <p class="text-sm text-gray-500 dark:text-gray-400">
          Google conectado. (A UI completa do calendário pode ser adicionada aqui.)
        </p>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import AdminLayout from '@/components/layout/AdminLayout.vue';
import PageBreadcrumb from '@/components/common/PageBreadcrumb.vue';

import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { apiFetch, getApiBaseUrl } from '@/services/api'

defineOptions({ name: 'AgendamentosAgenda' })

const route = useRoute()

const loading = ref(true)
const googleConnected = ref<boolean | null>(null)
const errorMessage = ref('')

const getErrorMessage = (e: unknown) => {
  if (e && typeof e === 'object' && 'message' in e) {
    const msg = (e as { message?: unknown }).message
    if (typeof msg === 'string' && msg.trim()) return msg
  }
  return 'Erro inesperado.'
}

onMounted(async () => {
  try {
    const baseUrl = getApiBaseUrl()
    const me = await apiFetch(`${baseUrl}/api/me`)
    googleConnected.value = Boolean(me?.google?.connected)
  } catch (e: unknown) {
    errorMessage.value = getErrorMessage(e) || 'Erro ao carregar status do Google.'
    googleConnected.value = false
  } finally {
    loading.value = false
  }
})

const handleConnectGoogle = async () => {
  errorMessage.value = ''
  try {
    const baseUrl = getApiBaseUrl()
    const redirect = `${window.location.origin}${route.fullPath}`
    const data = await apiFetch(`${baseUrl}/api/auth/google?redirect=${encodeURIComponent(redirect)}`)

    const url = data?.url
    if (!url) throw new Error('URL de conexão não retornada pela API.')

    window.location.href = url
  } catch (e: unknown) {
    errorMessage.value = getErrorMessage(e) || 'Erro ao iniciar conexão com o Google.'
  }
}
</script>

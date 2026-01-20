<template>
  <AdminLayout>
    <PageBreadcrumb pageTitle="Novo Barbeiro" />
    <div class="p-6 space-y-6">
      <div>
        <h1 class="text-2xl font-semibold">Novo barbeiro</h1>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          Cadastre um novo profissional/barbeiro com usuário e senha de acesso ao sistema.
        </p>
      </div>

      <!-- reaproveita o mesmo formulário da tela antiga -->
      <div
        class="rounded-lg border border-gray-200 bg-white p-4 dark:border-gray-800 dark:bg-gray-900"
      >
        <form class="mt-2 grid grid-cols-1 gap-4 md:grid-cols-2" @submit.prevent="createProfissional">
          <div>
            <label class="mb-1 block text-sm font-medium">Nome *</label>
            <input
              v-model.trim="form.nome"
              class="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-950"
              placeholder="Ex: João Carlos"
              required
            />
          </div>

          <div>
            <label class="mb-1 block text-sm font-medium">Apelido</label>
            <input
              v-model.trim="form.apelido"
              class="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-950"
              placeholder="Ex: Joao"
            />
          </div>

          <div>
            <label class="mb-1 block text-sm font-medium">Email (login) *</label>
            <input
              v-model.trim="form.email"
              type="email"
              class="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-950"
              placeholder="email@dominio.com"
              required
            />
          </div>

          <div>
            <label class="mb-1 block text-sm font-medium">Senha *</label>
            <input
              v-model="form.password"
              type="password"
              class="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-950"
              placeholder="Crie uma senha"
              required
            />
          </div>

          <div class="md:col-span-2">
            <label class="mb-1 block text-sm font-medium">Username (opcional)</label>
            <input
              v-model.trim="form.username"
              class="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm dark:border-gray-700 dark:bg-gray-950"
              placeholder="Se vazio, será gerado pelo nome/apelido"
            />
          </div>

          <div class="md:col-span-2 flex items-center gap-3">
            <button
              type="submit"
              class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
              :disabled="creating"
            >
              {{ creating ? 'Criando...' : 'Criar barbeiro' }}
            </button>

            <button
              type="button"
              class="rounded-md border border-gray-200 px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50 dark:border-gray-700 dark:hover:bg-gray-800"
              :disabled="creating"
              @click="resetForm"
            >
              Limpar
            </button>

            <p v-if="createOk" class="text-sm text-green-600 dark:text-green-400">
              Barbeiro criado e vinculado com sucesso.
            </p>

            <p v-if="createError" class="text-sm text-red-600 dark:text-red-400">
              {{ createError }}
            </p>
          </div>
        </form>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import PageBreadcrumb from '@/components/common/PageBreadcrumb.vue'
import { apiFetch, getApiBaseUrl } from '@/services/api'

const baseUrl = getApiBaseUrl()

const creating = ref(false)
const createError = ref<string | null>(null)
const createOk = ref(false)

const form = reactive({
  nome: '',
  apelido: '',
  username: '',
  email: '',
  password: '',
})

const resetForm = () => {
  form.nome = ''
  form.apelido = ''
  form.username = ''
  form.email = ''
  form.password = ''
  createError.value = null
  createOk.value = false
}

const createProfissional = async () => {
  try {
    creating.value = true
    createError.value = null
    createOk.value = false

    const payload = {
      nome: form.nome,
      apelido: form.apelido || undefined,
      username: form.username || undefined,
      email: form.email,
      password: form.password,
    }

    await apiFetch(`${baseUrl}/api/profissionais`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })

    createOk.value = true
    resetForm()
  } catch (e: any) {
    console.error('Erro ao criar barbeiro', e)
    createError.value = e?.message || 'Erro ao criar barbeiro.'
  } finally {
    creating.value = false
  }
}
</script>

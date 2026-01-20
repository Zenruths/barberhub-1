<template>
  <AdminLayout>
    <PageBreadcrumb :pageTitle="currentPageTitle" />
    <div class="space-y-5 sm:space-y-6">
      <ComponentCard title="Barbeiros">
        <!-- Barra superior dentro do card: controles + botão -->
        <div
          class="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
        >
          <!-- Controles de exibição (esquerda) -->
          <div
            class="flex items-center gap-2 px-2 text-xs text-gray-500 sm:px-0 dark:text-gray-400"
          >
            <span>Exibir</span>
            <select
              v-model.number="pageSize"
              class="h-8 rounded-lg border border-gray-200 bg-white px-2 text-xs text-gray-700 focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary dark:border-gray-700 dark:bg-gray-900 dark:text-gray-200"
            >
              <option :value="5">5</option>
              <option :value="15">15</option>
              <option :value="30">30</option>
            </select>
            <span>registros</span>
          </div>

          <!-- Campo de pesquisa + botão (direita) -->
          <div
            class="flex flex-col gap-3 px-2 text-xs text-gray-500 sm:flex-row sm:items-center sm:justify-end sm:px-0 dark:text-gray-400"
          >
            <!-- Campo de pesquisa -->
            <div class="w-full sm:w-64">
              <div
                class="flex h-8 items-center gap-2 rounded-lg border border-gray-200 bg-white px-2 text-xs text-gray-500 focus-within:border-primary focus-within:ring-1 focus-within:ring-primary dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300"
              >
                <svg
                  class="h-3 w-3 flex-shrink-0 text-gray-400"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M11 5a6 6 0 104.472 10.027l3.25 3.251a.75.75 0 101.06-1.06l-3.25-3.252A6 6 0 0011 5zm-4.5 6a4.5 4.5 0 119 0 4.5 4.5 0 01-9 0z"
                    fill="currentColor"
                  />
                </svg>
                <input
                  v-model="searchTerm"
                  type="text"
                  placeholder="Pesquisar por nome, apelido, usuário ou e-mail..."
                  class="w-full bg-transparent text-xs text-gray-700 placeholder:text-gray-400 focus:outline-none dark:text-gray-200 dark:placeholder:text-gray-500"
                />
              </div>
            </div>

            <!-- Botão Novo barbeiro -->
            <button
              class="rounded-md bg-blue-600 px-3 py-2 text-xs font-medium text-white hover:bg-blue-700 disabled:opacity-50"
              type="button"
              @click="goToNovoBarbeiro"
            >
              Novo barbeiro
            </button>
          </div>
        </div>

        <!-- Card interno com a tabela, igual Clientes -->
        <div
          class="rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/[0.03]"
        >
          <div class="max-w-full overflow-x-auto custom-scrollbar">
            <table class="min-w-full align-top table-auto">
              <thead>
                <tr class="border-b border-gray-200 dark:border-gray-700">
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Barbeiro
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Usuário
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Email
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Google
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Ativo
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Data criação
                    </p>
                  </th>
                  <th class="px-5 py-3 text-right sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Ações
                    </p>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                <tr v-if="loading">
                  <td
                    colspan="7"
                    class="px-5 py-6 text-center text-sm text-gray-500 sm:px-6 dark:text-gray-400"
                  >
                    Carregando barbeiros...
                  </td>
                </tr>

                <tr
                  v-else
                  v-for="(p, index) in paginatedItems"
                  :key="p.id"
                  class="border-t border-gray-100 align-top dark:border-gray-800"
                >
                  <td class="px-5 py-4 sm:px-6">
                    <div class="flex items-center gap-3">
                      <div
                        class="flex h-9 w-9 items-center justify-center rounded-full bg-gray-100 text-xs font-medium text-gray-600 dark:bg-gray-800 dark:text-gray-300"
                      >
                        {{ getIniciais(p.nome) }}
                      </div>
                      <div>
                        <span
                          class="block font-medium text-gray-800 text-theme-sm dark:text-white/90"
                        >
                          {{ p.nome }}
                        </span>
                        <span
                          v-if="p.apelido"
                          class="mt-0.5 block text-[11px] text-gray-500 dark:text-gray-400"
                        >
                          {{ p.apelido }}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ p.username || '-' }}
                    </p>
                  </td>
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ p.email || '-' }}
                    </p>
                  </td>
                  <td class="px-5 py-4 sm:px-6">
                    <span
                      class="inline-flex items-center rounded-full px-2 py-0.5 text-theme-xs bg-gray-100 text-gray-700 dark:bg-gray-700/40 dark:text-gray-200"
                    >
                      Não conectado
                    </span>
                  </td>
                  <td class="px-5 py-4 sm:px-6">
                    <span
                      class="inline-flex items-center rounded-full px-2 py-0.5 text-theme-xs"
                      :class="p.ativo
                        ? 'bg-primary/10 text-primary dark:bg-primary/20 dark:text-primary-400'
                        : 'bg-gray-100 text-gray-700 dark:bg-gray-700/40 dark:text-gray-200'"
                    >
                      {{ p.ativo ? 'Ativo' : 'Inativo' }}
                    </span>
                  </td>
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ formatDataCriacao(p.usuario_created_at) }}
                    </p>
                  </td>
                  <td class="px-5 py-4 text-right sm:px-6">
                    <button
                      type="button"
                      class="inline-flex h-8 w-8 items-center justify-center rounded-full text-gray-400 hover:bg-gray-100 hover:text-gray-600 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-200"
                      @click="toggleMenu(index, $event)"
                    >
                      <span class="sr-only">Abrir menu de ações</span>
                      <svg
                        class="h-4 w-4"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M10 4a1.5 1.5 0 110-3 1.5 1.5 0 010 3zM10 11.5a1.5 1.5 0 110-3 1.5 1.5 0 010 3zM10 19a1.5 1.5 0 110-3 1.5 1.5 0 010 3z"
                        />
                      </svg>
                    </button>
                  </td>
                </tr>

                <tr v-if="!loading && filteredItems.length === 0 && !error">
                  <td
                    colspan="7"
                    class="px-5 py-4 text-center text-sm text-gray-500 sm:px-6 dark:text-gray-400"
                  >
                    Nenhum barbeiro encontrado.
                  </td>
                </tr>

                <tr v-if="error && !loading">
                  <td
                    colspan="7"
                    class="px-5 py-4 text-center text-sm text-red-600 sm:px-6 dark:text-red-400"
                  >
                    {{ error }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginação igual Clientes -->
          <div
            class="flex flex-col gap-3 border-t border-gray-100 px-5 py-3 text-xs text-gray-500 sm:flex-row sm:items-center sm:justify-between dark:border-gray-800 dark:text-gray-400"
          >
            <p>
              Exibindo de
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ startItem }}</span>
              a
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ endItem }}</span>
              de
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ totalItems }}</span>
              barbeiros
            </p>

            <div class="inline-flex items-center gap-1 self-end sm:self-auto">
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === 1"
                @click="goToPage(1)"
              >
                «
              </button>
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                ‹
              </button>

              <span class="px-2 text-[11px] text-gray-600 dark:text-gray-300">
                Página
                <span class="font-medium">{{ currentPage }}</span>
                de
                <span class="font-medium">{{ totalPages }}</span>
              </span>

              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                ›
              </button>
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)"
              >
                »
              </button>
            </div>
          </div>
        </div>

        <!-- Menu de ações via teleport -->
        <teleport to="body">
          <div
            v-if="openMenuIndex !== null && menuPosition"
            :style="{ top: menuPosition.top + 'px', left: menuPosition.left + 'px' }"
            class="fixed z-50 mt-1 w-40 origin-top-right rounded-lg border border-gray-100 bg-white py-1 text-sm shadow-lg ring-1 ring-black/5 dark:border-gray-700 dark:bg-gray-900"
          >
            <button
              type="button"
              class="flex w-full items-center gap-2 px-3 py-1.5 text-left text-xs text-gray-700 hover:bg-gray-50 dark:text-gray-200 dark:hover:bg-gray-800"
              @click="handleEdit(currentMenuItemId)"
            >
              Editar
            </button>
            <button
              type="button"
              class="flex w-full items-center gap-2 px-3 py-1.5 text-left text-xs text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/20"
              @click="handleRemove(currentMenuItemId)"
            >
              Remover
            </button>
          </div>
        </teleport>
      </ComponentCard>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { onMounted, ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import PageBreadcrumb from '@/components/common/PageBreadcrumb.vue'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import ComponentCard from '@/components/common/ComponentCard.vue'
import { apiFetch, getApiBaseUrl } from '@/services/api'

const currentPageTitle = ref('Barbeiros')

type ProfissionalApi = {
  id: number
  nome: string
  apelido: string | null
  ativo: number | boolean
  usuario_id: number | null
  username?: string | null
  email?: string | null
  usuario_created_at?: string | null
}

const baseUrl = getApiBaseUrl()

const items = ref<ProfissionalApi[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

// Estados de UI (busca, paginação)
const searchTerm = ref('')
const pageSize = ref(15)
const currentPage = ref(1)

// Estado do menu de ações
const openMenuIndex = ref<number | null>(null)
const currentMenuItemId = ref<number | null>(null)
const menuPosition = ref<{ top: number; left: number } | null>(null)

const router = useRouter()

const goToNovoBarbeiro = () => {
  router.push('/equipe/novo-barbeiro')
}

const loadProfissionais = async () => {
  try {
    loading.value = true
    error.value = null

    const data = await apiFetch(`${baseUrl}/api/profissionais`)
    const list = Array.isArray(data) ? data : (data.items ?? [])
    console.log('profissionais brutos', list.map((p: any) => p.usuario_created_at))
    items.value = list as ProfissionalApi[]
  } catch (e) {
    console.error('Erro ao carregar barbeiros', e)
    error.value = 'Erro ao carregar barbeiros.'
  } finally {
    loading.value = false
  }
}

const getIniciais = (nome: string) => {
  if (!nome) return ''
  const partes = nome.trim().split(' ')
  const iniciais =
    partes.length === 1 ? partes[0][0] : partes[0][0] + partes[partes.length - 1][0]
  return iniciais.toUpperCase()
}

const formatDataCriacao = (value: string | null | undefined) => {
  if (!value) return '-'

  // Espera sempre string vinda do backend, sem conversao de timezone
  // Ex.: '2026-01-18 21:22:32' ou '2026-01-18T21:22:32.000Z'
  let dataStr = value
  let horaStr: string | undefined

  if (value.includes('T')) {
    const [d, t] = value.split('T')
    dataStr = d
    horaStr = t
  } else if (value.includes(' ')) {
    const [d, t] = value.split(' ')
    dataStr = d
    horaStr = t
  }

  const [ano, mes, dia] = dataStr.split('-')
  if (!ano || !mes || !dia) {
    return value
  }

  let horas = '00'
  let minutos = '00'
  if (horaStr) {
    const limpo = horaStr.replace('Z', '').split('.')[0]
    const [h, m] = limpo.split(':')
    if (h && m) {
      horas = h.padStart(2, '0')
      minutos = m.padStart(2, '0')
    }
  }

  return `${dia.padStart(2, '0')}/${mes.padStart(2, '0')}/${ano} ${horas}:${minutos}`
}

const filteredItems = computed(() => {
  const term = searchTerm.value.trim().toLowerCase()
  if (!term) return items.value

  return items.value.filter((p) => {
    return (
      p.nome.toLowerCase().includes(term) ||
      (p.apelido || '').toLowerCase().includes(term) ||
      (p.username || '').toLowerCase().includes(term) ||
      (p.email || '').toLowerCase().includes(term)
    )
  })
})

const totalItems = computed(() => filteredItems.value.length)
const totalPages = computed(() =>
  totalItems.value === 0 ? 1 : Math.ceil(totalItems.value / pageSize.value),
)

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredItems.value.slice(start, end)
})

const startItem = computed(() =>
  totalItems.value === 0 ? 0 : (currentPage.value - 1) * pageSize.value + 1,
)
const endItem = computed(() => {
  const potentialEnd = currentPage.value * pageSize.value
  return potentialEnd > totalItems.value ? totalItems.value : potentialEnd
})

const goToPage = (page: number) => {
  if (page < 1) return
  if (page > totalPages.value) return
  currentPage.value = page
}

const toggleMenu = (index: number, event: MouseEvent) => {
  if (openMenuIndex.value === index) {
    openMenuIndex.value = null
    currentMenuItemId.value = null
    menuPosition.value = null
    return
  }

  const rect = (event.currentTarget as HTMLElement).getBoundingClientRect()
  menuPosition.value = {
    top: rect.bottom + 4,
    left: rect.right - 160,
  }

  const item = paginatedItems.value[index]
  currentMenuItemId.value = item ? item.id : null
  openMenuIndex.value = index
}

const handleEdit = (profissionalId: number | null) => {
  if (!profissionalId) return
  console.log('Editar profissional (placeholder)', profissionalId)
  openMenuIndex.value = null
  currentMenuItemId.value = null
  menuPosition.value = null
}

const handleRemove = (profissionalId: number | null) => {
  if (!profissionalId) return
  console.log('Remover profissional (placeholder)', profissionalId)
  openMenuIndex.value = null
  currentMenuItemId.value = null
  menuPosition.value = null
}

watch([searchTerm, pageSize], () => {
  currentPage.value = 1
})

onMounted(async () => {
  await loadProfissionais()
})
</script>

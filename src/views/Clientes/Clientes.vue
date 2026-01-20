<template>
  <AdminLayout>
    <PageBreadcrumb :pageTitle="currentPageTitle" />
    <div class="space-y-5 sm:space-y-6">
      <!-- Cards de resumo -->
      <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <div
          class="rounded-2xl border border-gray-200 bg-white px-5 py-4 dark:border-gray-800 dark:bg-white/[0.03]"
        >
          <p class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
            Total de clientes
          </p>
          <p class="mt-2 text-2xl font-semibold text-gray-900 dark:text-white/90">
            {{ totalClientes }}
          </p>
        </div>

        <div
          class="rounded-2xl border border-gray-200 bg-white px-5 py-4 dark:border-gray-800 dark:bg-white/[0.03]"
        >
          <p class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
            Clientes ativos
          </p>
          <p class="mt-2 text-2xl font-semibold text-success-600 dark:text-success-400">
            {{ totalAtivos }}
          </p>
        </div>

        <div
          class="rounded-2xl border border-gray-200 bg-white px-5 py-4 dark:border-gray-800 dark:bg-white/[0.03]"
        >
          <p class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
            Clientes inativos
          </p>
          <p class="mt-2 text-2xl font-semibold text-gray-700 dark:text-gray-200">
            {{ totalInativos }}
          </p>
        </div>

        <div
          class="rounded-2xl border border-gray-200 bg-white px-5 py-4 dark:border-gray-800 dark:bg-white/[0.03]"
        >
          <p class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
            Clientes VIP
          </p>
          <p class="mt-2 text-2xl font-semibold text-warning-600 dark:text-warning-400">
            {{ totalVip }}
          </p>
        </div>
      </div>

      <ComponentCard title="Clientes">
        <!-- Barra superior dentro do card: controles + botão -->
        <div class="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
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
            <!-- Campo de pesquisa alinhado ao estilo do select -->
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
                  placeholder="Pesquisar cliente, telefone, barbeiro..."
                  class="w-full bg-transparent text-xs text-gray-700 placeholder:text-gray-400 focus:outline-none dark:text-gray-200 dark:placeholder:text-gray-500"
                />
              </div>
            </div>

            <!-- Botão Adicionar Cliente -->
            <UiButton
              variant="primary"
              size="sm"
              :endIcon="PlusIcon"
              className="!px-3 !py-2 text-xs"
            >
              Adicionar Cliente
            </UiButton>
          </div>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/[0.03]">
          <!-- wrapper com scroll apenas horizontal -->
          <div class="max-w-full overflow-x-auto custom-scrollbar">
            <table class="min-w-full align-top table-auto">
              <thead>
                <tr class="border-b border-gray-200 dark:border-gray-700">
                  <!-- Cliente -->
                  <th class="px-5 py-3 text-left w-3/11 sm:px-6">
                    <button
                      type="button"
                      class="inline-flex items-center gap-1 font-medium text-gray-500 text-theme-xs hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                      @click="toggleSort('nome')"
                    >
                      <span>Cliente</span>
                      <span v-if="sortBy === 'nome'">
                        <span v-if="sortDirection === 'asc'">▲</span>
                        <span v-else>▼</span>
                      </span>
                    </button>
                  </th>

                  <!-- Idade -->
                  <th class="px-5 py-3 text-left sm:px-6">
                    <button
                      type="button"
                      class="inline-flex items-center gap-1 font-medium text-gray-500 text-theme-xs hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                      @click="toggleSort('idade')"
                    >
                      <span>Idade</span>
                      <span v-if="sortBy === 'idade'">
                        <span v-if="sortDirection === 'asc'">▲</span>
                        <span v-else>▼</span>
                      </span>
                    </button>
                  </th>

                  <!-- Telefone -->
                  <th class="px-5 py-3 text-left w-2/11 sm:px-6">
                    <button
                      type="button"
                      class="inline-flex items-center gap-1 font-medium text-gray-500 text-theme-xs hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                      @click="toggleSort('telefone')"
                    >
                      <span>Telefone</span>
                      <span v-if="sortBy === 'telefone'">
                        <span v-if="sortDirection === 'asc'">▲</span>
                        <span v-else>▼</span>
                      </span>
                    </button>
                  </th>

                  <!-- Última visita (ordena por data em string por enquanto) -->
                  <th class="px-5 py-3 text-left w-3/11 sm:px-6">
                    <button
                      type="button"
                      class="inline-flex items-center gap-1 font-medium text-gray-500 text-theme-xs hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                      @click="toggleSort('ultimaData')"
                    >
                      <span>Última visita</span>
                      <span v-if="sortBy === 'ultimaData'">
                        <span v-if="sortDirection === 'asc'">▲</span>
                        <span v-else>▼</span>
                      </span>
                    </button>
                  </th>

                  <!-- Demais colunas mantêm texto simples -->
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">Frequência</p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Preferência de horário
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Barbeiro padrão
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">Plano ativo</p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Pontos de fidelidade
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">
                      Desconto personalizado
                    </p>
                  </th>
                  <th class="px-5 py-3 text-left w-2/11 sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">Status</p>
                  </th>
                  <th class="px-5 py-3 text-right w-2/11 sm:px-6">
                    <p class="font-medium text-gray-500 text-theme-xs dark:text-gray-400">Ações</p>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                <tr v-if="loading">
                  <td
                    colspan="12"
                    class="px-5 py-6 text-center text-sm text-gray-500 sm:px-6 dark:text-gray-400"
                  >
                    Carregando clientes...
                  </td>
                </tr>

                <tr
                  v-else
                  v-for="(row, index) in paginatedRows"
                  :key="index"
                  class="border-t border-gray-100 align-top dark:border-gray-800"
                >
                  <!-- Cliente (avatar + nome) -->
                  <td class="px-5 py-4 sm:px-6">
                    <div class="flex items-center gap-3">
                      <div
                        class="flex h-9 w-9 items-center justify-center rounded-full bg-gray-100 text-xs font-medium text-gray-600 dark:bg-gray-800 dark:text-gray-300"
                      >
                        {{ row.iniciais }}
                      </div>
                      <div>
                        <span
                          class="block font-medium text-gray-800 text-theme-sm dark:text-white/90"
                        >
                          {{ row.nome }}
                        </span>
                      </div>
                    </div>
                  </td>

                  <!-- Idade -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.idade }} anos
                    </p>
                  </td>

                  <!-- Telefone -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.telefone }}
                    </p>
                  </td>

                  <!-- Última visita (serviço + data) -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-800 text-theme-sm dark:text-white/90">
                      {{ row.ultimoServico }}
                    </p>
                    <p class="text-gray-500 text-xs dark:text-gray-400">
                      {{ row.ultimaData }}
                    </p>
                  </td>

                  <!-- Frequência -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.frequencia }}
                    </p>
                  </td>

                  <!-- Preferência de horário -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.preferenciaHorario }}
                    </p>
                  </td>

                  <!-- Barbeiro padrão -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.barbeiroPadrao }}
                    </p>
                  </td>

                  <!-- Plano ativo -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.planoAtivo }}
                    </p>
                  </td>

                  <!-- Pontos de fidelidade -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.pontosFidelidade }} pts
                    </p>
                  </td>

                  <!-- Desconto personalizado -->
                  <td class="px-5 py-4 sm:px-6">
                    <p class="text-gray-500 text-theme-sm dark:text-gray-400">
                      {{ row.descontoPersonalizado }}
                    </p>
                  </td>

                  <!-- Status -->
                  <td class="px-5 py-4 sm:px-6">
                    <span
                      :class="[
                        'rounded-full px-2 py-0.5 text-theme-xs font-medium',
                        {
                          'bg-success-50 text-success-700 dark:bg-success-500/15 dark:text-success-500':
                            row.status === 'Ativo',
                          'bg-gray-100 text-gray-700 dark:bg-gray-700/40 dark:text-gray-200':
                            row.status === 'Inativo',
                          'bg-warning-50 text-warning-700 dark:bg-warning-500/15 dark:text-warning-400':
                            row.status === 'VIP',
                        },
                      ]"
                    >
                      {{ row.status }}
                    </span>
                  </td>

                  <!-- Ações com menu de 3 pontinhos -->
                  <td class="px-5 py-4 sm:px-6 align-top">
                    <div class="relative flex justify-end">
                      <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-full text-gray-500 hover:bg-gray-100 hover:text-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-100"
                        @click="toggleMenu(index, $event)"
                      >
                        <span class="sr-only">Ações</span>
                        <span class="inline-flex flex-col gap-[2px]">
                          <span class="block h-[2px] w-[2px] rounded-full bg-current"></span>
                          <span class="block h-[2px] w-[2px] rounded-full bg-current"></span>
                          <span class="block h-[2px] w-[2px] rounded-full bg-current"></span>
                        </span>
                      </button>
                    </div>
                  </td>
                </tr>

                <tr v-if="!loading && !filteredRows.length">
                  <td
                    colspan="12"
                    class="px-5 py-4 text-center text-sm text-gray-500 sm:px-6 dark:text-gray-400"
                  >
                    Nenhum cliente encontrado.
                  </td>
                </tr>

                <tr v-if="error && !loading">
                  <td
                    colspan="12"
                    class="px-5 py-4 text-center text-sm text-error-600 sm:px-6 dark:text-error-400"
                  >
                    {{ error }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div
            class="flex flex-col gap-3 border-t border-gray-100 px-5 py-3 text-xs text-gray-500 sm:flex-row sm:items-center sm:justify-between dark:border-gray-800 dark:text-gray-400"
          >
            <p>
              Exibindo de
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ startItem }}</span>
              a
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ endItem }}</span>
              de
              <span class="font-medium text-gray-700 dark:text-gray-200">{{ totalClientes }}</span>
              clientes
            </p>

            <div class="inline-flex items-center gap-1 self-end sm:self-auto">
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === 1"
                @click="goToPage(1)"
              >
                <span class="sr-only">Primeira página</span>
                «
              </button>
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                <span class="sr-only">Página anterior</span>
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
                <span class="sr-only">Próxima página</span>
                ›
              </button>
              <button
                type="button"
                class="flex h-8 w-8 items-center justify-center rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)"
              >
                <span class="sr-only">Última página</span>
                »
              </button>
            </div>
          </div>
        </div>

        <!-- Dropdown global fora da área rolável -->
        <teleport to="body">
          <div
            v-if="openMenuIndex !== null && dropdownPosition"
            :style="{
              position: 'fixed',
              top: dropdownPosition.top + 'px',
              left: dropdownPosition.left + 'px',
              zIndex: 9999,
            }"
            class="w-32 overflow-hidden rounded-lg border border-gray-100 bg-white text-xs shadow-lg dark:border-gray-700 dark:bg-gray-900"
          >
            <button
              type="button"
              class="flex w-full items-center px-3 py-2 text-left text-gray-700 hover:bg-gray-50 dark:text-gray-200 dark:hover:bg-gray-800"
            >
              Agendar
            </button>
            <button
              type="button"
              class="flex w-full items-center px-3 py-2 text-left text-gray-700 hover:bg-gray-50 dark:text-gray-200 dark:hover:bg-gray-800"
            >
              Ver
            </button>
            <button
              type="button"
              class="flex w-full items-center px-3 py-2 text-left text-gray-700 hover:bg-gray-50 dark:text-gray-200 dark:hover:bg-gray-800"
            >
              Editar
            </button>
            <button
              type="button"
              class="flex w-full items-center px-3 py-2 text-left text-error-600 hover:bg-error-50 dark:text-error-400 dark:hover:bg-error-500/10"
            >
              Excluir
            </button>
          </div>
        </teleport>
      </ComponentCard>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import PageBreadcrumb from '@/components/common/PageBreadcrumb.vue'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import ComponentCard from '@/components/common/ComponentCard.vue'
import UiButton from '@/components/ui/Button.vue'
import PlusIcon from '@/icons/PlusIcon.vue'
import { apiFetch, getApiBaseUrl } from '@/services/api'

const currentPageTitle = ref('Clientes')

interface Row {
  nome: string
  iniciais: string
  idade: number
  telefone: string
  ultimoServico: string
  ultimaData: string
  frequencia: 'Semanal' | 'Quinzenal' | 'Mensal'
  preferenciaHorario: string
  barbeiroPadrao: string
  planoAtivo: string
  pontosFidelidade: number
  descontoPersonalizado: string
  status: 'Ativo' | 'Inativo' | 'VIP'
}

interface ClienteApi {
  id: number
  nome: string
  telefone_principal: string | null
  telefone_secundario: string | null
  email: string | null
  data_nascimento: string | null
  data_cadastro: string
  ativo: number
  vip: number
  frequencia: string | null
  plano_ativo: string | null
  pontos_fidelidade: number | null
  desconto_personalizado: number | null
  preferencia_horario: string | null
  profissional_padrao_id: number | null
  profissional_padrao_nome: string | null
  observacoes: string | null
}

const calcularIdade = (dataIso: string | null): number => {
  if (!dataIso) return 0
  const hoje = new Date()
  const nasc = new Date(dataIso)
  if (Number.isNaN(nasc.getTime())) return 0

  let idade = hoje.getFullYear() - nasc.getFullYear()
  const m = hoje.getMonth() - nasc.getMonth()
  if (m < 0 || (m === 0 && hoje.getDate() < nasc.getDate())) {
    idade--
  }
  return idade
}

const mapClienteApiToRow = (c: ClienteApi): Row => {
  const idade = calcularIdade(c.data_nascimento)

  const status: Row['status'] = c.vip
    ? 'VIP'
    : c.ativo
    ? 'Ativo'
    : 'Inativo'

  const nome = c.nome
  const iniciais =
    nome
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((p) => p[0]?.toUpperCase())
      .join('') || '?'

  return {
    nome,
    iniciais,
    idade,
    telefone: c.telefone_principal || c.telefone_secundario || '',
    // Por enquanto mantemos último serviço/data mockados
    ultimoServico: 'Sem Informação',
    ultimaData: 'Sem Informação',
    frequencia: (c.frequencia as Row['frequencia']) || 'Sem Informação',
    preferenciaHorario: c.preferencia_horario || 'Sem Informação',
    barbeiroPadrao: c.profissional_padrao_nome || 'Sem Informação',
    planoAtivo: c.plano_ativo || 'Sem Informação',
    pontosFidelidade: c.pontos_fidelidade ?? 0,
    descontoPersonalizado: `${c.desconto_personalizado ?? 0}%`,
    status,
  }
}

const rows = ref<Row[]>([])

const loading = ref(false)
const error = ref<string | null>(null)

onMounted(async () => {
  try {
    loading.value = true
    error.value = null

    const baseUrl = getApiBaseUrl()
    const data = await apiFetch(`${baseUrl}/api/clientes`)

    // A API retorna um objeto { items, total, page, pageSize }
    const list = Array.isArray(data) ? data : (data.items ?? [])

    rows.value = (list as ClienteApi[]).map(mapClienteApiToRow)
  } catch (e) {
    console.error('Erro ao carregar clientes', e)
    error.value = 'Erro ao carregar clientes.'
  } finally {
    loading.value = false
  }
})

const searchTerm = ref('')
const pageSize = ref(15)
const currentPage = ref(1)

// Estado de ordenação
const sortBy = ref<'nome' | 'idade' | 'telefone' | 'ultimaData' | null>(null)
const sortDirection = ref<'asc' | 'desc'>('asc')

const filteredRows = computed(() => {
  const term = searchTerm.value.trim().toLowerCase()
  let base = rows.value

  if (term) {
    base = base.filter((row) => {
      return (
        row.nome.toLowerCase().includes(term) ||
        row.telefone.toLowerCase().includes(term) ||
        row.barbeiroPadrao.toLowerCase().includes(term) ||
        row.ultimoServico.toLowerCase().includes(term)
      )
    })
  }

  if (!sortBy.value) return base

  const sorted = [...base].sort((a, b) => {
    const key = sortBy.value as keyof Row
    const dir = sortDirection.value === 'asc' ? 1 : -1

    const aVal = a[key]
    const bVal = b[key]

    if (typeof aVal === 'number' && typeof bVal === 'number') {
      return (aVal - bVal) * dir
    }

    return String(aVal).localeCompare(String(bVal)) * dir
  })

  return sorted
})

const totalClientes = computed(() => filteredRows.value.length)
const totalPages = computed(() =>
  totalClientes.value === 0 ? 1 : Math.ceil(totalClientes.value / pageSize.value),
)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredRows.value.slice(start, end)
})

const startItem = computed(() =>
  totalClientes.value === 0 ? 0 : (currentPage.value - 1) * pageSize.value + 1,
)
const endItem = computed(() => {
  const potentialEnd = currentPage.value * pageSize.value
  return potentialEnd > totalClientes.value ? totalClientes.value : potentialEnd
})

const goToPage = (page: number) => {
  if (page < 1) return
  if (page > totalPages.value) return
  currentPage.value = page
}

// Sempre que o termo de busca ou o tamanho da página mudar, voltar para a página 1
watch([searchTerm, pageSize], () => {
  currentPage.value = 1
})

const totalAtivos = computed(() => rows.value.filter((r) => r.status === 'Ativo').length)
const totalInativos = computed(() => rows.value.filter((r) => r.status === 'Inativo').length)
const totalVip = computed(() => rows.value.filter((r) => r.status === 'VIP').length)

const openMenuIndex = ref<number | null>(null)
const dropdownPosition = ref<{ top: number; left: number } | null>(null)

const toggleMenu = (index: number, event: MouseEvent) => {
  if (openMenuIndex.value === index) {
    openMenuIndex.value = null
    dropdownPosition.value = null
    return
  }

  const target = event.currentTarget as HTMLElement | null
  if (!target) return

  const rect = target.getBoundingClientRect()

  // posiciona o dropdown logo abaixo e alinhado à direita do botão
  dropdownPosition.value = {
    top: rect.bottom + 4,
    left: rect.right - 128, // 128px = largura aproximada (w-32)
  }

  openMenuIndex.value = index
}

// Alterna ordenação ao clicar no header
const toggleSort = (field: 'nome' | 'idade' | 'telefone' | 'ultimaData') => {
  if (sortBy.value === field) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = field
    sortDirection.value = 'asc'
  }

  currentPage.value = 1
}
</script>

<style scoped>
/* Mesmo estilo de tabela base, usando utilitários Tailwind */
</style>
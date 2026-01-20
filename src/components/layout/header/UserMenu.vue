<template>
  <div class="relative" ref="dropdownRef">
    <button
      class="flex items-center text-gray-700 dark:text-gray-400"
      @click.prevent="toggleDropdown"
    >
      <span class="mr-3 overflow-hidden rounded-full h-11 w-11">
        <img src="/images/user/owner.jpg" alt="User" />
      </span>

      <!-- Aqui mostra APENAS o username (displayName) -->
      <span class="block mr-1 font-medium text-theme-sm">{{ displayName }}</span>

      <ChevronDownIcon :class="{ 'rotate-180': dropdownOpen }" />
    </button>

    <!-- Dropdown Start -->
    <div
      v-if="dropdownOpen"
      class="absolute right-0 mt-[17px] flex w-[260px] flex-col rounded-2xl border border-gray-200 bg-white p-3 shadow-theme-lg dark:border-gray-800 dark:bg-gray-dark"
    >
      <div>
        <!-- Nome (username) -->
        <span class="block font-medium text-gray-700 text-theme-sm dark:text-gray-400">
          {{ displayName }}
        </span>
        <!-- Apenas email embaixo -->
        <span class="mt-0.5 block text-theme-xs text-gray-500 dark:text-gray-400">
          {{ userEmail || '---' }}
        </span>
      </div>

      <ul class="flex flex-col gap-1 pt-4 pb-3 border-b border-gray-200 dark:border-gray-800">
        <li v-for="item in menuItems" :key="item.href">
          <router-link
            :to="item.href"
            class="flex items-center gap-3 px-3 py-2 font-medium text-gray-700 rounded-lg group text-theme-sm hover:bg-gray-100 hover:text-gray-700 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-gray-300"
          >
            <!-- SVG icon would go here -->
            <component
              :is="item.icon"
              class="text-gray-500 group-hover:text-gray-700 dark:group-hover:text-gray-300"
            />
            {{ item.text }}
          </router-link>
        </li>
      </ul>
      <router-link
        to="/signin"
        @click.prevent="signOut"
        class="flex items-center gap-3 px-3 py-2 mt-3 font-medium text-gray-700 rounded-lg group text-theme-sm hover:bg-gray-100 hover:text-gray-700 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-gray-300"
      >
        <LogoutIcon
          class="text-gray-500 group-hover:text-gray-700 dark:group-hover:text-gray-300"
        />
        Sign out
      </router-link>
    </div>
    <!-- Dropdown End -->
  </div>
</template>

<script setup lang="ts">
import { ChevronDownIcon, InfoCircleIcon, LogoutIcon, SettingsIcon, UserCircleIcon } from '@/icons'
import { onMounted, onUnmounted, ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { getApiBaseUrl } from '@/services/api'

const router = useRouter()
const dropdownOpen = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)

const userEmail = ref('')
const displayName = ref('Usuário')

const menuItems = [
  { href: '/profile', icon: UserCircleIcon, text: 'Editar perfil' },
  { href: '/profile', icon: SettingsIcon, text: 'Configurações da conta' },
  { href: '/profile', icon: InfoCircleIcon, text: 'Suporte' },
]

const loadUserFromToken = () => {
  const token = localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token')
  if (!token) return

  try {
    const payloadPart = token.split('.')[1]
    const json = JSON.parse(atob(payloadPart))
    // backend envia { id, email, username }
    const username = json.username || ''
    const email = json.email || ''

    displayName.value = username || 'Usuário'
    userEmail.value = email
  } catch (e) {
    console.error('Erro ao decodificar token JWT:', e)
  }
}

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value
}

const closeDropdown = () => {
  dropdownOpen.value = false
}

const signOut = async () => {
  const baseUrl = getApiBaseUrl()

  const accessToken =
    localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token')
  const refreshToken =
    localStorage.getItem('refresh_token') || sessionStorage.getItem('refresh_token')

  try {
    await fetch(`${baseUrl}/api/logout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
      },
      body: JSON.stringify({ refreshToken }),
    })
  } catch (error) {
    console.error('Erro ao fazer logout:', error)
  } finally {
    // limpar tokens locais independentemente do resultado
    localStorage.removeItem('auth_token')
    localStorage.removeItem('refresh_token')
    sessionStorage.removeItem('auth_token')
    sessionStorage.removeItem('refresh_token')

    // marca que a sessão foi encerrada para exibir alerta na tela de login
    sessionStorage.setItem('session_ended', '1')

    closeDropdown()

    await router.push({ path: '/signin', query: { session: 'ended' } })
  }
}

const handleClickOutside = (event: Event) => {
  if (dropdownRef.value && !dropdownRef.value.contains(event.target as Node)) {
    closeDropdown()
  }
}

onMounted(() => {
  loadUserFromToken()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

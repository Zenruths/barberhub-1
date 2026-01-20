import { fileURLToPath, URL } from 'node:url'

import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import { defineConfig } from 'vite'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  // Mantém compatibilidade com GH Pages (basePath /tailadmin-vuejs/),
  // mas permite sobrescrever via variável para Docker/VPS.
  base:
    process.env.VITE_BASE ||
    (process.env.NODE_ENV === 'production' ? '/tailadmin-vuejs/' : '/'),
  plugins: [vue(), vueJsx(), vueDevTools()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: undefined,
      },
    },
  },
})

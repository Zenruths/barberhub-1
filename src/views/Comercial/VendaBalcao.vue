<template>
  <AdminLayout>
    <PageBreadcrumb :pageTitle="currentPageTitle" />
    <div class="p-6 space-y-3">
      <h1 class="text-2xl font-semibold">Venda de Balcão teste 2</h1>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        Módulo Comercial → Venda de Balcão.
      </p>
      <div class="mt-4 rounded-lg border border-dashed border-gray-300 bg-gray-50 p-4 text-sm text-gray-500 dark:border-gray-700 dark:bg-white/5 dark:text-gray-400">
        Esta tela está em branco por enquanto. Aqui você poderá listar e registrar vendas de balcão.
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import AdminLayout from '@/components/layout/AdminLayout.vue';
import PageBreadcrumb from '@/components/common/PageBreadcrumb.vue';

const currentPageTitle = ref('Venda de Balcão');
</script>

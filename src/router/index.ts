import { createRouter, createWebHistory } from 'vue-router'
import ComercialVendaBalcao from "@/views/Comercial/VendaBalcao.vue";
import ComercialOrdemServico from "@/views/Comercial/OrdemServico.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { left: 0, top: 0 }
  },
  routes: [
    {
      path: '/',
      name: 'Ecommerce',
      component: () => import('../views/Ecommerce.vue'),
      alias: '/ecommerce',
      meta: {
        title: 'Painel Principal',
      },
    },
    {
      path: '/calendar',
      name: 'Calendar',
      component: () => import('../views/Others/Calendar.vue'),
      meta: {
        title: 'Calendar',
      },
    },
    {
      path: '/profile',
      name: 'Profile',
      component: () => import('../views/Others/UserProfile.vue'),
      meta: {
        title: 'Profile',
      },
    },
    {
      path: '/form-elements',
      name: 'Form Elements',
      component: () => import('../views/Forms/FormElements.vue'),
      meta: {
        title: 'Form Elements',
      },
    },
    {
      path: '/basic-tables',
      name: 'Basic Tables',
      component: () => import('../views/Tables/BasicTables.vue'),
      meta: {
        title: 'Basic Tables',
      },
    },
    {
      path: '/line-chart',
      name: 'Line Chart',
      component: () => import('../views/Chart/LineChart/LineChart.vue'),
    },
    {
      path: '/bar-chart',
      name: 'Bar Chart',
      component: () => import('../views/Chart/BarChart/BarChart.vue'),
    },
    {
      path: '/alerts',
      name: 'Alerts',
      component: () => import('../views/UiElements/Alerts.vue'),
      meta: {
        title: 'Alerts',
      },
    },
    {
      path: '/avatars',
      name: 'Avatars',
      component: () => import('../views/UiElements/Avatars.vue'),
      meta: {
        title: 'Avatars',
      },
    },
    {
      path: '/badge',
      name: 'Badge',
      component: () => import('../views/UiElements/Badges.vue'),
      meta: {
        title: 'Badge',
      },
    },

    {
      path: '/buttons',
      name: 'Buttons',
      component: () => import('../views/UiElements/Buttons.vue'),
      meta: {
        title: 'Buttons',
      },
    },

    {
      path: '/images',
      name: 'Images',
      component: () => import('../views/UiElements/Images.vue'),
      meta: {
        title: 'Images',
      },
    },
    {
      path: '/videos',
      name: 'Videos',
      component: () => import('../views/UiElements/Videos.vue'),
      meta: {
        title: 'Videos',
      },
    },
    {
      path: '/blank',
      name: 'Blank',
      component: () => import('../views/Pages/BlankPage.vue'),
      meta: {
        title: 'Blank',
      },
    },

    {
      path: '/error-404',
      name: '404 Error',
      component: () => import('../views/Errors/FourZeroFour.vue'),
      meta: {
        title: '404 Error',
      },
    },

    {
      path: '/signin',
      name: 'Signin',
      component: () => import('../views/Auth/Signin.vue'),
      meta: {
        title: 'Acessar Conta',
        public: true,
      },
    },
    {
      path: '/signup',
      name: 'Signup',
      component: () => import('../views/Auth/Signup.vue'),
      meta: {
        title: 'Signup',
        public: true,
      },
    },
    // Módulo Comercial
    {
      path: '/comercial/venda-balcao',
      name: 'ComercialVendaBalcao',
      component: () => import('../views/Comercial/VendaBalcao.vue'),
      meta: {
        title: 'Comercial - Venda de Balcão',
      },
    },
    {
      path: '/comercial/vendas-aberto',
      name: 'ComercialVendasAberto',
      component: () => import('../views/Comercial/VendasAberto.vue'),
      meta: {
        title: 'Comercial - Vendas em Aberto',
      },
    },
    {
      path: '/comercial/historico-vendas',
      name: 'ComercialHistoricoVendas',
      component: () => import('../views/Comercial/HistoricoVendas.vue'),
      meta: {
        title: 'Comercial - Histórico de Vendas',
      },
    },

    // Agendamentos
    {
      path: '/agendamentos/agenda',
      name: 'AgendamentosAgenda',
      component: () => import('../views/Agendamentos/Agenda.vue'),
      meta: {
        title: 'Agendamentos - Agenda',
      },
    },
    {
      path: '/agendamentos/novo',
      name: 'AgendamentosNovo',
      component: () => import('../views/Agendamentos/NovoAgendamento.vue'),
      meta: {
        title: 'Agendamentos - Novo Agendamento',
      },
    },
    {
      path: '/agendamentos/historico',
      name: 'AgendamentosHistorico',
      component: () => import('../views/Agendamentos/Historico.vue'),
      meta: {
        title: 'Agendamentos - Histórico',
      },
    },

    // Serviços
    {
      path: '/servicos',
      name: 'ServicosLista',
      component: () => import('../views/Servicos/Servicos.vue'),
      meta: {
        title: 'Serviços - Lista',
      },
    },
    {
      path: '/servicos/combos',
      name: 'ServicosCombos',
      component: () => import('../views/Servicos/Combos.vue'),
      meta: {
        title: 'Serviços - Combos',
      },
    },
    {
      path: '/servicos/categorias',
      name: 'ServicosCategorias',
      component: () => import('../views/Servicos/Categorias.vue'),
      meta: {
        title: 'Serviços - Categorias',
      },
    },

    // Clientes
    {
      path: '/clientes',
      name: 'ClientesLista',
      component: () => import('../views/Clientes/Clientes.vue'),
      meta: {
        title: 'Clientes - Lista',
      },
    },
    {
      path: '/clientes/fidelidade',
      name: 'ClientesFidelidade',
      component: () => import('../views/Clientes/Fidelidade.vue'),
      meta: {
        title: 'Clientes - Fidelidade',
      },
    },
    {
      path: '/clientes/aniversariantes',
      name: 'ClientesAniversariantes',
      component: () => import('../views/Clientes/Aniversariantes.vue'),
      meta: {
        title: 'Clientes - Aniversariantes',
      },
    },

    // Estoque
    {
      path: '/estoque/produtos',
      name: 'EstoqueProdutos',
      component: () => import('../views/Estoque/Produtos.vue'),
      meta: {
        title: 'Estoque - Produtos',
      },
    },
    {
      path: '/estoque/movimentacoes',
      name: 'EstoqueMovimentacoes',
      component: () => import('../views/Estoque/Movimentacoes.vue'),
      meta: {
        title: 'Estoque - Movimentações',
      },
    },
    {
      path: '/estoque/fornecedores',
      name: 'EstoqueFornecedores',
      component: () => import('../views/Estoque/Fornecedores.vue'),
      meta: {
        title: 'Estoque - Fornecedores',
      },
    },

    // Financeiro
    {
      path: '/financeiro/caixa',
      name: 'FinanceiroCaixa',
      component: () => import('../views/Financeiro/Caixa.vue'),
      meta: {
        title: 'Financeiro - Caixa',
      },
    },
    {
      path: '/financeiro/contas-pagar',
      name: 'FinanceiroContasPagar',
      component: () => import('../views/Financeiro/ContasPagar.vue'),
      meta: {
        title: 'Financeiro - Contas a Pagar',
      },
    },
    {
      path: '/financeiro/contas-receber',
      name: 'FinanceiroContasReceber',
      component: () => import('../views/Financeiro/ContasReceber.vue'),
      meta: {
        title: 'Financeiro - Contas a Receber',
      },
    },
    {
      path: '/financeiro/relatorios',
      name: 'FinanceiroRelatorios',
      component: () => import('../views/Financeiro/Relatorios.vue'),
      meta: {
        title: 'Financeiro - Relatórios',
      },
    },

    // Equipe
    {
      path: '/equipe/barbeiros',
      name: 'EquipeBarbeiros',
      component: () => import('../views/Equipe/Barbeiros.vue'),
      meta: {
        title: 'Equipe - Barbeiros',
      },
    },
    {
      path: '/equipe/novo-barbeiro',
      name: 'EquipeNovoBarbeiro',
      component: () => import('../views/Equipe/NovoBarbeiro.vue'),
      meta: {
        title: 'Equipe - Novo Barbeiro',
      },
    },
    {
      path: '/equipe/comissoes',
      name: 'EquipeComissoes',
      component: () => import('../views/Equipe/Comissoes.vue'),
      meta: {
        title: 'Equipe - Comissões',
      },
    },
    {
      path: '/equipe/escalas',
      name: 'EquipeEscalas',
      component: () => import('../views/Equipe/Escalas.vue'),
      meta: {
        title: 'Equipe - Escalas',
      },
    },

    // Configurações
    {
      path: '/configuracoes',
      name: 'Configuracoes',
      component: () => import('../views/Configuracoes/Index.vue'),
      meta: {
        title: 'Configurações',
      },
    },
  ],
})

export default router

router.beforeEach((to, from, next) => {
  const baseTitle = 'Eden ERP'
  const routeTitle = to.meta && to.meta.title ? String(to.meta.title) : ''
  document.title = routeTitle ? `Homologação - ${routeTitle} | ${baseTitle}` : baseTitle

  const isPublic = to.meta && to.meta.public
  const token =
    localStorage.getItem('auth_token') || sessionStorage.getItem('auth_token')

  if (!isPublic && !token && to.path !== '/signin') {
    return next({ path: '/signin' })
  }

  next()
})

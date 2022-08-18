import { createRouter, createWebHistory } from 'vue-router'
import login from '../views/static/login.view.vue'
import home from '../views/static/home.view.vue'
import notFound from '../views/static/notFound.view.vue'


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: home
    },
    {
      path: '/login',
      name: 'login',
      component: login
    },
    {
      path: '/404',
      name: 'notFound',
      component: notFound
    },
    {
      path: '/wallet',
      name: 'wallet',
      // route level code-splitting
      // this generates a separate chunk (wallet.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/wallet.view.vue')
    },
    {
      path: '/staking',
      name: 'staking',
      component: () => import('../views/staking.view.vue')
    },
    {
      path: '/statistics',
      name: 'statistics',
      component: () => import('../views/statistics.view.vue')
    },
    {
      path: '/strategy',
      name: 'strategy',
      component: () => import('../views/strategy.view.vue')
    },
    {
      path: '/settings',
      name: 'settings',
      component: () => import('../views/settings.view.vue')
    }
  ]
})

export default router

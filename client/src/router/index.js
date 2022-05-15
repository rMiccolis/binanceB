import { createRouter, createWebHistory } from 'vue-router'
import home from '../views/home.view.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: home
    },
    {
      path: '/wallet',
      name: 'wallet',
      // route level code-splitting
      // this generates a separate chunk (wallet.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/wallet.view.vue')
    }
  ]
})

export default router

import { createRouter, createWebHistory } from "vue-router";
import login from "../views/login.view.vue";
import notFound from "../views/static/notFound.view.vue";
import { useMainStore } from "../store/useMainStore";
import axios from "axios";
const baseURL = import.meta.env.VITE_baseURL;

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/login",
            name: "login",
            component: login,
        },
        {
            path: "/bot",
            name: "bot",
            component: import("../views/bot.view.vue"),
        },
        {
            path: "/wallet",
            name: "wallet",
            // route level code-splitting
            // this generates a separate chunk (wallet.[hash].js) for this route
            // which is lazy-loaded when the route is visited.
            component: () => import("../views/wallet.view.vue"),
        },
        {
            path: "/staking",
            name: "staking",
            component: () => import("../views/staking.view.vue"),
        },
        {
            path: "/statistics",
            name: "statistics",
            component: () => import("../views/statistics.view.vue"),
        },
        {
            path: "/strategy",
            name: "strategy",
            component: () => import("../views/strategy.view.vue"),
        },
        {
            path: "/settings",
            name: "settings",
            component: () => import("../views/accountSettings.view.vue"),
        },
        {
            path: "/:pathMatch(.*)*",
            name: "notFound",
            component: notFound,
        },
    ],
});

router.beforeEach(async (to, from) => {
    const mainStore = useMainStore();
    const logged = await mainStore.isLoggedIn()

      if (logged === false && to.name !== 'login') {
        return { name: 'login', params: {isLoggedIn: false} };
      }
});

export default router;

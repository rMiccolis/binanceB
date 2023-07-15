import { createRouter, createWebHistory } from "vue-router";
import login from "../views/login.view.vue";
import home from "../views/home.view.vue";
import notFound from "../views/static/notFound.view.vue";
import axios from "axios";
const baseURL = import.meta.env.VITE_SERVER_URI;

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "home",
            component: home,
        },
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

// router.beforeEach((to, from) => {
//     const mainStore = useMainStore();
//     const logged = mainStore.isUserloggedIn;
//     if (!logged && to.name !== "login") {
//         console.log("sending this", logged);
//         return { name: "login", params: { isLoggedIn: false } };
//     }
// });

export default router;

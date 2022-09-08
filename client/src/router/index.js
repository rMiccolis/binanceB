import { createRouter, createWebHistory } from "vue-router";
import login from "../views/login.view.vue";
import home from "../views/home.view.vue";
import notFound from "../views/static/notFound.view.vue";
import { useMainStore } from "../store/useMainStore";

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/home",
            name: "home",
            component: home,
        },
        {
            path: "/404",
            name: "notFound",
            component: notFound,
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
            component: () => import("../views/settings.view.vue"),
        },
    ],
});

router.beforeEach(async (to, from) => {
    if (
        // make sure the user is authenticated
        !useMainStore.iUserLoggedIn &&
        // ❗️ Avoid an infinite redirect
        to.name !== "home"
    ) {
        // redirect the user to the login page
        return { name: "home" };
    }
});

export default router;

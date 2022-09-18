import { createRouter, createWebHistory } from "vue-router";
import home from "../views/home.view.vue";
import notFound from "../views/static/notFound.view.vue";
import { useMainStore } from "../store/useMainStore";

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "noPath",
            component: home,
        },
        {
            path: "/home",
            name: "home",
            component: home,
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
        {
            path: "/:pathMatch(.*)*",
            name: "notFound",
            component: notFound,
        },
    ],
});

// router.beforeEach(async (to, from, next) => {
//     const mainStore = useMainStore();
//     console.log(mainStore.iUserLoggedIn);
//     if (!mainStore.iUserLoggedIn && to.name != "home" && to.name != "notFound") next({ name: "home" });
//     else next();
// });

export default router;

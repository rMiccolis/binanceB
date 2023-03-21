import { createRouter, createWebHistory } from "vue-router";
<<<<<<< HEAD
import home from "../views/home.view.vue";
import notFound from "../views/static/notFound.view.vue";
import { useMainStore } from "../store/useMainStore";
=======
import login from "../views/login.view.vue";
import notFound from "../views/static/notFound.view.vue";
import { useMainStore } from "../store/useMainStore";
import axios from "axios";
const baseURL = import.meta.env.VITE_SERVER_URI;
>>>>>>> develop

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
<<<<<<< HEAD
            path: "/",
            name: "noPath",
            component: home,
        },
        {
            path: "/home",
            name: "home",
            component: home,
=======
            path: "/login",
            name: "login",
            component: login,
        },
        {
            path: "/bot",
            name: "bot",
            component: import("../views/bot.view.vue"),
>>>>>>> develop
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
<<<<<<< HEAD
            component: () => import("../views/settings.view.vue"),
=======
            component: () => import("../views/accountSettings.view.vue"),
>>>>>>> develop
        },
        {
            path: "/:pathMatch(.*)*",
            name: "notFound",
            component: notFound,
        },
    ],
});

<<<<<<< HEAD
// router.beforeEach(async (to, from, next) => {
//     const mainStore = useMainStore();
//     console.log(mainStore.iUserLoggedIn);
//     if (!mainStore.iUserLoggedIn && to.name != "home" && to.name != "notFound") next({ name: "home" });
//     else next();
// });
=======
router.beforeEach((to, from) => {
    const mainStore = useMainStore();
    const logged = mainStore.isUserloggedIn;
    if (!logged && to.name !== "login") {
        console.log("sending this", logged);
        return { name: "login", params: { isLoggedIn: false } };
    }
});
>>>>>>> develop

export default router;

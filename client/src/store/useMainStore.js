import { defineStore } from "pinia";
import { watch, ref, onMounted } from "vue";
import axios from "axios";
import { useRouter, useRoute } from "vue-router";

// You can name the return value of `defineStore()` anything you want, but it's best to use the name of the store and surround it with `use` and `Store` (e.g. `useUserStore`, `useCartStore`, `useProductStore`)
// the first argument is a unique id of the store across your application
export const useMainStore = defineStore("mainStore", () => {
    const baseURL = import.meta.env.VITE_SERVER_URI;
    const router = useRouter();
    const isUserloggedIn = ref(false);
    const userId = ref(null);
    const session = ref(null);

    const setLoggedIn = async ({ loggedIn: loggedIn, sessionInfo: sessionInfo }) => {
        if (session.refreshTimeoutId) {
            clearTimeout(session.refreshTimeoutId);
        }
        if (loggedIn === true && sessionInfo) {
            session.value = sessionInfo;
            isUserloggedIn.value = true;
            userId.value = sessionInfo.userId;
            let expiryDate = session.value.exp - 10000 - session.value.iat;
            // console.log("issued at:", new Date(session.value.iat).toLocaleString());
            // console.log("expires at:", new Date(session.value.exp).toLocaleString());

            let refreshTimeoutId = setInterval(async () => {
                console.log("you have finished your session time!");
                console.log("trying to refresh token...");
                //TODO TRY TO REFRESH TOKEN
                let response = await axios.get(`${baseURL}auth/refresh`, {
                    withCredentials: true,
                });
                if (response.data.error === false) {
                    isUserloggedIn.value = true;
                    session.value = response.data.sessionInfo;
                    userId.value = response.data.sessionInfo.userId;
                    console.log("Token refreshed, session is still valid!");
                } else {
                    isUserloggedIn.value = false;
                    session.value = null;
                    userId.value = null;
                    console.log("Token NOT refreshed, session is not valid!");
                    router.push({
                        name: "login",
                    });
                }
            }, expiryDate);

            session.value.refreshTimeoutId = refreshTimeoutId;
        } else {
            isUserloggedIn.value = false;
            session.value = false;
            userId.value = null;
            if (router.currentRoute.value.name != "notFound" && router.currentRoute.value.name != "login") {
                router.push({
                    name: "login",
                });
            }
        }
        isUserloggedIn.value = loggedIn;
    };

    const isLoggedIn = async () => {
        if (isUserloggedIn.value === true && Date.now() < session?.value.exp) {
            return true;
        } else if (session.value == null) {
            let response = await axios.get(`${baseURL}auth/isLoggedIn`, {
                withCredentials: true,
            });

            if (response.data?.isLoggedIn === true) {
                await setLoggedIn({
                    loggedIn: true,
                    sessionInfo: response.data.sessionInfo,
                });
                return true;
            } else {
                isUserloggedIn.value = false;
                session.value = false;
                userId.value = null;
                return false;
            }
        } else if (session.value === false) {
            isUserloggedIn.value = false;
            session.value = false;
            userId.value = null;
            return false;
        }
    };

    return { isUserloggedIn, userId, session, setLoggedIn, isLoggedIn };
});

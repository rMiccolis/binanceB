import { defineStore } from "pinia";
import { watch, ref, onMounted } from "vue";
import axios from "axios";
import { useRouter, useRoute } from "vue-router";


// You can name the return value of `defineStore()` anything you want, but it's best to use the name of the store and surround it with `use` and `Store` (e.g. `useUserStore`, `useCartStore`, `useProductStore`)
// the first argument is a unique id of the store across your application
export const useMainStore = defineStore("mainStore", () => {
    const baseURL = import.meta.env.VITE_baseURL;
    const router = useRouter();
    const isUserloggedIn = ref(true);
    const session = ref(null);

    const setLoggedIn = ({ loggedIn: loggedIn, sessionInfo: sessionInfo }) => {
        if (session.refreshTimeoutId) {
            clearTimeout(session.refreshTimeoutId);
          }
        if (loggedIn === true && sessionInfo) {
            session.value = sessionInfo;
            isUserloggedIn.value = true;
            let expiryDate = session.value.exp - 10000 - session.value.iat;
            console.log(session.value.exp - 10000 - session.value.iat);
            console.log(session.value.exp);
            console.log(session.value.iat);

            let refreshTimeoutId = setTimeout(async () => {
                console.log("you have finished your session time!");
                console.log("trying to refresh token...");
                //TODO TRY TO REFRESH TOKEN
                let response = await axios.get(`${baseURL}auth/refresh`, {
                    withCredentials: true,
                });
                if (response.data.error === false) {
                    isUserloggedIn.value = true;
                    session.value = response.data.sessionInfo;
                    console.log("Token refreshed, session is still valid!");
                } else {
                    isUserloggedIn.value = false;
                    session.value = null;
                    console.log("Token NOT refreshed, session is not valid!");
                }
            }, expiryDate);

            session.value.refreshTimeoutId = refreshTimeoutId;
        } else {
            isUserloggedIn.value = false;
            session.value = null;
            if (router.currentRoute.value.name != "notFound" && router.currentRoute.value.name != "login") {
                router.push({
                    name: "login",
                });
            }
        }
        isUserloggedIn.value = loggedIn;
    };

    return { isUserloggedIn, session, setLoggedIn };
});

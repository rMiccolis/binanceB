import { defineStore } from "pinia";
import { watch, ref, onMounted } from "vue";
import axios from "axios";

// You can name the return value of `defineStore()` anything you want, but it's best to use the name of the store and surround it with `use` and `Store` (e.g. `useUserStore`, `useCartStore`, `useProductStore`)
// the first argument is a unique id of the store across your application
export const useMainStore = defineStore("mainStore", () => {
    const isUserloggedIn = ref(false);
    const session = ref({});

    const getIsUserLoggedIn = () => {
        return isUserloggedIn.value;
    };

    const getsession = () => {
      return session.value;
  };

    const setLoggedIn = (isLogged, sessionInfo = null) => {
        isUserloggedIn.value = isLogged;
        if (isLogged === true && sessionInfo) {
            session.value = sessionInfo;
        }
    };

    return { getIsUserLoggedIn, getsession, setLoggedIn };
});

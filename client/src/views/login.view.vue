<template>
  <div>
    <!-- <v-row class="pb-4" justify="center"><h1>Login Page</h1></v-row> -->
    <v-row class="text-center">
      <v-col>
        <!-- <h3>{{ loginHeader }}</h3> -->
        <login-component
            :displayAlert="loginAlert"
            @action="manageAccess"
          ></login-component>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { watch, ref, onMounted } from "vue";
import { useMainStore } from "../store/useMainStore";
import { useRouter, useRoute } from "vue-router";
import axios from "axios";
import LoginComponent from "../components/login.component.vue";

const router = useRouter();
const route = useRoute();
const baseURL = import.meta.env.VITE_SERVER_URI;
const mainStore = useMainStore();
const loginModal = ref(false);
// const loginHeader = ref("Access Page");
let loginAlert = ref(null);

// const changeHeader = (title) => {
//   loginHeader.value = title;
// };

const manageAccess = async (action) => {
  if (action.type === "signin") {
    let response = await axios.post(
      `${baseURL}auth/signin`,
      {
        userId: action.userId.toLowerCase(),
        password: action.password,
        rememberme: action.rememberme
      },
      { withCredentials: true }
    );

    if (response.data.error == false) {
      // console.log("calling setLoggedIn");
      await mainStore.setLoggedIn({
        loggedIn: true,
        sessionInfo: response.data.sessionInfo,
      });
      loginAlert.value = {
        display: true,
        type: "success",
        message: "Successfully signed in!",
      };
      router.push({ name: "home" })
    } else {
      await mainStore.setLoggedIn({ loggedIn: false, sessionInfo: null });
      loginAlert.value = {
        display: true,
        type: "error",
        message: "Username or Password are not correct!",
      };
    }
  } else if (action.type === "signup") {
    let response = await axios.post(
      `${baseURL}auth/signup`,
      {
        userId: action.userId.toLowerCase(),
        password: action.password,
        publicApiKey: action.publicApiKey,
        privateApiKey: action.privateApiKey,
      },
      { withCredentials: true }
    );
  }
};

watch(
  () => mainStore.isUserloggedIn,
  (value) => {
    if (!value) {
      loginModal.value = true;
    } else {
      setTimeout(() => {
        loginModal.value = false;
      }, 1000);
    }
  }
);
</script>

<style>
.b-app-min-height {
  min-height: 75vh;
}

.vertical-align {
  vertical-align: baseline;
}

a {
  color: var(--a-color);
  font-weight: bold;
  text-decoration: none;
}
</style>

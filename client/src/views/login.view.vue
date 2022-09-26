<template>
  <div>
    <!-- <v-row class="pb-4" justify="center"><h1>Login Page</h1></v-row> -->
    <v-row>
      <v-col>
        <modal-component
          v-if="loginModal === true"
          :name="'login'"
          :open="loginModal"
          :persistent="true"
          :scrollable="true"
          @toggle="toggleModal"
        >
          <template v-slot:header>
            <!-- <h3>{{loginHeader}}</h3> -->
            {{ loginHeader }}
          </template>
          <template v-slot:body>
            <login-component
              @changeHeader="changeHeader"
              @loggedIn="useSetLoggedIn"
            ></login-component>
          </template>
        </modal-component>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { watch, ref, onMounted } from "vue";
import { useMainStore } from "../store/useMainStore";
import { useRouter, useRoute } from "vue-router";
import axios from "axios";
import ModalComponent from "../components/modal.component.vue";
import LoginComponent from "../components/login.component.vue";

const router = useRouter();
const route = useRoute();
const baseURL = import.meta.env.VITE_baseURL;
const mainStore = useMainStore();
const loginModal = ref(false);
const loginHeader = ref("Sign in");

const changeHeader = (title) => {
  loginHeader.value = title;
};

const useSetLoggedIn = ({ loggedIn: loggedIn, sessionInfo: sessionInfo }) => {
  console.log("toggle modal");
  mainStore.setLoggedIn({ loggedIn, sessionInfo });
};

const toggleModal = function (modalInfo) {
  // if (modalInfo.value == false && mainStore.isUserloggedIn == false) return;
  console.log("toggle modal");
  if (modalInfo.name && modalInfo.value) {
    loginModal.value = modalInfo.value;
  } else {
    loginModal.value = !loginModal.value;
  }
};

onMounted(() => {
  if (mainStore.isUserloggedIn === true) {
    console.log("loginView: LOGGED");
    loginModal.value = false;
  } else {
    console.log("loginView: not logged");
    loginModal.value = true;
  }
});

watch(
  () => mainStore.isUserloggedIn,
  (value) => {
      if (!value) {
        loginModal.value = true;
      } else {
        loginModal.value = false;
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

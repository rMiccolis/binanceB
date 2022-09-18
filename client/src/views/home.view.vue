<template>
  <div>
    <v-row class="pb-4" justify="center"><h1>Home Page:</h1></v-row>
    <v-row>
      <v-col>
        <modal-component
          v-if="loginModal"
          :name="'login'"
          :open="loginModal"
          :persistent="true"
          @toggle="toggleModal"
        >
          <!-- <template v-slot:header>
            <h3>{{loginHeader}}:</h3>
          </template> -->
          <template v-slot:body>
            <login-component @loggedIn="useSetLoggedIn"></login-component>
          </template>
        </modal-component>
      </v-col>
    </v-row>
    <v-row>
      <p>ciao</p>
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

const useSetLoggedIn = ({ loggedIn: loggedIn, sessionInfo: sessionInfo }) => {
  mainStore.setLoggedIn({ loggedIn, sessionInfo });
};

const toggleModal = function (modalInfo) {
  // if (modalInfo.value == false && mainStore.isUserloggedIn == false) return;
  if (modalInfo.name && modalInfo.value) {
    loginModal.value = modalInfo.value;
  } else {
    loginModal.value = !loginModal.value;
  }
};

onMounted(() => {
  if (mainStore.isUserloggedIn === true) {
    console.log("qui");
    loginModal.value = false;
  } else {
    console.log("quo");
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

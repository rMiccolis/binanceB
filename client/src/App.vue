<template>
  <v-app :theme="darkTheme">
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item>
        <v-list-item-avatar>
          <i class="bi bi-person" style="font-size: 10"></i>
        </v-list-item-avatar>

        <v-list-item-content>
          <v-list-item-title class="ml-5">TestAccount</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-divider class="mb-1"></v-divider>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'home', params: { userId: 'test' } }"
              >Home</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><a @click.stop="toggleModal({ name: 'login' })"
              >Login</a
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'strategy', params: { userId: 'test' } }"
              >Strategy</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link
              :to="{ name: 'statistics', params: { userId: 'test' } }"
              >Statistics</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'wallet', params: { userId: 'test' } }"
              >Wallet</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'staking', params: { userId: 'test' } }"
              >Staking</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'settings', params: { userId: 'test' } }"
              >Settings</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>

      <template v-slot:append>
        <div class="pa-2">
          <v-btn @click="logout()" block variant="outlined" color="red">
            Logout
          </v-btn>
        </div>
      </template>
    </v-navigation-drawer>
    <!-- </v-sheet> -->
    <v-toolbar elevation="2">
      <v-row align="center" justify="space-between">
        <v-col class="text-left">
          <v-btn color="blue" @click.stop="openDrawer()">
            <!-- <i class="bi bi-list"></i>  -->
            <v-icon size="40" color="blue darken-2"> mdi-menu </v-icon>
          </v-btn>
        </v-col>

        <v-col class="text-right">
          <v-btn
            @click="changeTheme()"
            class="ma-2"
            :icon="themeIcon"
            :color="themeColor"
          ></v-btn>
        </v-col>
      </v-row>
    </v-toolbar>

    <modal-component
      v-if="loginModal"
      :name="'login'"
      :open="loginModal"
      :persistent="true"
      @toggle="toggleModal"
    >
      <template v-slot:header>Login:</template>
      <template v-slot:body>
        <login-component @loggedIn="mainStore.setLoggedIn()"></login-component>
      </template>
    </modal-component>

    <v-main>
      <v-container app fluid>
        <router-view class="pl-5"></router-view>
      </v-container>
    </v-main>
    <v-footer app
      >User: <span class="text-blue ms-1 me-2">Bob617 </span> Bot state:
      <span class="text-success ms-1"> Running!</span>
    </v-footer>
  </v-app>
</template>

<script setup>
import { watch, ref, onMounted, reactive } from "vue";
import { useMainStore } from "./store/useMainStore";
import axios from "axios";
import ModalComponent from "./components/modal.component.vue";
import LoginComponent from "./components/login.component.vue";

const drawer = ref(false);
const mainStore = useMainStore();
const darkTheme = ref("dark");
const themeColor = ref("blue");
const themeIcon = ref("bi bi-brightness-high");
const root = ref(document.querySelector(":root"));
const loginModal = ref(false);
const logout = () => {
  alert("sara è scema");
};

const toggleModal = function (modalInfo) {
  if (modalInfo.value == false && mainStore.getIsUserLoggedIn() == false) return;
  if (modalInfo.name && modalInfo.value) {
    loginModal.value = modalInfo.value;
  } else {
    loginModal.value = !loginModal.value;
  }
};

const isLoggedIn = async function () {
  let response = await axios.get("http://localhost:3000/auth/isLoggedIn", {
    withCredentials: true,
  });

  if (response.data.isLoggedIn === true) {
    mainStore.setLoggedIn(true, response.data.sessionInfo);
  } else {
    mainStore.setLoggedIn(false);
  }
};

onMounted(async () => {
  await isLoggedIn();
  if (mainStore.getIsUserLoggedIn() === true) {
    loginModal.value = false;
    let expiryDate = mainStore.session.exp - mainStore.session.iat;
    setTimeout(() => {
      console.log("you have finished your session time!");
    }, expiryDate);
    return;
  }
  loginModal.value = true;
});

watch(
  () => mainStore.getIsUserLoggedIn(),
  (value) => {
    console.log("changed to =>", value);
    if (value == true) {
      loginModal.value = false;
    }
  }
);

watch(
  () => darkTheme.value,
  (value) => {
    if (value == "dark") {
      console.log("is dark");
      root.value.style.setProperty("--a-color", "white");
    } else {
      console.log("is light");
      root.value.style.setProperty("--a-color", "black");
    }
  }
);

const changeTheme = () => {
  if (darkTheme.value == "dark") {
    darkTheme.value = "light";
    themeColor.value = "blue";
    themeIcon.value = "bi bi-moon";
  } else {
    darkTheme.value = "dark";
    themeColor.value = "blue";
    themeIcon.value = "bi bi-brightness-high";
  }
};

const openDrawer = () => {
  drawer.value = !drawer.value;
};
</script>

<style>
.vertical-align {
  vertical-align: baseline;
}

a {
  color: var(--a-color);
  font-weight: bold;
  text-decoration: none;
}
</style>

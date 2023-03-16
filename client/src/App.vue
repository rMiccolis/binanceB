<template>
  <v-app :theme="darkTheme">
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item @click="toUserPage()">
        <v-list-item-avatar>
          <i class="bi bi-person" style="font-size: 10"></i>
        </v-list-item-avatar>

        <v-list-item-content>
          <v-list-item-title class="ml-5"
            ><span class="text-capitalize">{{
              mainStore.userId
            }}</span></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>

      <v-divider class="mb-1"></v-divider>
      <div v-if="mainStore.isUserloggedIn">
        <v-list-item>
          <v-list-item-content>
            <v-list-item-title
              ><router-link
                :to="{ name: 'statistics'}"
                >Statistics</router-link
              ></v-list-item-title
            >
          </v-list-item-content>
        </v-list-item>

        <v-list-item>
          <v-list-item-content>
            <v-list-item-title
              ><router-link :to="{ name: 'wallet'}"
                >Wallet</router-link
              ></v-list-item-title
            >
          </v-list-item-content>
        </v-list-item>

        <v-list-item>
          <v-list-item-content>
            <v-list-item-title
              ><router-link
                :to="{ name: 'staking'}"
                >Staking</router-link
              ></v-list-item-title
            >
          </v-list-item-content>
        </v-list-item>

        <v-list-item>
          <v-list-item-content>
            <v-list-item-title
              ><router-link
                :to="{ name: 'settings'}"
                >Settings</router-link
              ></v-list-item-title
            >
          </v-list-item-content>
        </v-list-item>
      </div>
      <v-list-item v-else>
        <v-list-item-content>
          <v-list-item-title
            ><router-link
              v-if="route.name != 'login'"
              :to="{ name: 'login'}"
              >Login</router-link
            >
            <a v-else @click="router.go()">Login</a>
          </v-list-item-title>
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
    <v-toolbar elevation="2" :color="whiteBlackToolbar">
      <v-row align="center" justify="space-between">
        <v-col class="text-left">
          <v-btn color="blue" @click.stop="toggleDrawer()">
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

    <v-main app class="b-app-min-height">
      <v-container app>
        <router-view ></router-view>
      </v-container>
    </v-main>

    <!-- <v-footer app>
      User: <span class="text-blue ms-1 me-2">Bob617 </span> Bot state:
      <span class="text-success ms-1"> Running!</span>
    </v-footer> -->
    <v-bottom-navigation app :bg-color="whiteBlackFooter" class="mt-1">
      <footer-menu-component :menuItems="menu"></footer-menu-component>
    </v-bottom-navigation>
  </v-app>
</template>

<script setup>
import { watch, ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter, useRoute } from "vue-router";
import { useMainStore } from "./store/useMainStore";
import axios from "axios";
import ModalComponent from "./components/modal.component.vue";
import LoginComponent from "./components/login.component.vue";
import FooterMenuComponent from "./components/footerMenu.component.vue";

const router = useRouter();
const route = useRoute();
const baseURL = process.env.SERVER_URI;
const drawer = ref(false);
const mainStore = useMainStore();
const darkTheme = ref("dark");
// const whiteBlackColor = ref("rgb(18,18,18)");
const whiteBlackColor = ref("rgba(20, 23, 23, 0.678)");
const whiteBlackToolbar = ref("rgba(20, 23, 23, 0.678)");
const whiteBlackFooter = ref("rgba(0, 23, 23,");
const themeColor = ref("blue");
const themeIcon = ref("bi bi-brightness-high");
const root = ref(document.querySelector(":root"));
const userId = ref(null);
const menu = ref([
  {
    name: "Account",
    action: (menuItem) => {},
    icon: "mdi-account",
  },
  {
    name: "Bot",
    action: (menuItem) => router.push({ name: "bot" }),
    icon: "mdi-hexagon-slice-6",
  },
  // {
  //   name: 'Refresh',
  //   action: (menuItem) => {
  //
  //   },
  //   icon: "mdi-autorenew"
  // },
  {
    name: "Strategies",
    action: (menuItem) => router.push({ name: "strategy" }),
    icon: "mdi-cog",
  },
]);

const toUserPage = () => {
  if (mainStore.userId != null) {
    console.log("goto account");
    router.push({ name: "account" });
  } else {
    console.log("goto login");
    if (route.name != "login") {
      router.push({ name: "login" });
    } else {
      router.go();
    }
  }
};

const logout = async () => {
  console.log(baseURL);
  let response = await axios.get(`${baseURL}auth/logout`, {
    withCredentials: true,
  });
  toggleDrawer();

  setTimeout(() => {
    mainStore.setLoggedIn({ loggedIn: false, sessioInfo: null });
  }, 500);
};

const isLoggedIn = async function () {
  let response = await axios.get(`${baseURL}auth/isLoggedIn`, {
    withCredentials: true,
  });

  if (response.data.isLoggedIn === true) {
    mainStore.setLoggedIn({
      loggedIn: true,
      sessioInfo: response.data.sessionInfo,
    });
  } else {
    mainStore.setLoggedIn({ loggedIn: false, sessioInfo: null });
  }
};

onMounted(async () => {
  // await isLoggedIn();
  mainStore.isLoggedIn();
  let test = import.meta.env
  console.log(baseURL);
  console.log(test);
  console.log(process.env);
});

watch(
  () => darkTheme.value,
  (value) => {
    if (value == "dark") {
      console.log("is dark");
      whiteBlackColor.value = "rgba(20, 23, 23, 0.678)";
      whiteBlackToolbar.value = "rgba(20, 23, 23, 0.678)";
      whiteBlackFooter.value = "rgb(20, 23, 23)";
      root.value.style.setProperty("--a-color", "white");
    } else {
      console.log("is light");
      // whiteBlackColor.value = "rgb(255,255,255)";
      whiteBlackColor.value = "rgba(220,220,220, 0.6)";
      whiteBlackToolbar.value = "rgba(190,190,190, 0.2)";
      whiteBlackFooter.value = "white";
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

const toggleDrawer = () => {
  drawer.value = !drawer.value;
};

onBeforeUnmount(() => {
  router.push({ name: "login" });
})
</script>

<style>

.a {
  color: rgba(20, 19, 19, 0.678);
}

.b-app-min-height {
  min-height: 80vh !important;
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

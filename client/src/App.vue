<template>
  <v-app :theme="darkTheme">
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item @click="changePage('account')">
        <v-row>
          <v-col cols="1">
            <v-list-item-avatar>
              <i class="bi bi-person" style="font-size: 10"></i>
            </v-list-item-avatar>
          </v-col>
          <v-col cols="auto">
            <v-list-item-content>
              <span class="text-capitalize font-weight-bold">{{ mainStore.userId }}</span>
            </v-list-item-content>
          </v-col>
        </v-row>
      </v-list-item>

      <v-divider class="mb-1"></v-divider>
      <div v-if="mainStore.isUserloggedIn">
        <v-list-item @click="changePage('home')">
          <v-list-item-content>
            <span class="text-capitalize font-weight-bold">home</span>
          </v-list-item-content>
        </v-list-item>

        <v-list-item @click="changePage('statistics')">
          <v-list-item-content>
            <span class="text-capitalize font-weight-bold">statistics</span>
          </v-list-item-content>
        </v-list-item>

        <v-list-item @click="changePage('wallet')">
          <v-list-item-content>
            <span class="text-capitalize font-weight-bold">wallet</span>
          </v-list-item-content>
        </v-list-item>

        <v-list-item @click="changePage('staking')">
          <v-list-item-content>
            <span class="text-capitalize font-weight-bold">staking</span>
          </v-list-item-content>
        </v-list-item>

        <v-list-item @click="changePage('settings')">
          <v-list-item-content>
            <span class="text-capitalize font-weight-bold">settings</span>
          </v-list-item-content>
        </v-list-item>
      </div>
      <v-list-item v-else>
        <v-list-item-content>
          <v-list-item-title
            ><router-link v-if="route.name != 'login'" :to="{ name: 'login' }"
              >Login</router-link
            >
            <a v-else @click="toggleDrawer()">Login</a>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <template v-slot:append>
        <div class="pa-2">
          <v-btn
            @click="logout()"
            block
            variant="outlined"
            color="red"
            :disabled="!mainStore.isUserloggedIn"
          >
            Logout
          </v-btn>
        </div>
      </template>
    </v-navigation-drawer>
    <v-toolbar elevation="2" :color="toolbarBGColor">
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
      <v-container app class="pt-2">
        <router-view></router-view>
      </v-container>
    </v-main>

    <!-- <v-footer app>
      User: <span class="text-blue ms-1 me-2">Bob617 </span> Bot state:
      <span class="text-success ms-1"> Running!</span>
    </v-footer> -->
    <v-bottom-navigation v-if="mainStore.isUserloggedIn === true" app :bg-color="footerBGColor" class="mt-1">
      <footer-menu-component :menuItems="menu"></footer-menu-component>
    </v-bottom-navigation>
  </v-app>
</template>

<script setup>
import { watch, ref, onMounted, onBeforeMount } from "vue";
import { useRouter, useRoute } from "vue-router";
import { useMainStore } from "./store/useMainStore";
import axios from "axios";
import FooterMenuComponent from "./components/footerMenu.component.vue";
import css from "./assets/base.css"

const router = useRouter();
const route = useRoute();
const baseURL = import.meta.env.VITE_SERVER_URI;
const drawer = ref(false);
const mainStore = useMainStore();
const darkTheme = ref("dark");
// const whiteBlackColor = ref("rgb(18,18,18)");
// const whiteBlackColor = ref("rgba(20, 23, 23, 0.678)");
const toolbarBGColor = ref("rgba(20, 20, 20, 0.678)");
const footerBGColor = ref("rgba(20, 20, 20, 0.98)");
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

const changePage = (pageName = "home", params = null) => {
  if (mainStore.isUserloggedIn === true) {
    router.push({ name: pageName });
  } else {
    router.push({ name: "login" });
  }
};

const logout = async () => {
  console.log(baseURL);
  let response = await axios.get(`${baseURL}auth/logout`, {
    withCredentials: true,
  });
  toggleDrawer();

  setTimeout(async () => {
    await mainStore.setLoggedIn({ loggedIn: false, sessioInfo: null });
    router.push({ name: "login" });
  }, 500);
};

onMounted(async () => {
  let environment_vars = import.meta.env;
  console.log(environment_vars, "import meta env");
});

watch(
  () => darkTheme.value,
  (value) => {
    if (value == "dark") {
      // console.log("is dark");
      // whiteBlackColor.value = "rgba(200, 203, 230, 0.678)";
      toolbarBGColor.value = "rgba(20, 20, 20, 0.678)";
      footerBGColor.value = "rgba(20, 20, 20, 0.678)";
      root.value.style.setProperty("--a-color", "white");
      root.value.style.setProperty("--bg-app-icon", "black");
      root.value.style.setProperty("--app-icon-text-color", "grey");
    } else {
      // console.log("is light");
      // whiteBlackColor.value = "rgb(255,255,255)";
      // whiteBlackColor.value = "rgba(220,220,220, 0.6)";
      toolbarBGColor.value = "rgba(220,220,220, 0.3)";
      footerBGColor.value = "rgba(255, 255, 255, 0.85)";
      root.value.style.setProperty("--a-color", "black");
      root.value.style.setProperty("--bg-app-icon", "white");
      root.value.style.setProperty("--app-icon-text-color", "rgb(236, 102, 40)");
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

onBeforeMount(async () => {
  // const mainStore = useMainStore();
  // const logged = await mainStore.isLoggedIn();
  // if (!logged) {
  //   router.push({ name: "login" });
  // }
});
</script>

<style>
.a {
  color: rgba(20, 19, 19, 0.678);
}

.cursor-pointer {
  cursor: pointer;
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

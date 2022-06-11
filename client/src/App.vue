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
            ><router-link :to="{ name: 'login', params: { userId: 'test' } }"
              >Login</router-link
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
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'account', params: { userId: 'test' } }"
              >Account</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <template v-slot:append>
        <div class="pa-2">
          <v-btn block variant="outlined" color="red"> Logout </v-btn>
        </div>
      </template>
    </v-navigation-drawer>
    <!-- </v-sheet> -->
    <v-toolbar elevation="2">
      <v-btn color="blue" @click.stop="openDrawer()">
        <!-- <i class="bi bi-list"></i>  -->
        <v-icon size="40" color="blue darken-2"> mdi-menu </v-icon>
      </v-btn>
      <v-row justify="end">
        <v-btn
          @click="changeTheme()"
          class="ma-2"
          :icon="themeIcon"
          :color="themeColor"
        ></v-btn>
      </v-row>
    </v-toolbar>

    <v-main>
      <v-container app fluid>
        <router-view></router-view>
      </v-container>
    </v-main>
    <v-footer app
      >User: <span class="text-blue ms-1 me-2">Bob617 </span> Bot state:
      <span class="text-success ms-1"> Running!</span>
    </v-footer>
  </v-app>
</template>

<script setup>
import { watch, ref, onMounted } from "vue";
import axios from "axios";
let drawer = ref(false);

let darkTheme = ref("light");
let themeColor = ref("blue");
let themeIcon = ref("bi bi-brightness-high");
let root = ref(document.querySelector(":root"));

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

let changeTheme = () => {
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

let openDrawer = () => {
  drawer.value = !drawer.value;
};
</script>

<style>
a {
  color: var(--a-color);
  font-weight: bold;
  text-decoration: none;
}
</style>

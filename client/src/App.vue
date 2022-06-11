<template>
  <v-app theme="dark">
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item>
        <v-list-item-avatar>
          <i class="bi bi-person" style="font-size: 10"></i>
        </v-list-item-avatar>

        <v-list-item-content>
          <v-list-item-title class="ml-5">TestAccount</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-divider></v-divider>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'home', params: { userId: 'test' } }"
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
            ><router-link :to="{ name: 'wallet', params: { userId: 'test' } }"
              >Staking</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'wallet', params: { userId: 'test' } }"
              >Bot Settings</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title
            ><router-link :to="{ name: 'wallet', params: { userId: 'test' } }"
              >Account</router-link
            ></v-list-item-title
          >
        </v-list-item-content>
      </v-list-item>
      <template v-slot:append>
        <div class="pa-2">
          <v-btn block> Logout </v-btn>
        </div>
      </template>
    </v-navigation-drawer>
    <!-- </v-sheet> -->
    <v-toolbar elevation="2">
      <v-btn color="blue" outlined dark @click.stop="openDrawer()">
        <!-- <i class="bi bi-list"></i>  -->
        <v-icon size="40" color="blue darken-2"> mdi-menu </v-icon>
      </v-btn></v-toolbar
    >

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
import sidebar from "@/components/sidebar.vue";
import { onBeforeMount, ref } from "vue";
import axios from "axios";
let drawer = ref(false);

let openDrawer = () => {
  drawer.value = !drawer.value;
};
</script>

<style>
a {
  color: white;
}
</style>

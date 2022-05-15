<template>
  <v-app>
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item>
        <v-list-item-avatar>
          <i class="bi bi-person" style="font-size: 40px"></i>
        </v-list-item-avatar>

        <v-list-item-content>
          <v-list-item-title class="ml-5">John Leider</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-divider></v-divider>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title><router-link :to="{ name: 'home', params: { userId: 'test' }}">Home</router-link></v-list-item-title>
        </v-list-item-content>
      </v-list-item>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title><router-link :to="{ name: 'wallet', params: { userId: 'test' }}">Wallet</router-link></v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-navigation-drawer>
    <!-- </v-sheet> -->
    <v-toolbar color="white" elevation="2"
      ><v-btn color="pink" dark @click.stop="openDrawer()">
        <i class="bi bi-list"></i> </v-btn
    ></v-toolbar>

    <v-main>
      <v-container app fluid>
        <router-view></router-view>
      </v-container>
    </v-main>
    <v-footer app> footer </v-footer>
  </v-app>
</template>

<script setup>
import sidebar from "@/components/sidebar.vue";
import { ref } from "vue";
let drawer = ref(false);

let openDrawer = () => {
  drawer.value = !drawer.value;
};
</script>

<style>
</style>

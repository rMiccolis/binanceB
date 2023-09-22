<template>
  <div>
    <v-row class="pb-4" justify="start">
      <v-col><h1>Home Page:</h1></v-col>
      </v-row>
    <v-row>
      <v-col>
        This is the home page!
        <p>You are logged in as: <span class="text-capitalize font-weight-bold">{{ mainStore.userId }}</span></p>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { watch, ref, onMounted } from "vue";
import { useMainStore } from "../store/useMainStore";
import axios from "axios";

const baseURL = import.meta.env.VITE_baseURL;

const mainStore = useMainStore();
const loginModal = ref(false);

onMounted(async () => {
});

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

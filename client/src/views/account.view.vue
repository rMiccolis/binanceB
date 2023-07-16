<template>
    <div>
      <v-row class="pb-4" justify="start">
        <v-col><h1>Account Page:</h1></v-col>
        </v-row>
      <v-row>
        <v-col>
          This is your account page!
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
  
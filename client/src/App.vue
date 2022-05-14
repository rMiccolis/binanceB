<script setup>
import { RouterLink, RouterView } from "vue-router";
import sidebar from "@/components/sidebar.vue";
import { ref, watch } from "vue";

let open = ref(false);

function openSidebar() {
  open.value = true;
}

function closeSidebar() {
  open.value = false
}

</script>

<template>
  <header>
  <!-- <RouterLink to="/">Home</RouterLink> -->
  </header>
  <sidebar :open="open" @close="closeSidebar" @open="openSidebar"/>
  <button class="btn btn-info" @click="openSidebar()">ciao APP.VUE</button>

  <RouterView />
</template>

<style>
/* @import '@/assets/base.css'; */
</style>

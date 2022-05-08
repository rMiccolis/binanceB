<script setup>
import { RouterLink, RouterView } from 'vue-router'
import sidebar from '@/components/sidebar.vue'
</script>

<template>
  <header>
    <!-- <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="125" height="125" /> -->

    <div class="wrapper">
      <!-- <HelloWorld msg="You did it!" /> -->
      <!-- <sidebar :open="true" /> -->
      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/about">About</RouterLink>
      </nav>
      ciao
    </div>
  </header>

  <RouterView />
</template>

<style>
/* @import '@/assets/base.css'; */


</style>

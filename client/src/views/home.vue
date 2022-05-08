<script setup>
import { ref, watch } from 'vue'
import sidebar from '../components/sidebar.vue'

let open = ref(false)

function ciao() {
  open.value = !open.value;
}
</script>

<template>
  <div>
    <button class="btn btn-info ciao" @click="ciao();">ciao</button>
    <sidebar :open="open" />
  </div>
</template>

<style scoped>
.ciao {
  position: absolute;
  right: 150px;
  /* bottom: 10000px; */
  /* margin-right: 0; */
  /* margin-left: 1000px; */
}
</style>
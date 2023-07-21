
<template>
  <div class="d-flex w-100">
    <!-- <v-row> -->
    <div
      class="b-menu-item w-100 text-center"
      v-for="(menu, index) in menuItems"
      :key="index"
    >
      <!-- <v-col class="p-10"> -->
      <v-btn class="mt-2 mb-2 btn-hover" width="100%" height="fit-content" size="x-small" @click="menu.action(menu)">
        <v-icon x-large class="b-icon-size">{{menu.icon}}</v-icon>
        <span class="b-text-newline">{{ menu.name }}</span>
      </v-btn>
    </div>
  </div>
</template>

<script setup>
import { onMounted, watch, ref } from "vue";
import _ from "lodash";
const props = defineProps({
  menuItems: { type: Array, default: [], required: true }
});

// const emit = defineEmits(["toggle"]);

// watch(
//   () => props.open,
//   (value) => {
//     modalState.value = value;
//   }
// );
</script>

<style scoped>
  .b-icon-size {
    font-size: 2.5em;
  }
.b-text-newline {
  white-space: pre-wrap !important;
  font-size: 0.7em;
}

.btn-hover:hover {
  background-color: var(--icon-hover-color);
}

.b-menu-item {
  display: inline;
  width: 25%;
  color: var(--bottom-nav-buttons-color);
  /* border-right: 1px solid rgba(0, 162, 255, 0.245); */
  /* border-top: 1px solid rgba(0, 162, 255, 0.475); */
  }
</style>
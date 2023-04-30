<template>
  <div class="text-center">
    <v-row class="pb-4 d-flex">
      <div class="b-bg-blue text-center">
        <h1>{{props.headerTitle}}</h1>
      </div>
    </v-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";

const props = defineProps({
  headerTitle: { type: String, default: "", required: false }
});
</script>

<style scoped>
.b-bg-blue {
  position: relative;
  height: 100%;
  width: 100%;
  background-color: rgba(50, 143, 224, 0.958);
}
</style>

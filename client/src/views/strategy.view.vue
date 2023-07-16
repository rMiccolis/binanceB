<template>
  <div class="text-center">
    <header-component header-title="Strategy"></header-component>
    <v-row class="pb-4" justify-content="center">
      <v-col>
        <v-text-field v-model="coin" label="Coin"></v-text-field>
      </v-col>
      <v-col>
        <v-text-field
          v-model="baseAsset"
          label="Base Asset"
          required
        ></v-text-field>
      </v-col>
    </v-row>
    <v-btn :disabled="!valid" color="success" class="mr-4"> Validate </v-btn>

    <div>
      <v-icon :icon="icon"></v-icon>
    </div>
  </div>
</template>

<script setup>
import axios from "axios";
import { ref, onMounted, watch, onUnmounted } from "vue";
import HeaderComponent from "../components/header.component.vue";
let valid = ref(true);
let baseAsset = ref("");
let icon = ref("mdi-account");
onMounted(async () => {
  let res = await axios.get(
    "https://cryptoflash-icons-api.herokuapp.com/svg/icon/eth"
  );
  // console.log(res);
  icon.value = res.data;
});
</script>

<style scoped>
.b-bg-blue {
  position: relative;
  height: 100%;
  width: 100%;
  background-color: rgba(108, 174, 232, 0.558);
}
</style>

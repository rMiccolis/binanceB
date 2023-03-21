<template>
<<<<<<< HEAD
  <div>
    <v-container>
      <v-row class="pb-4" justify="center">
        <h1>Strategies:</h1>
      </v-row>
      <v-row class="pb-4" justify="center">
        <v-form ref="form" v-model="valid" lazy-validation>
          <v-col cols="6">
            <v-text-field v-model="coin" label="Coin" required></v-text-field>
          </v-col>
          <v-col cols="6">
            <v-text-field v-model="baseAsset" label="Base Asset" required></v-text-field>
          </v-col>

          <v-btn :disabled="!valid" color="success" class="mr-4">
            Validate
          </v-btn>
        </v-form>
      </v-row>
    </v-container>
=======
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
>>>>>>> develop
  </div>
</template>

<script setup>
<<<<<<< HEAD
import { ref, onMounted, watch } from "vue";

let valid = ref(false)
let baseAsset = ref(false)
let coin = ref(false)
</script>

<style scoped>
=======
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
  console.log(res);
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
>>>>>>> develop
</style>

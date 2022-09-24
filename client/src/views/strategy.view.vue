<template>
  <div>
    <v-row class="pb-4 d-flex" justify="center">
      <div class="b-bg-blue">
        <h1>Strategies:</h1>
      </div>
    </v-row>
    <v-row class="pb-4" justify="center">
      <v-form ref="form" v-model="valid" lazy-validation>
        <v-col cols="6">
          <v-text-field v-model="coin" label="Coin" required></v-text-field>
        </v-col>
        <v-col cols="6">
          <v-text-field
            v-model="baseAsset"
            label="Base Asset"
            required
          ></v-text-field>
        </v-col>

        <v-btn :disabled="!valid" color="success" class="mr-4">
          Validate
        </v-btn>
      </v-form>
    </v-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";

let valid = ref(false);
let baseAsset = ref(false);
let coin = ref(false);
</script>

<style scoped>
.b-bg-blue {
  position: relative;
  height: 100%;
  width: 100%;
  background-color: rgba(108, 174, 232, 0.558);
}
</style>

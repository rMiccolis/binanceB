<template>
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
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";

let valid = ref(false)
let baseAsset = ref(false)
let coin = ref(false)
</script>

<style scoped>
</style>

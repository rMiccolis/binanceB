<script setup>
import { ref, watch } from "vue";
</script>

<template>
  <div>
    <v-row no-gutters><h1>THIS IS THE WALLET PAGE</h1></v-row>
    <v-row no-gutters>
      <v-col cols="4">
        <v-card class="pa-2" outlined tile>
          <v-card-title>
            <v-col cols="9">Wallet Info</v-col>
            <v-col
              ><v-btn class="mx-2" fab dark small rounded color="blue">
               <i class="bi bi-arrow-clockwise"></i>
              </v-btn></v-col
            ></v-card-title
          >
          <v-divider></v-divider>
          <v-row class="pa-2" no-gutters>Wallet content</v-row>
        </v-card>
      </v-col>
      <v-col cols="4">
        <v-card class="pa-2" outlined tile> 2 of three columns </v-card>
      </v-col>
      <v-col cols="4">
        <v-card class="pa-2" outlined tile> 3 of three columns </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<style scoped>
</style>
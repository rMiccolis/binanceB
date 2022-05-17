
<template>
  <div>
    <v-row no-gutters><h1>THIS IS THE WALLET PAGE</h1></v-row>
    <v-row no-gutters>
      <v-col>
        <v-card class="pa-2" outlined tile>
          <v-card-title>
            <v-col cols="9">Wallet Info</v-col>
            <v-col
              ><v-btn class="mx-2" @click="getAccountInfo()" fab dark small rounded color="blue">
               <i class="bi bi-arrow-clockwise"></i>
              </v-btn></v-col
            ></v-card-title
          >
          <v-divider></v-divider>
          <v-row class="pa-2" no-gutters>
            <v-list-item>
              <v-list-item-content>
                <v-list-item-title><h4>data: </h4></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
            {{accountInfo}}
          </v-row>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from 'axios';

let accountInfo = ref(null);
let userId = 'test'

let getAccountInfo = async () => {
  accountInfo.value = await axios({
    method: "get",
    url: "http://localhost:3000/api/account",
    params: {userId} 
  });
}
</script>

<style scoped>
</style>
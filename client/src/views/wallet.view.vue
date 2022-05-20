
<template>
  <div>
    <v-row no-gutters><h1>THIS IS THE WALLET PAGE</h1></v-row>
    <v-row no-gutters>
      <v-col>
        <v-card class="pa-2" outlined tile>
          <v-card-title>
            <v-col cols="9">Wallet Info</v-col>
            <v-col
              ><v-btn
                class="mx-2"
                @click="getAccountInfo()"
                fab
                dark
                small
                rounded
                color="blue"
              >
                <i class="bi bi-arrow-clockwise"></i> </v-btn></v-col
          ></v-card-title>
          <v-divider></v-divider>
          <v-row class="pa-2" no-gutters>
            <v-col cols="12">
              <h2>Data:</h2>
            </v-col>
            <div v-for="(item, key) in accountInfo">
              <v-list-item>
                <v-list-item-content>
                  <v-list-item-title>
                    <h4>{{ key }}:</h4>
                  </v-list-item-title>
                  <v-list-item-subtitle>{{
                    item
                  }}</v-list-item-subtitle>                
                </v-list-item-content>
              </v-list-item>
            </div>
          </v-row>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from "axios";

let accountInfo = ref(null);
let userId = "test";

let getAccountInfo = async () => {
  // accountInfo.value = (
  //   await axios({
  //     method: "get",
  //     url: "http://localhost:3000/api/account",
  //     params: { userId },
  //   })
  // ).data;
  accountInfo.value = {"makerCommission":0,"takerCommission":0,"buyerCommission":0,"sellerCommission":0,"canTrade":true,"canWithdraw":false,"canDeposit":false,"updateTime":1652523293213,"accountType":"SPOT","balances":[{"asset":"BNB","free":"1000.70000000","locked":"0.00000000"},{"asset":"BTC","free":"1.00000000","locked":"0.00000000"},{"asset":"BUSD","free":"10000.00000000","locked":"0.00000000"},{"asset":"ETH","free":"100.00000000","locked":"0.00000000"},{"asset":"LTC","free":"500.00000000","locked":"0.00000000"},{"asset":"TRX","free":"500000.00000000","locked":"0.00000000"},{"asset":"USDT","free":"9800.60500000","locked":"0.00000000"},{"asset":"XRP","free":"50000.00000000","locked":"0.00000000"}],"permissions":["SPOT"]}
};
</script>

<style scoped>
</style>
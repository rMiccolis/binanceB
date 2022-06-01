
<template>
  <div>
    <v-row no-gutters><h1>THIS IS THE WALLET PAGE</h1></v-row>
    <v-row no-gutters>
      <v-col>
        <v-card class="pa-2" outlined tile>
          <v-card-title>
            <v-col cols="9">Wallet Info:</v-col>
          </v-card-title>

          <v-divider></v-divider>
          <v-row class="pa-2" no-gutters>
            <v-expansion-panels>
              <v-expansion-panel>
                <v-expansion-panel-title @click="getAccountInfo()">
                  Wallet Info:
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                  <v-row class="pa-2" no-gutters>
                    <div v-if="accountInfo">
                      <div v-for="(item, key) in accountInfo" :key="key">
                        <v-col>
                          <v-list-item v-if="typeof item != 'object'">
                            <v-list-item-content>
                              <v-list-item-title>
                                <h4>{{ key }}:</h4>
                              </v-list-item-title>
                              <v-list-item-subtitle>{{
                                item
                              }}</v-list-item-subtitle>
                            </v-list-item-content>
                          </v-list-item>
                        </v-col>
                      </div>
                    </div>
                    <div v-else>Loading...</div>
                  </v-row>
                </v-expansion-panel-text>
              </v-expansion-panel>
            </v-expansion-panels>
          </v-row>

          <v-row class="pa-2" no-gutters>
            <v-expansion-panels>
              <v-expansion-panel>
                <v-expansion-panel-title @click="getAccountInfo()">
                  Balances:
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                  <v-row>
                    <v-col>
                      <h3>Asset:</h3>
                    </v-col>
                    <v-col>
                      <h3>Amount:</h3>
                    </v-col>
                    <v-col>
                      <h3>Staking:</h3>
                    </v-col>
                  </v-row>
                  <div v-if="accountInfo && accountInfo.data">
                    <div
                      v-for="(item, key) in accountInfo.data.balances"
                      :key="key"
                    >
                      <v-row>
                        <v-col v-for="(element, name) in item" :key="name">
                          <!-- <h3>{{ name }}:</h3> -->
                          <div class="pa-2">{{ element }}</div>
                        </v-col>
                        <v-divider></v-divider>
                      </v-row>
                    </div>
                  </div>
                  <div v-else>Loading...</div>
                </v-expansion-panel-text>
              </v-expansion-panel>
            </v-expansion-panels>
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
let userId = "Bob617";
// let userId = "test";

let getAccountInfo = async () => {
  console.log(accountInfo.value);
  if (accountInfo?.value?.timestamp) {
    let now = Date.now();
    let refreshTime = now - accountInfo.value.timestamp;
    console.log(Math.floor(refreshTime / 1000), Math.floor(refreshTime / 1000) < 5);
    if (Math.floor(refreshTime / 1000) < 10) {
      return;
    }
  }
  console.log("fetching");
  let dataFetched = (
    await axios({
      method: "get",
      url: "http://localhost:3000/api/account",
      params: { userId },
    })
  ).data;
  accountInfo.value = {
    timestamp: Date.now(),
    data: dataFetched,
  };
  // let a = (
  //   await axios({
  //     method: "get",
  //     url: "http://localhost:3000/api/earn/blocked",
  //     params: { userId },
  //   })
  // ).data;
  // console.log(a);
  // accountInfo.value = {
  //   makerCommission: 0,
  //   takerCommission: 0,
  //   buyerCommission: 0,
  //   sellerCommission: 0,
  //   canTrade: true,
  //   canWithdraw: false,
  //   canDeposit: false,
  //   updateTime: 1652523293213,
  //   accountType: "SPOT",
  //   balances: [
  //     { asset: "BNB", free: "1000.70000000", locked: "0.00000000" },
  //     { asset: "BTC", free: "1.00000000", locked: "0.00000000" },
  //     { asset: "BUSD", free: "10000.00000000", locked: "0.00000000" },
  //     { asset: "ETH", free: "100.00000000", locked: "0.00000000" },
  //     { asset: "LTC", free: "500.00000000", locked: "0.00000000" },
  //     { asset: "TRX", free: "500000.00000000", locked: "0.00000000" },
  //     { asset: "USDT", free: "9800.60500000", locked: "0.00000000" },
  //     { asset: "XRP", free: "50000.00000000", locked: "0.00000000" },
  //   ],
  //   permissions: ["SPOT"],
  // };
};
</script>

<style scoped>
</style>
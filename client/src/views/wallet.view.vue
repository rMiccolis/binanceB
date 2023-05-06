
<template>
  <div>
    <v-row class="pb-4" justify="center"><h1>Wallet:</h1></v-row>
    <v-row>
      <v-col>
        <grid :data="accountInfo?.data?.balances"></grid>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import grid from "../components/grid.component.vue";
let accountInfo = ref(null);
let userId = "test";
// let userId = "test";
let maxRefreshTimeSecs = 10;
const baseURL = import.meta.env.VITE_SERVER_URI;

onMounted(async () => {
  await getAccountInfo();
});

let getAccountInfo = async () => {
  if (accountInfo?.value?.timestamp) {
    let now = Date.now();
    let refreshTime = now - accountInfo.value.timestamp;
    if (Math.floor(refreshTime / 1000) < maxRefreshTimeSecs) {
      return;
    }
  }

  let dataFetched = (
    await axios.get(`${baseURL}api/wallet`, {
      withCredentials: true,
    })
  ).data;
  accountInfo.value = {
    timestamp: Date.now(),
    data: dataFetched,
  };

  // PROVA ANDROID
  // setTimeout(() => {
  //   accountInfo.value = {
  //     data: {
  //       balances: [
  //         { asset: "BNB", free: "1000.70000000", locked: "0.00000000" },
  //         { asset: "BTC", free: "1.00000000", locked: "0.00000000" },
  //         { asset: "BUSD", free: "10000.00000000", locked: "0.00000000" },
  //         { asset: "ETH", free: "100.00000000", locked: "0.00000000" },
  //         { asset: "LTC", free: "500.00000000", locked: "0.00000000" },
  //         { asset: "TRX", free: "500000.00000000", locked: "0.00000000" },
  //         { asset: "USDT", free: "9800.60500000", locked: "0.00000000" },
  //         { asset: "XRP", free: "50000.00000000", locked: "0.00000000" },
  //       ],
  //     },
  //     permissions: ["SPOT"],
  //   };
  // }, 500);
};
</script>

<style scoped>
</style>
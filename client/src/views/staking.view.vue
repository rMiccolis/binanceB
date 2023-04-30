
<template>
  <div>
    <v-row class="pb-4" justify="center"><h1>Staking:</h1></v-row>
    <v-row>
      <v-col>
        <grid :data="stakingInfo?.data" :detail-data="detailData"></grid>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import axios from "axios";
import grid from "../components/grid.component.vue";
let stakingInfo = ref(null);
let userId = "Bob617";
// let userId = "test";
let maxRefreshTimeSecs = 10;
const baseURL = import.meta.env.VITE_SERVER_URI;

let detailData = ref([]);

onMounted(async () => {
  await getStakingInfo();
});

let getStakingInfo = async () => {
  if (stakingInfo?.value?.timestamp) {
    let now = Date.now();
    let refreshTime = now - stakingInfo.value.timestamp;
    if (Math.floor(refreshTime / 1000) < maxRefreshTimeSecs) {
      return;
    }
  }
  let stakingData = (
    await axios.get(`${baseURL}api/wallet/staking`, {withCredentials: true})
  ).data;
  let tempData = [];
  for (const el of stakingData) {
    tempData.push({ asset: el.asset, amount: el.amount, apy: el.apy });
    detailData.value.push({
      end_Date: new Date(el.interestEndDate).toLocaleDateString(),
      duration: el.duration,
      earn_X_day: el.nextInterestPay,
    });
  }
  stakingInfo.value = {
    timestamp: Date.now(),
    data: tempData
  };

  //PROVA ANDROID
  // setTimeout(() => {
  //   let tempData = []
  //   let dati = [
  //     {
  //       asset: "AXS",
  //       amount: "4.06909757",
  //       duration: 30,
  //       nextInterestPay: "0.00839239",
  //       interestEndDate: "5/7/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "5.72023108",
  //       duration: 30,
  //       nextInterestPay: "0.0117978",
  //       interestEndDate: "2/7/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "2.58630181",
  //       duration: 30,
  //       nextInterestPay: "0.00533416",
  //       interestEndDate: "29/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "5.57905917",
  //       duration: 30,
  //       nextInterestPay: "0.01150664",
  //       interestEndDate: "27/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "1.81126343",
  //       duration: 30,
  //       nextInterestPay: "0.00373567",
  //       interestEndDate: "26/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "SHIB",
  //       amount: "7000000",
  //       duration: 10,
  //       nextInterestPay: "1940.82",
  //       interestEndDate: "6/6/2022",
  //       apy: "0.1012",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "2.58136118",
  //       duration: 30,
  //       nextInterestPay: "0.00532397",
  //       interestEndDate: "25/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "12.27295805",
  //       duration: 30,
  //       nextInterestPay: "0.0253126",
  //       interestEndDate: "22/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "2",
  //       duration: 90,
  //       nextInterestPay: "0.00661316",
  //       interestEndDate: "17/8/2022",
  //       apy: "1.2069",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "12",
  //       duration: 60,
  //       nextInterestPay: "0.02934576",
  //       interestEndDate: "18/7/2022",
  //       apy: "0.8926",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "4.85730145",
  //       duration: 30,
  //       nextInterestPay: "0.01001803",
  //       interestEndDate: "17/6/2022",
  //       apy: "0.7528",
  //     },
  //     {
  //       asset: "SHIB",
  //       amount: "7000000",
  //       duration: 120,
  //       nextInterestPay: "2318.61",
  //       interestEndDate: "12/9/2022",
  //       apy: "0.1209",
  //     },
  //     {
  //       asset: "AXS",
  //       amount: "14.23750846",
  //       duration: 30,
  //       nextInterestPay: "0.02936443",
  //       interestEndDate: "8/6/2022",
  //       apy: "0.7528",
  //     },
  //   ];
  //   for (const el of dati) {
  //     tempData.push({ asset: el.asset, amount: el.amount, apy: el.apy });
  //     detailData.value.push({
  //       end_Date: new Date(el.interestEndDate).toLocaleDateString(),
  //       duration: el.duration,
  //       earn_X_day: el.nextInterestPay,
  //     });
  //   }
  //   stakingInfo.value = {
  //     timestamp: Date.now(),
  //     data: dati.map((el) => ({
  //       asset: el.asset,
  //       amount: el.amount,
  //       duration: el.duration,
  //     })),
  //   };
  // }, 500);
};
</script>

<style scoped>
</style>
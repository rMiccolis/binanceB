<template>
  <div>
    <v-row class="pa-2" no-gutters>
      <v-expansion-panels>
        <v-expansion-panel>
          <v-expansion-panel-title @click="getStakingInfo()">
            Staking:
          </v-expansion-panel-title>
          <v-expansion-panel-text>
            <div v-if="stakingInfo?.data && stakingInfo?.data?.length > 0">
              <v-table density="compact">
                <thead>
                  <tr>
                    <th v-for="(item, key) in stakingInfo.data[0]" :key="key" class="text-left text-capitalize">{{key}}</th>
                  </tr>
                </thead>
                <tbody v-if="stakingInfo?.data">
                  <tr v-for="(item, key) in stakingInfo.data" :key="key">
                    <td v-for="(elem, name) in item" :key="name">{{ elem }}</td>
                  </tr>
                </tbody>
              </v-table>
            </div>
            <div v-else>
              <div v-if="stakingInfo?.data && stakingInfo?.data?.length == 0">No Data Available!</div>
              <div v-else-if="!stakingInfo?.data">Loading Staking...</div>
            </div>
          </v-expansion-panel-text>
        </v-expansion-panel>
      </v-expansion-panels>
    </v-row>
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import axios from "axios";
let drawer = ref(false);

let accountInfo = ref(null);
let stakingInfo = ref(null);
let userId = "Bob617";
// let userId = "test";
let maxRefreshTimeSecs = 10;

let getStakingInfo = async () => {
  if (stakingInfo?.value?.timestamp) {
    let now = Date.now();
    let refreshTime = now - stakingInfo.value.timestamp;
    if (Math.floor(refreshTime / 1000) < maxRefreshTimeSecs) {
      return;
    }
  }
  let stakingData = (
    await axios({
      method: "get",
      url: "http://localhost:3000/api/earn/staking",
      params: { userId },
    })
  ).data;
  stakingInfo.value = {
    timestamp: Date.now(),
    data: stakingData.map((el) => ({
      asset: el.asset,
      amount: parseFloat(el.amount).toFixed(3),
      duration: el.duration,
      nextInterestPay: parseFloat(el.nextInterestPay).toFixed(3),
      interestEndDate: new Date(el.interestEndDate).toLocaleDateString(),
      apy: (el.apy * 100).toFixed(2),
    })),
  };
  // stakingInfo.value = [{"asset":"AXS","amount":"4.06909757","duration":30,"nextInterestPay":"0.00839239","interestEndDate":"5/7/2022","apy":"0.7528"},{"asset":"AXS","amount":"5.72023108","duration":30,"nextInterestPay":"0.0117978","interestEndDate":"2/7/2022","apy":"0.7528"},{"asset":"AXS","amount":"2.58630181","duration":30,"nextInterestPay":"0.00533416","interestEndDate":"29/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"5.57905917","duration":30,"nextInterestPay":"0.01150664","interestEndDate":"27/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"1.81126343","duration":30,"nextInterestPay":"0.00373567","interestEndDate":"26/6/2022","apy":"0.7528"},{"asset":"SHIB","amount":"7000000","duration":10,"nextInterestPay":"1940.82","interestEndDate":"6/6/2022","apy":"0.1012"},{"asset":"AXS","amount":"2.58136118","duration":30,"nextInterestPay":"0.00532397","interestEndDate":"25/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"12.27295805","duration":30,"nextInterestPay":"0.0253126","interestEndDate":"22/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"2","duration":90,"nextInterestPay":"0.00661316","interestEndDate":"17/8/2022","apy":"1.2069"},{"asset":"AXS","amount":"12","duration":60,"nextInterestPay":"0.02934576","interestEndDate":"18/7/2022","apy":"0.8926"},{"asset":"AXS","amount":"4.85730145","duration":30,"nextInterestPay":"0.01001803","interestEndDate":"17/6/2022","apy":"0.7528"},{"asset":"SHIB","amount":"7000000","duration":120,"nextInterestPay":"2318.61","interestEndDate":"12/9/2022","apy":"0.1209"},{"asset":"AXS","amount":"14.23750846","duration":30,"nextInterestPay":"0.02936443","interestEndDate":"8/6/2022","apy":"0.7528"}]
};
</script>

<style scoped>
</style>

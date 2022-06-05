
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
                      <div v-for="(item, key) in accountInfo.data" :key="key">
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
                      <h3>Locked:</h3>
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

          <v-row class="pa-2" no-gutters>
            <v-expansion-panels>
              <v-expansion-panel>
                <v-expansion-panel-title @click="getStakingInfo()">
                  Staking:
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
                      <h3>Duration:</h3>
                    </v-col>
                    <v-col>
                      <!-- nextInterestPay -->
                      <h3>Earn per Day:</h3>
                    </v-col>
                    <v-col>
                      <!-- interestEndDate -->
                      <h3>End Date:</h3>
                    </v-col>
                    <v-col>
                      <!-- interestEndDate -->
                      <h3>APY:</h3>
                    </v-col>
                  </v-row>
                  <div v-if="stakingInfo && stakingInfo.data.length > 0">
                    <div
                      v-for="(item, key) in stakingInfo.data"
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
                  <div v-else>Loading Staking...</div>
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
    data: stakingData.map(el => ({asset: el.asset, amount: el.amount, duration: el.duration, nextInterestPay: el.nextInterestPay, interestEndDate: new Date(el.interestEndDate).toLocaleDateString(), apy: el.apy})),
  };
  // stakingInfo.value = [{"asset":"AXS","amount":"4.06909757","duration":30,"nextInterestPay":"0.00839239","interestEndDate":"5/7/2022","apy":"0.7528"},{"asset":"AXS","amount":"5.72023108","duration":30,"nextInterestPay":"0.0117978","interestEndDate":"2/7/2022","apy":"0.7528"},{"asset":"AXS","amount":"2.58630181","duration":30,"nextInterestPay":"0.00533416","interestEndDate":"29/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"5.57905917","duration":30,"nextInterestPay":"0.01150664","interestEndDate":"27/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"1.81126343","duration":30,"nextInterestPay":"0.00373567","interestEndDate":"26/6/2022","apy":"0.7528"},{"asset":"SHIB","amount":"7000000","duration":10,"nextInterestPay":"1940.82","interestEndDate":"6/6/2022","apy":"0.1012"},{"asset":"AXS","amount":"2.58136118","duration":30,"nextInterestPay":"0.00532397","interestEndDate":"25/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"12.27295805","duration":30,"nextInterestPay":"0.0253126","interestEndDate":"22/6/2022","apy":"0.7528"},{"asset":"AXS","amount":"2","duration":90,"nextInterestPay":"0.00661316","interestEndDate":"17/8/2022","apy":"1.2069"},{"asset":"AXS","amount":"12","duration":60,"nextInterestPay":"0.02934576","interestEndDate":"18/7/2022","apy":"0.8926"},{"asset":"AXS","amount":"4.85730145","duration":30,"nextInterestPay":"0.01001803","interestEndDate":"17/6/2022","apy":"0.7528"},{"asset":"SHIB","amount":"7000000","duration":120,"nextInterestPay":"2318.61","interestEndDate":"12/9/2022","apy":"0.1209"},{"asset":"AXS","amount":"14.23750846","duration":30,"nextInterestPay":"0.02936443","interestEndDate":"8/6/2022","apy":"0.7528"}]
}

let getAccountInfo = async () => {
  if (accountInfo?.value?.timestamp) {
    let now = Date.now();
    let refreshTime = now - accountInfo.value.timestamp;
    if (Math.floor(refreshTime / 1000) < maxRefreshTimeSecs) {
      return;
    }
  }
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
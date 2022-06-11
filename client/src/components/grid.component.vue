<template>
  <div>
    <!-- <v-row class="pa-2" no-gutters>
      <v-expansion-panels>
        <v-expansion-panel>
          <v-expansion-panel-title @click="getStakingInfo()">
            Staking:
          </v-expansion-panel-title>
          <v-expansion-panel-text>
            
          </v-expansion-panel-text>
        </v-expansion-panel>
      </v-expansion-panels>
    </v-row> -->

    <div v-if="data?.length > 0">
      <v-table density="default">
        <thead>
          <tr>
            <th
              v-for="(item, key) in data[0]"
              :key="key"
              class="text-left text-capitalize"
            >
              {{ key }}
            </th>
          </tr>
        </thead>
        <tbody v-if="data">
          <tr v-for="(item, key) in data" :key="key">
            <td v-for="(elem, name) in item" :key="name">{{ elem }}</td>
          </tr>
        </tbody>
      </v-table>
    </div>
    <div v-else>
      <div v-if="data && data?.length == 0">No Data Available!</div>
      <div v-else-if="!data">Loading Staking...</div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, watch, ref } from "vue";
import axios from "axios";

const props = defineProps({
  data: { type: Array, default: null, required: false },
});
</script>

<style scoped>
</style>

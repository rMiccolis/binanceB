<script setup>
import { ref, watch } from "vue";

let headers = ref([
  {text: 'asset', align: 'start', sortable: true, value: 'asset', },
  {text: 'free', align: 'start', sortable: true, value: 'free'},
  {text: 'locked', align: 'start', sortable: true, value: 'locked'}
])

let search = ref('')

let balances =ref([ { 'asset': 'BNB', 'free': '1000.70000000', 'locked': '0.00000000' }, { 'asset': 'BTC', 'free': '1.00000000', 'locked': '0.00000000' }, { 'asset': 'BUSD', 'free': '10000.00000000', 'locked': '0.00000000' }, { 'asset': 'ETH', 'free': '100.00000000', 'locked': '0.00000000' }, { 'asset': 'LTC', 'free': '500.00000000', 'locked': '0.00000000' }, { 'asset': 'TRX', 'free': '500000.00000000', 'locked': '0.00000000' }, { 'asset': 'USDT', 'free': '9800.60500000', 'locked': '0.00000000' }, { 'asset': 'XRP', 'free': '50000.00000000', 'locked': '0.00000000' } ])

</script>

<template>
    
    <v-card>
      <v-card-title>
        Nutrition
        <v-spacer></v-spacer>
        <v-text-field
          v-model="search"
          append-icon="mdi-magnify"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
      </v-card-title>
      <v-data-table
        :headers="headers"
        :items="balances"
        :search="search"
        :items-per-page="5"
      ></v-data-table>
    </v-card>
</template>

<style scoped>

</style>
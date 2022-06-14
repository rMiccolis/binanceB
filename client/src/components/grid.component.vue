<template>
  <div>
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
            <th>Details</th>
          </tr>
        </thead>
        <tbody v-if="data">
          <tr v-for="(item, key) in data" :key="key">
            <td v-for="(elem, name) in item" :key="name">{{ elem }}</td>
            <td>
              <v-icon @click="toggleModal(key)" color="blue" class="cursor-pointer">mdi-information-outline</v-icon>
              
            </td>
          </tr>
        </tbody>
      </v-table>
    </div>
    <div v-else>
      <div v-if="data && data?.length == 0">No Data Available!</div>
      <div v-else-if="!data">Loading Staking...</div>
    </div>
    <v-dialog
        v-model="openModal"
        scrollable
      >
      <v-card>
        <v-card-title>Details:</v-card-title>
        <v-divider></v-divider>
        <v-card-text>
          {{detailShown}}
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-btn
            color="blue-darken-1"
            text
            @click="openModal = false"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
      </v-dialog>
  </div>
</template>

<script setup>
import { onMounted, watch, ref } from "vue";
import axios from "axios";

const props = defineProps({
  data: { type: Array, default: null, required: false },
  detailData: { type: Array, default: null, required: false },
});

let openModal = ref(false)
let detailShown = ref({})

let toggleModal = (key) => {
  detailShown.value = props.data[key]
  openModal.value = true
}

</script>

<style scoped>
.cursor-pointer {
  cursor: pointer;
}
</style>

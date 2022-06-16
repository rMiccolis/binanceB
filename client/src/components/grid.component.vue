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
              <span style="text-transform: uppercase">{{
                key.replace(/_/g, " ")
              }}</span>
            </th>
            <th v-if="detailData.length > 0">
              <span style="text-transform: uppercase">Details</span>
            </th>
          </tr>
        </thead>
        <tbody v-if="data">
          <tr v-for="(item, key) in data" :key="key">
            <td v-for="(elem, name) in item" :key="name">{{ elem }}</td>
            <td v-if="detailData.length > 0">
              <v-icon
                @click="toggleModal(key)"
                color="blue"
                class="cursor-pointer"
                >mdi-information-outline</v-icon
              >
            </td>
          </tr>
        </tbody>
      </v-table>
    </div>
    <div v-else>
      <div v-if="data && data?.length == 0">No Data Available!</div>
      <div v-else-if="!data">Loading Staking...</div>
    </div>
    <v-dialog v-model="openModal" scrollable>
      <v-card>
        <v-card-title
          ><span style="text-transform: uppercase"
            >details:
            <v-icon size="small" color="blue" class="cursor-pointer me-2"
              >mdi-clipboard-list-outline</v-icon
            ></span
          ></v-card-title
        >
        <v-divider></v-divider>
        <v-card-text style="height: 50vh; width: 85vw">
          <div v-for="(elem, name) in detailShown" :key="name">
            <v-list-item>
              <v-list-item-header>
                <v-list-item-title> <span style="text-transform: uppercase">{{
                name.replace(/_/g, " ")
              }}<v-icon size="small" color="blue" class="cursor-pointer ms-5"
              >mdi-arrow-right-thick</v-icon
            > </span></v-list-item-title>
              </v-list-item-header>
              {{ elem }}
            </v-list-item>
            <v-divider></v-divider>
          </div>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-btn color="blue-darken-1" text @click="openModal = false">
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
  detailData: { type: Array, default: [], required: false },
});

let openModal = ref(false);
let detailShown = ref({});

let toggleModal = (key) => {
  detailShown.value = props.detailData[key];
  console.log(detailShown);
  openModal.value = true;
};
</script>

<style scoped>
.cursor-pointer {
  cursor: pointer;
}
</style>

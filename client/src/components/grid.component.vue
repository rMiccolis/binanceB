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
      <div v-else-if="!data">Loading data...</div>
    </div>
    <v-dialog v-model="openModal" scrollable>
      <v-card width="80vw" elevation="10" rounded="10">
        <v-card-title
          ><span
            ><v-icon size="small" color="blue" class="cursor-pointer me-2"
              >mdi-clipboard-list-outline</v-icon
            >Details:
          </span></v-card-title
        >
        <v-divider></v-divider>
        <!-- <v-card-text style="height: 50vh; width: 85vw"> -->
          
        <v-card-text>
          <v-list-item v-for="(elem, name) in detailShown" :key="name">
            <v-list-item-header>
              <v-list-item-title
                ><span style="text-transform: capitalize">{{
                  name.replace(/_/g, " ")
                }}</span></v-list-item-title
              >
              <v-list-item-subtitle>{{ elem }}</v-list-item-subtitle>
            </v-list-item-header>
          </v-list-item>
        </v-card-text>

        <v-card-actions>
          <v-btn
            block
            variant="outlined"
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
  detailData: { type: Array, default: [], required: false },
});

let openModal = ref(false);
let detailShown = ref({});

let toggleModal = (key) => {
  detailShown.value = props.detailData[key];
  // console.log(detailShown);
  openModal.value = true;
};
</script>

<style scoped>
.cursor-pointer {
  cursor: pointer;
}
</style>

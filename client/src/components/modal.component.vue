<template>
  <v-row justify="center">
    <v-dialog v-model="modalState" :persistent="persistent" :max-width="'80vw'">
      <v-toolbar dark color="blue" class="text-center">
        <v-row no-gutters align="center" :justify="'end'" class="ml-2">
          <!-- <v-spacer></v-spacer> -->
          <v-col cols="1" :align-self="'end'">
            <v-btn icon dark @click="toggleModal">
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </v-col>
          <v-col cols="10">
              <h3><slot name="header"></slot></h3>
          </v-col>
          <v-col></v-col>
        </v-row>
        <!-- <v-card-title v-if="$slots.header">
        
      </v-card-title> -->
      </v-toolbar>
      <v-card>
        <v-card-text class="mt-0 pt-0" v-if="$slots.body">
          <!-- <v-container> -->
            <slot name="body"></slot>
          <!-- </v-container> -->
        </v-card-text>
        <v-card-actions v-if="$slots.footer">
          <v-spacer></v-spacer>
          <slot name="footer"></slot>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-row>
</template>

<script setup>
import { onMounted, watch, ref } from "vue";
// import _ from "lodash";
const props = defineProps({
  open: { type: Boolean, default: false, required: true },
  name: { type: String, default: undefined, required: true },
  minWidth: { type: String, default: undefined, required: false },
  width: { type: String, default: undefined, required: false },
  maxWidth: { type: String, default: undefined, required: false },
  height: { type: String, default: undefined, required: false },
  maxHeight: { type: String, default: undefined, required: false },
  minHeight: { type: String, default: undefined, required: false },
  persistent: { type: Boolean, default: false, required: false },
});
const modalState = ref(props.open);
const emit = defineEmits(["toggle"]);

const toggleModal = () => {
  let emitObj = {
    name: props.name,
    value: false,
  };
  emit("toggle", emitObj);
};

watch(
  () => props.open,
  (value) => {
    modalState.value = value;
  }
);
</script>
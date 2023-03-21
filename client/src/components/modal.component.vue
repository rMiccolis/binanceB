<template>
  <v-row justify="center">
<<<<<<< HEAD
    <v-dialog
      v-model="modalState"
      :persistent="persistent"
      @click:outside="toggleModal"
    >
      <v-card :min-width="'75vw'" :max-width="'100vw'" :width="'85vw'">
        <v-card-title>
          <v-row class="justify-center">
            <slot name="header"></slot>
          </v-row>
        </v-card-title>
        <v-card-text>
          <v-container>
            <slot name="body"></slot>
          </v-container>
        </v-card-text>
        <v-card-actions>
=======
    <v-dialog v-model="modalState" :persistent="persistent">
      <v-toolbar dark color="blue" class="text-center">
        <v-row no-gutters align="center" :justify="'end'">
          <v-col cols="2">
            <v-btn icon dark @click="toggleModal">
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </v-col>
          <!-- <v-spacer></v-spacer> -->
          <v-col cols="9">
            
              <h3><slot name="header"></slot></h3>
          </v-col>
          <v-col></v-col>
        </v-row>
        <!-- <v-card-title v-if="$slots.header">
        
      </v-card-title> -->
      </v-toolbar>
      <v-card :min-width="'75vw'" :max-width="'100vw'" :width="'85vw'">
        <v-card-text class="mt-0 pt-0" v-if="$slots.body">
          <!-- <v-container> -->
            <slot name="body"></slot>
          <!-- </v-container> -->
        </v-card-text>
        <v-card-actions v-if="$slots.footer">
>>>>>>> develop
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
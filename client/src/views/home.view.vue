<template>
  <div>
    <h2>type your account name:</h2>
    <v-text-field
      shaped
      prepend-inner-icon="mdi-account"
      label="Account Name"
      hint="For testing, type 'test'"
      color="blue"
      clearable
    ></v-text-field>
    
    <v-text-field
      v-model="psw"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye' : 'mdi-eye-off'"
      label="Password"
      :error="error"
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
      @update:model-value="a"
    ></v-text-field>

    <v-btn flat color="blue">
      Submit
    </v-btn>
    
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
let error = ref(true)
let show = ref(false)
let userId = ref("")
let psw = ref("")


</script>

<style scoped>
</style>
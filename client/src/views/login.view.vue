<template>
  <div>
    <h2>type your account name:</h2>
    <v-text-field
      :disabled="isTextDisabled"
      v-model="userId"
      shaped
      :error="error()"
      prepend-inner-icon="mdi-account"
      label="Account Name"
      hint="For testing, type 'test'"
      color="blue"
      clearable
    ></v-text-field>

    <v-text-field
      :disabled="isTextDisabled"
      v-model="password"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Password"
      :error="error()"
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
      @update:model-value="a"
    ></v-text-field>

    <v-text-field
      :disabled="isTextDisabled"
      v-model="apyKey"
      shaped
      prepend-inner-icon="mdi-key"
      label="Public APY_KEY"
      :error="error()"
      @click:append-inner="show = !show"
      clearable
      @update:model-value="a"
    ></v-text-field>

    <v-text-field
      :disabled="isTextDisabled"
      v-model="privateApyKey"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Private APY_KEY"
      :error="error()"
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
      @update:model-value="a"
    ></v-text-field>

    <v-row class="pb-4" justify="center">
      <v-btn class="mr-5" flat color="blue" @click="signin()"> Sign In! </v-btn>
      <v-btn flat color="green" @click="signup()"> Sign Up! </v-btn>
    </v-row>

    <v-row class="pb-4" justify="center">
      <p v-if="axiosResponse">{{ axiosResponse }}</p>
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from "axios";

let isTextDisabled = ref(false);
let show = ref(false);
let userId = ref("");
let password = ref("");
let a = ref("");
let axiosResponse = ref("");
let error = () => {
  if (password.value.length > 0) return false;
  return true;
};

let signin = async () => {
  isTextDisabled.value = true;
  let response = await axios.post(
    "http://localhost:3000/auth/signin",
    {
      userId: userId.value,
      password: password.value,
    },
    { withCredentials: true }
  );

  isTextDisabled.value = false;
  axiosResponse.value = response.data;
};

let signup = async () => {
  isTextDisabled.value = true;
  let response = await axios.post(
    "http://localhost:3000/auth/signup",
    {
      userId: userId.value,
      password: password.value,
    },
    { withCredentials: true }
  );

  isTextDisabled.value = false;
  axiosResponse.value = response.data;
};
</script>

<style>
.b-pointer {
  cursor: pointer;
}
</style>
<template>
  <div>
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
      <!-- @update:model-value="a" -->

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
    ></v-text-field>

    <v-text-field
      :disabled="isTextDisabled"
      v-model="publicApiKey"
      shaped
      prepend-inner-icon="mdi-key"
      label="Public API_KEY"
      :error="error()"
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

    <v-text-field
      :disabled="isTextDisabled"
      v-model="privateApiKey"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Private API_KEY"
      :error="error()"
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

    <v-row class="mt-5 mb-5" justify="center">
      <v-col class="text-center">
        <v-btn block variant="outlined" color="blue" @click="signin()">
          Sign In!
        </v-btn>
      </v-col>
      <v-col class="text-center">
        <v-btn block variant="outlined" color="green" @click="signup()">
          Sign Up!
        </v-btn>
      </v-col>
    </v-row>

    <v-row v-if="axiosResponse" class="mt-5" justify="center">
      <p>{{ axiosResponse }}</p>
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from "axios";

const emit = defineEmits(["loggedIn"]);

let privateApiKey = ref("");
let publicApiKey = ref("");
let isTextDisabled = ref(false);
let show = ref(false);
let userId = ref("");
let password = ref("");
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

  if (response.data.error == false) {
    emit("loggedIn", {loggedIn: true, sessionInfo: response.data.sessionInfo});
  } else {
    emit("loggedIn", {loggedIn: false, sessionInfo: null});
  }

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
      publicApiKey: publicApiKey.value,
      privateApiKey: privateApiKey.value,
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
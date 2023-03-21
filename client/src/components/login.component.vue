<template>
  <div>
<<<<<<< HEAD
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
=======
    <v-tabs fixed-tabs centered stacked slider-color="blue" class="mb-5 pt-0 mt-0" color="blue">
      <v-tab value="signin" @click="selectTab('signin')">
        <v-icon size="small">mdi-key</v-icon>
        <small>Sign in!</small>
      </v-tab>

      <v-tab value="signup" @click="selectTab('signup')">
        <v-icon size="small">mdi-exit-to-app</v-icon>
        <small>Sign up!</small>
      </v-tab>
    </v-tabs>

    <v-text-field
      v-model="userId"
      shaped
      :error="error('userId')"
      prepend-inner-icon="mdi-account"
      label="Account Name"
      hint="For testing, User ID is 'aa'"
      color="blue"
      clearable
    ></v-text-field>
    <!-- @update:model-value="a" -->

    <v-text-field
>>>>>>> develop
      v-model="password"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Password"
<<<<<<< HEAD
      :error="error()"
=======
      hint="For testing, Password is 'aa'"
      :error="error('psw')"
>>>>>>> develop
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

    <v-text-field
<<<<<<< HEAD
      :disabled="isTextDisabled"
      v-model="publicApiKey"
      shaped
      prepend-inner-icon="mdi-key"
      label="Public API_KEY"
      :error="error()"
=======
      v-if="selectedTab == 'signup'"
      v-model="confirmPassword"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Confirm Password"
      hint="For testing, Password is 'aa'"
      :error="error('confirmPassword')"
      :type="show ? 'text' : 'password'"
>>>>>>> develop
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

    <v-text-field
<<<<<<< HEAD
      :disabled="isTextDisabled"
=======
      v-if="selectedTab == 'signup'"
      v-model="publicApiKey"
      shaped
      prepend-inner-icon="mdi-key"
      label="Public API_KEY"
      :error="error('pubApyKey')"
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

    <v-text-field
      v-if="selectedTab == 'signup'"
>>>>>>> develop
      v-model="privateApiKey"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Private API_KEY"
<<<<<<< HEAD
      :error="error()"
=======
      :error="error('privApyKey')"
>>>>>>> develop
      :type="show ? 'text' : 'password'"
      @click:append-inner="show = !show"
      clearable
    ></v-text-field>

<<<<<<< HEAD
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
=======
    <v-row class="mb-5" justify="center">
      <v-col class="text-center">
        <v-btn
          block
          variant="outlined"
          :color="formError === true ? 'rgb(207,102,121)' : 'blue'"
          :disabled="formError"
          @click="selectedTab == 'signin' ? signin() : signup()"
        >
          {{ action }}!
        </v-btn>
      </v-col>
>>>>>>> develop
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from "axios";

<<<<<<< HEAD
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
  // let response = await axios.post(
  //   "http://localhost:3000/auth/signin",
  //   {
  //     userId: userId.value,
  //     password: password.value,
  //   },
  //   { withCredentials: true }
  // );

  // if (response.data.error == false) {
    emit("loggedIn", {loggedIn: true, sessionInfo: {"userId":"aa","iat":1663433314286,"exp":1699999963436314286}});
  // }
  //  else {
  //   emit("loggedIn", {loggedIn: false, sessionInfo: null});
  // }

  isTextDisabled.value = false;
  // axiosResponse.value = response.data;
};

let signup = async () => {
  isTextDisabled.value = true;
  let response = await axios.post(
    "http://localhost:3000/auth/signup",
    {
      userId: userId.value,
=======
const emit = defineEmits(["loggedIn", "changeHeader"]);
const baseURL = import.meta.env.VITE_SERVER_URI;

let privateApiKey = ref("");
let publicApiKey = ref("");
let show = ref(false);
let userId = ref("");
let password = ref("");
let selectedTab = ref("signin");
let action = ref("Sign In");
let confirmPassword = ref("");
let formError = ref(true);

let error = (type) => {
  let error = true;

  if (type == "confirmPassword" && password.value == confirmPassword.value && password.value.length >= 8) {
    error = false;
  }
  else if (type == "psw" && (password.value == 'aa' || password.value.length >= 8)) {
    error = false;
  }
  else if (type == "userId" && (userId.value == 'aa' || userId.value.length > 3)) {
    error = false;
  }
  else if (type == "pubApyKey" && publicApiKey.value.length > 0) {
    error = false;
  }
  else if (type == "privApyKey" && privateApiKey.value.length > 0) {
    error = false;
  }
  formError.value = error;
  return error;
};

const selectTab = (tabClicked) => {
  selectedTab.value = tabClicked;
  action.value = selectedTab.value == "signin" ? "Sign In" : "Sign Up";
  emit("changeHeader", action.value + "!");
  userId.value = "";
  password.value = "";
  confirmPassword.value = "";
  publicApiKey.value = "";
  privateApiKey.value = "";

};

let signin = async () => {
  let response = await axios.post(
    `${baseURL}auth/signin`,
    {
      userId: userId.value.toLowerCase(),
      password: password.value,
    },
    { withCredentials: true }
  );

  if (response.data.error == false) {
    emit("loggedIn", {
      loggedIn: true,
      sessionInfo: response.data.sessionInfo,
    });
  } else {
    emit("loggedIn", { loggedIn: false, sessionInfo: null });
  }
};

let signup = async () => {
  let response = await axios.post(
    `${baseURL}auth/signup`,
    {
      userId: userId.value.toLowerCase(),
>>>>>>> develop
      password: password.value,
      publicApiKey: publicApiKey.value,
      privateApiKey: privateApiKey.value,
    },
    { withCredentials: true }
  );

<<<<<<< HEAD
  isTextDisabled.value = false;
  axiosResponse.value = response.data;
=======
  if (response.data.error === false) {
    selectTab("signin");
  }
>>>>>>> develop
};
</script>

<style>
.b-pointer {
  cursor: pointer;
}
</style>
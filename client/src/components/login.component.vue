<template>
  <div>
    <div class="img-container">
      <v-img
        class="blur icon-center mb-2"
        width="45%"
        lazy-src="binanceB_android_icon-removebg-preview.svg"
        src="binanceB_android_icon-removebg-preview.svg"
        cover
      >
      </v-img>
      <h1 class="centered-icon-text">BinanceB</h1>
    </div>
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
      v-model="password"
      shaped
      prepend-inner-icon="mdi-key"
      :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
      label="Password"
      hint="For testing, Password is 'aa'"
      :error="error('psw')"
      :type="show ? 'text' : 'password'"
      @click:append-inner="showHideLabel"
      clearable
    ></v-text-field>

    <div>

      <v-text-field
        v-if="selectedTab == 'signup'"
        v-model="confirmPassword"
        shaped
        prepend-inner-icon="mdi-key"
        :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
        label="Confirm Password"
        hint="For testing, Password is 'aa'"
        :error="error('confirmPassword')"
        :type="show ? 'text' : 'password'"
        @click:append-inner="show = !show"
        clearable
      ></v-text-field>
  
      <v-text-field
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
        v-model="privateApiKey"
        shaped
        prepend-inner-icon="mdi-key"
        :append-inner-icon="show ? 'mdi-eye b-pointer' : 'mdi-eye-off b-pointer'"
        label="Private API_KEY"
        :error="error('privApyKey')"
        :type="show ? 'text' : 'password'"
        @click:append-inner="show = !show"
        clearable
      ></v-text-field>
    </div>

    <v-row>
      <v-col cols="12" v-if="selectedTab == 'signin'">
        <v-checkbox
          class="d-inline-flex text-center"
          color="blue"
          v-model="rememberme"
          :label="'Remember me'"
        ></v-checkbox>
      </v-col>

      <v-col cols="12">
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
    </v-row>

    <v-row>
      <v-col>
        <v-alert
          v-if="alert?.display"
          :color="alert.type"
          class="rounded-shaped"
          density="compact"
          :icon="`$${alert.type}`"
          :text="alert.message"
        ></v-alert>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <p
          v-if="selectedTab == 'signin'"
          @click="selectTab('signup')"
          class="text-center text-caption text-blue cursor-pointer"
        >
          Not registered? Sign up!
        </p>
        <p
          v-else
          @click="selectTab('signin')"
          class="text-center text-caption text-blue cursor-pointer"
        >
          Already registered? Sign in!
        </p>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import axios from "axios";

const emit = defineEmits(["action", "changeHeader"]);
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
const alert = ref(null);
let rememberme = ref(false);

const props = defineProps({
  displayAlert: { type: Object, default: null, required: false },
});

const showHideLabel = () => {
  show.value = !show.value;
};

let error = (type) => {
  let error = true;

  if (
    type == "confirmPassword" &&
    password.value == confirmPassword.value &&
    password.value?.length >= 8
  ) {
    error = false;
  } else if (
    type == "psw" &&
    (password.value == "aa" || password.value?.length >= 8)
  ) {
    error = false;
  } else if (
    type == "userId" &&
    (userId.value == "aa" || userId.value?.length > 3)
  ) {
    error = false;
  } else if (type == "pubApyKey" && publicApiKey.value?.length > 0) {
    error = false;
  } else if (type == "privApyKey" && privateApiKey.value?.length > 0) {
    error = false;
  }
  formError.value = error;
  return error;
};

const selectTab = (tabClicked) => {
  // alert.value.display = false;
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
  emit("action", {
    type: "signin",
    userId: userId.value.toLowerCase(),
    password: password.value,
    rememberme: rememberme.value,
  });
};

let signup = async () => {
  emit("action", {
    type: "signup",
    userId: userId.value.toLowerCase(),
    password: password.value,
    publicApiKey: publicApiKey.value,
    privateApiKey: privateApiKey.value,
  });
};

watch(
  () => props.displayAlert,
  (value) => {
    alert.value = props.displayAlert;
    setTimeout(() => {
      alert.value.display = false;
    }, 5000);
  }
);
</script>

<style>
.b-pointer {
  cursor: pointer;
}

.icon-center {
  display: block;
  margin-left: auto;
  margin-right: auto;
  max-width: 45%;
}

.img-container {
  position: relative;
  text-align: center;
  color: rgba(255, 255, 255, 0.551);
}

/* Centered text */
.centered-icon-text {
  /* position: absolute; */
  /* top: 50%;
  left: 50%;
  transform: translate(-50%, -50%); */
  color: var(--app-icon-text-color);
  font-family: fantasy;
}
</style>
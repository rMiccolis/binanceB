<template>
    <div id="mySidenav" class="sidenav">
      <a class="icon-list" @click="toggleNav()"
        ><i class="bi bi-list"></i></a
      >
      <a href="#"><i class="bi bi-person"></i> <transition name='fade'> <span v-if="open">{{sidebarElements.account}}</span> </transition></a>
      <hr class="dropdown-divider divider">
      <a href="#"><i class="bi bi-house"></i> <span class="labels" v-if="open">{{sidebarElements.home}}</span></a>
      <a href="#"><i class="bi bi-gear"></i> <span class="labels" v-if="open">{{sidebarElements.settings}}</span></a>
    </div>
</template>

<script setup>
import { ref, watch, onMounted, defineEmits } from 'vue'
const props = defineProps({
  open: {
    type: Boolean,
    default: false
  },
});

const emit = defineEmits(['open', 'close'])

let sidebarElements = ref({account: 'Account', home: 'Home', settings: 'Settings'})

function toggleNav() {
  props.open == true ? closeNav() : openNav()
}

//function section
/* Set the width of the side navigation to 250px */
function openNav() {
  document.getElementById("mySidenav").style.width = "250px";
  emit("open");
}

/* Set the width of the side navigation to 0 */
function closeNav() {
  emit("close");
  document.getElementById("mySidenav").style.width = "50px";
}

onMounted(() => {
  closeNav();
})

watch( () => props.open, (value, oldValue) => {
  console.log("props.open = ", value);
    if (value == false) {
      closeNav();
    } else {
      openNav();
    }
  });
</script>

<style scoped>
.divider {
  color: white;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.1s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

/* The side navigation menu */
.sidenav {
  height: 100%; /* 100% Full-height */
  width: 0; /* 0 width - change this with JavaScript */
  position: fixed; /* Stay in place */
  z-index: 1; /* Stay on top */
  top: 0; /* Stay at the top */
  left: 0;
  background-color: #111; /* Black*/
  overflow-x: hidden; /* Disable horizontal scroll */
  padding-top: 60px; /* Place content 60px from the top */
  transition: 0.5s; /* 0.5 second transition effect to slide in the sidenav */
}

/* The navigation menu links */
.sidenav a {
  padding: 8px 8px 8px 1vw;
  text-decoration: none;
  font-size: 25px;
  color: #818181;
  display: block;
  transition: 0.3s;
}

/* When you mouse over the navigation links, change their color */
.sidenav a:hover {
  color: #f1f1f1;
}

.icon-list{
  color: #f1f1f1;
  font-size: 0.875em;
}

/* Position and style the close button (top right corner) */
.sidenav .closebtn {
  position: absolute;
  top: 0;
  right: 25px;
  font-size: 36px;
  margin-left: 50px;
}

/* Style page content - use this if you want to push the page content to the right when you open the side navigation */
#main {
  transition: margin-left 0.5s;
  padding: 20px;
}

/* On smaller screens, where height is less than 450px, change the style of the sidenav (less padding and a smaller font size) */
@media screen and (max-height: 450px) {
  .sidenav {
    padding-top: 15px;
  }
  .sidenav a {
    font-size: 18px;
  }
}
</style>

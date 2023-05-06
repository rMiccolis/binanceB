import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia'
import router from './router'
import vuetify from './plugins/vuetify'
import { loadFonts } from './plugins/webfontloader'
import 'bootstrap-icons/font/bootstrap-icons.css'
loadFonts()

const pinia = createPinia()

createApp(App)
  .use(router)
  .use(vuetify)
  .use(pinia)
  .mount('#app')

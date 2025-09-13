import { createApp } from 'vue'
import './styles/main.scss'
import App from './App.vue'
import { createWebHistory, createRouter } from 'vue-router'
import { routes } from './generated-routes'

const router = createRouter({
    history: createWebHistory(),
    routes
})

const app = createApp(App)
app.use(router)
app.mount('#app')

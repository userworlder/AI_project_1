import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import router from './router'
import App from './App.vue'
import { useUserStore } from './stores/user'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(ElementPlus)

// 挂载前初始化用户状态（从 localStorage 恢复）
app.mount('#app')

// 在应用挂载后初始化用户状态
const userStore = useUserStore()
userStore.initFromStorage()

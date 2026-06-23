import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import './styles/variables.css'
import router from './router'
import App from './App.vue'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(ElementPlus)

// 先挂载应用
app.mount('#app')

// 路由准备就绪后，从 localStorage 恢复用户状态
router.isReady().then(() => {
  import('@/stores/user').then(({ useUserStore }) => {
    const userStore = useUserStore()
    userStore.initFromStorage()
  })
})

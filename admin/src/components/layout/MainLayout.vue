<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSidebarStore } from '@/stores/sidebar'
import { useUserStore } from '@/stores/user'
import {
  Menu,
  User,
  Setting,
  HomeFilled,
  Folder,
  Notebook,
  MagicStick,
  UserFilled,
  ShoppingCart,
  Plus,
  Document,
  ArrowLeft,
  ArrowRight
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const sidebarStore = useSidebarStore()
const userStore = useUserStore()

const menuItems = [
  { name: 'Dashboard', path: '/dashboard', icon: HomeFilled },
  { name: '用户管理', path: '/user', icon: UserFilled },
  { name: '技能树管理', path: '/skill', icon: Folder },
  { name: '学习记录', path: '/record', icon: Notebook },
  { name: 'AI功能管理', path: '/ai', icon: MagicStick },
  { name: '订单管理', path: '/order', icon: ShoppingCart },
  { name: '计数器', path: '/counter', icon: Plus },
  { name: '用户表单', path: '/user-form', icon: Document }
]

console.log('Menu items:', menuItems)

const activePath = computed(() => route.path)

const handleLogout = () => {
  // 调用 userStore.logout() 清除状态
  userStore.logout()
  // 跳转到登录页
  router.push('/login')
}
</script>

<template>
  <div class="layout-container">
    <aside class="sidebar" :class="{ collapsed: sidebarStore.collapsed }">
      <div class="logo">
        <span class="logo-text">AI伴学</span>
      </div>
      <nav class="menu">
        <ul class="sidebar-menu">
          <li
            v-for="item in menuItems"
            :key="item.path"
            :class="{ active: activePath === item.path }"
            @click="router.push(item.path)"
          >
            <component :is="item.icon" />
            <span>{{ item.name }}</span>
          </li>
        </ul>
      </nav>
    </aside>

    <!-- 侧边栏折叠按钮 -->
    <div class="toggle-bar" @click="sidebarStore.toggle">
      <component :is="sidebarStore.collapsed ? ArrowRight : ArrowLeft" />
    </div>

    <main class="main-content">
      <header class="header">
        <div class="header-left">
          <button class="toggle-btn" @click="sidebarStore.toggle">
            <Menu />
          </button>
        </div>
        <div class="header-right">
          <el-button :icon="Setting" circle />
          <el-dropdown>
            <el-button class="user-btn" :icon="User" circle />
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>个人中心</el-dropdown-item>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <div class="content-wrapper">
        <router-view />
      </div>
    </main>
  </div>
</template>

<style scoped>
.layout-container {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.sidebar {
  width: 200px;
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  color: #fff;
  transition: width 0.3s ease;
  overflow: hidden;
}

.sidebar.collapsed {
  width: 64px;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  white-space: nowrap;
  overflow: hidden;
}

.logo-text {
  font-size: 18px;
  font-weight: bold;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.sidebar.collapsed .logo-text {
  opacity: 0;
  transform: translateX(-10px);
}

.menu {
  padding: 16px 0;
}

.sidebar-menu {
  list-style: none;
  padding: 0;
  margin: 0;
}

.sidebar-menu li {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  margin: 4px 8px;
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  transition: all 0.3s ease;
}

.sidebar-menu li:hover {
  background: rgba(102, 126, 234, 0.2);
}

.sidebar-menu li.active {
  background: linear-gradient(90deg, rgba(102, 126, 234, 0.3) 0%, rgba(118, 75, 162, 0.3) 100%);
  color: #fff;
}

.sidebar-menu li svg {
  width: 20px;
  height: 20px;
  margin-right: 12px;
  flex-shrink: 0;
}

.sidebar-menu li span {
  font-size: 14px;
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.sidebar.collapsed .sidebar-menu li span {
  opacity: 0;
  transform: translateX(-10px);
  width: 0;
  overflow: hidden;
}

/* 侧边栏折叠按钮 */
.toggle-bar {
  width: 24px;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #666;
  font-size: 14px;
  transition: all 0.3s ease;
  writing-mode: vertical-rl;
}

.toggle-bar:hover {
  background: #f5f7fa;
  color: #667eea;
}

.toggle-bar svg {
  width: 16px;
  height: 16px;
  transition: transform 0.3s ease;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}

.header {
  height: 60px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.header-left {
  display: flex;
  align-items: center;
}

.toggle-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  padding: 8px;
  color: #666;
}

.toggle-btn:hover {
  background: #f5f7fa;
  border-radius: 6px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-btn {
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border: none;
}

.content-wrapper {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}
</style>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSidebarStore } from '@/stores/sidebar'
import { useUserStore } from '@/stores/user'
import {
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
  ArrowRight,
  Fold,
  Expand,
  ArrowDown
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const sidebarStore = useSidebarStore()
const userStore = useUserStore()

const menuItems = [
  { name: '仪表盘', path: '/dashboard', icon: HomeFilled },
  { name: '用户管理', path: '/user', icon: UserFilled },
  { name: '技能树管理', path: '/skill', icon: Folder },
  { name: '学习记录', path: '/record', icon: Notebook },
  { name: 'AI功能管理', path: '/ai', icon: MagicStick },
  { name: '订单管理', path: '/order', icon: ShoppingCart },
  { name: '计数器', path: '/counter', icon: Plus },
  { name: '用户表单', path: '/user-form', icon: Document }
]

const activePath = computed(() => route.path)

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}

const pageTitle = computed(() => route.meta?.title || '')
</script>

<template>
  <div class="layout-container">
    <!-- ===== 侧栏 ===== -->
    <aside class="sidebar" :class="{ collapsed: sidebarStore.collapsed }">
      <!-- Logo -->
      <div class="logo-area">
        <div class="logo-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M12 2L2 7v10l10 5 10-5V7L12 2z" fill="currentColor" opacity="0.3"/>
            <path d="M12 2L2 7v2l10-5 10 5V7L12 2z" fill="currentColor"/>
            <path d="M2 17l10 5 10-5v-3L12 14 2 11v6z" fill="currentColor" opacity="0.2"/>
          </svg>
        </div>
        <span class="logo-text">AI伴学</span>
      </div>

      <!-- 导航 -->
      <nav class="nav-area">
        <div class="nav-label" v-show="!sidebarStore.collapsed">导航菜单</div>
        <ul class="nav-list">
          <li
            v-for="item in menuItems"
            :key="item.path"
            class="nav-item"
            :class="{ active: activePath === item.path }"
            @click="router.push(item.path)"
          >
            <div class="nav-item-inner">
              <div class="nav-indicator"></div>
              <component :is="item.icon" class="nav-icon" />
              <span class="nav-name">{{ item.name }}</span>
            </div>
          </li>
        </ul>
      </nav>

      <!-- 折叠按钮 -->
      <div class="sidebar-footer" @click="sidebarStore.toggle">
        <div class="collapse-btn">
          <component :is="sidebarStore.collapsed ? ArrowRight : ArrowLeft" />
          <span v-show="!sidebarStore.collapsed">收起侧栏</span>
        </div>
      </div>
    </aside>

    <!-- ===== 主区域 ===== -->
    <div class="main-area">
      <!-- 顶栏 -->
      <header class="header">
        <div class="header-left">
          <button class="collapse-trigger" @click="sidebarStore.toggle">
            <component :is="sidebarStore.collapsed ? Expand : Fold" />
          </button>
          <div class="page-hierarchy">
            <span class="hierarchy-root">首页</span>
            <span class="hierarchy-sep">/</span>
            <span class="hierarchy-current">{{ pageTitle }}</span>
          </div>
        </div>
        <div class="header-right">
          <div class="header-actions">
            <el-tooltip content="通知中心" placement="bottom">
              <button class="header-icon-btn">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                  <path d="M13.73 21a2 2 0 01-3.46 0"/>
                </svg>
                <span class="notif-dot"></span>
              </button>
            </el-tooltip>

            <el-dropdown trigger="click">
              <div class="user-profile">
                <div class="avatar-circle">
                  <span>{{ userStore.userInfo?.nickname?.charAt(0) || 'A' }}</span>
                </div>
                <span class="username">
                  {{ userStore.userInfo?.nickname || '管理员' }}
                </span>
                <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item :icon="User">个人中心</el-dropdown-item>
                  <el-dropdown-item divided :icon="Setting" @click="handleLogout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </header>

      <!-- 内容区 -->
      <div class="content-wrapper">
        <router-view />
      </div>
    </div>
  </div>
</template>

<style scoped>
/* ===== 布局容器 ===== */
.layout-container {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

/* =============================================
   侧栏
   ============================================= */
.sidebar {
  width: var(--sidebar-width);
  background: var(--sidebar-bg);
  display: flex;
  flex-direction: column;
  transition: width var(--transition-base);
  overflow: hidden;
  flex-shrink: 0;
  z-index: 100;
  position: relative;
}

/* 右侧分割线光效 */
.sidebar::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  width: 1px;
  background: linear-gradient(180deg,
    transparent 0%,
    rgba(99, 102, 241, 0.25) 30%,
    rgba(99, 102, 241, 0.25) 70%,
    transparent 100%
  );
}

.sidebar.collapsed {
  width: var(--sidebar-collapsed-width);
}

/* Logo */
.logo-area {
  height: 64px;
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 12px;
  border-bottom: 1px solid var(--sidebar-divider);
  flex-shrink: 0;
}

.logo-icon {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #fff;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: #fff;
  white-space: nowrap;
  letter-spacing: 1px;
  transition: opacity var(--transition-base);
}

.sidebar.collapsed .logo-text {
  opacity: 0;
  width: 0;
  overflow: hidden;
}

.sidebar.collapsed .logo-area {
  padding: 0;
  justify-content: center;
}

/* 导航 */
.nav-area {
  flex: 1;
  padding: 4px 0;
  overflow-y: auto;
  overflow-x: hidden;
}

.nav-label {
  font-size: 11px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.25);
  text-transform: uppercase;
  letter-spacing: 1.2px;
  padding: 16px 20px 8px;
  user-select: none;
}

.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-item {
  padding: 2px 12px;
  cursor: pointer;
}

.nav-item-inner {
  display: flex;
  align-items: center;
  padding: 9px 12px;
  border-radius: var(--radius-md);
  color: var(--sidebar-text);
  transition: all var(--transition-fast);
  position: relative;
  gap: 12px;
  user-select: none;
}

.nav-item:hover .nav-item-inner {
  background: var(--sidebar-hover-bg);
  color: var(--sidebar-text-active);
}

.nav-item.active .nav-item-inner {
  background: var(--sidebar-active-bg);
  color: var(--sidebar-text-active);
}

/* 激活指示条 */
.nav-indicator {
  position: absolute;
  left: -12px;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 0;
  border-radius: 0 3px 3px 0;
  background: var(--sidebar-active-border);
  transition: height var(--transition-fast);
  box-shadow: 0 0 8px rgba(99, 102, 241, 0.4);
}

.nav-item.active .nav-indicator {
  height: 20px;
}

.nav-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.nav-name {
  font-size: var(--font-base);
  white-space: nowrap;
  transition: opacity var(--transition-base);
}

.sidebar.collapsed .nav-item {
  padding: 2px 8px;
}

.sidebar.collapsed .nav-item-inner {
  padding: 10px;
  justify-content: center;
}

.sidebar.collapsed .nav-name,
.sidebar.collapsed .nav-label {
  opacity: 0;
  width: 0;
  overflow: hidden;
}

/* 侧面折叠按钮 */
.sidebar-footer {
  padding: 12px;
  border-top: 1px solid var(--sidebar-divider);
  flex-shrink: 0;
}

.collapse-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  border-radius: var(--radius-md);
  color: var(--sidebar-text);
  cursor: pointer;
  font-size: var(--font-sm);
  transition: all var(--transition-fast);
}

.collapse-btn:hover {
  background: var(--sidebar-hover-bg);
  color: var(--sidebar-text-active);
}

.collapse-btn svg {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.sidebar.collapsed .collapse-btn {
  justify-content: center;
  padding: 8px;
}

/* =============================================
   主区域
   ============================================= */
.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
  background: var(--color-bg);
}

/* 顶栏 */
.header {
  height: 64px;
  background: var(--color-surface);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-trigger {
  width: 36px;
  height: 36px;
  border: none;
  background: transparent;
  border-radius: var(--radius-md);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-secondary);
  font-size: 18px;
  transition: all var(--transition-fast);
}

.collapse-trigger:hover {
  background: var(--color-bg);
  color: var(--color-primary);
}

/* 面包屑导航 */
.page-hierarchy {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--font-base);
}

.hierarchy-root {
  color: var(--color-text-tertiary);
}

.hierarchy-sep {
  color: var(--color-border);
  font-size: var(--font-xs);
}

.hierarchy-current {
  color: var(--color-text-primary);
  font-weight: 500;
}

/* 顶栏右侧 */
.header-right {
  display: flex;
  align-items: center;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.header-icon-btn {
  position: relative;
  width: 36px;
  height: 36px;
  border: none;
  background: transparent;
  border-radius: var(--radius-md);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-secondary);
  transition: all var(--transition-fast);
}

.header-icon-btn:hover {
  background: var(--color-bg);
  color: var(--color-primary);
}

.notif-dot {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--color-danger);
  border: 2px solid var(--color-surface);
}

/* 用户资料 */
.user-profile {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 8px 4px 4px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--transition-fast);
  margin-left: 4px;
}

.user-profile:hover {
  background: var(--color-bg);
}

.avatar-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: var(--font-base);
  font-weight: 600;
  flex-shrink: 0;
}

.username {
  font-size: var(--font-base);
  color: var(--color-text-primary);
  font-weight: 500;
}

.dropdown-icon {
  font-size: 12px;
  color: var(--color-text-tertiary);
}

/* 内容区 */
.content-wrapper {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 0;
}

/* =============================================
   响应式
   ============================================= */
@media (max-width: 768px) {
  .sidebar:not(.collapsed) {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 1000;
    box-shadow: 4px 0 24px rgba(0, 0, 0, 0.3);
  }

  .username {
    display: none;
  }

  .header {
    padding: 0 16px;
  }
}
</style>

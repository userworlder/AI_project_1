import { createRouter, createWebHistory } from 'vue-router'

// ========== 路由表配置 ==========
const routes = [
  // ========== 登录页 - 无需鉴权 ==========
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: {
      title: '登录',
      requiresAuth: false  // 无需鉴权
    }
  },

  // ========== 后台布局 - 需要鉴权 ==========
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/components/layout/MainLayout.vue'),
    redirect: '/dashboard',
    meta: {
      requiresAuth: true  // 需要鉴权
    },
    children: [
      {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: {
          title: '仪表盘',
          requiresAuth: true
        }
      },
      {
        path: '/user',
        name: 'User',
        component: () => import('@/views/user/index.vue'),
        meta: {
          title: '用户管理',
          requiresAuth: true
        }
      },
      {
        path: '/skill',
        name: 'Skill',
        component: () => import('@/views/skill/index.vue'),
        meta: {
          title: '技能树管理',
          requiresAuth: true
        }
      },
      {
        path: '/record',
        name: 'Record',
        component: () => import('@/views/record/index.vue'),
        meta: {
          title: '学习记录',
          requiresAuth: true
        }
      },
      {
        path: '/ai',
        name: 'AI',
        component: () => import('@/views/ai/index.vue'),
        meta: {
          title: 'AI功能管理',
          requiresAuth: true
        }
      },
      {
        path: '/order',
        name: 'Order',
        component: () => import('@/views/order/index.vue'),
        meta: {
          title: '订单管理',
          requiresAuth: true
        }
      },
      {
        path: '/counter',
        name: 'Counter',
        component: () => import('@/views/counter/index.vue'),
        meta: {
          title: '计数器',
          requiresAuth: true
        }
      },
      {
        path: '/user-form',
        name: 'UserForm',
        component: () => import('@/views/user-form/index.vue'),
        meta: {
          title: '用户表单',
          requiresAuth: true
        }
      }
    ]
  },

  // ========== 404 兜底路由 - 通配符匹配所有未定义路径 ==========
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard',
    meta: {
      title: '页面未找到',
      requiresAuth: false
    }
  }
]

// ========== 创建路由实例 ==========
const router = createRouter({
  history: createWebHistory(),
  routes
})

// ========== 全局前置导航守卫 ==========
router.beforeEach((to, from, next) => {
  // 1. 动态设置页面标题
  const title = to.meta.title || '页面'
  document.title = `${title} - AI伴学管理后台`

  // 2. 判断目标路由是否需要鉴权
  const requiresAuth = to.meta.requiresAuth !== false

  // 3. 获取登录状态（从 localStorage 读取，与 Pinia 保持同步）
  // 注意：在路由守卫中不能直接使用 useUserStore()，因为 Pinia 需要在应用实例创建后才能使用
  // 使用 localStorage 作为判断依据，Pinia 会在初始化时从 localStorage 恢复状态
  const hasToken = !!localStorage.getItem('admin_token')

  // 4. 核心权限控制逻辑
  if (hasToken) {
    // 已登录
    if (to.path === '/login') {
      // 已登录且访问登录页 → 跳转到仪表盘
      next('/dashboard')
    } else {
      // 已登录访问其他页面 → 正常放行
      next()
    }
  } else {
    // 未登录
    if (!requiresAuth) {
      // 不需要鉴权的页面 → 正常放行
      next()
    } else {
      // 需要鉴权但没有 Token → 跳转到登录页
      next('/login')
    }
  }
})

// ========== 全局后置导航守卫（可选，用于页面切换后的操作） ==========
router.afterEach((to, from) => {
  // 可用于记录访问日志等操作
  console.log(`路由跳转: ${from.path} → ${to.path}`)
})

export default router

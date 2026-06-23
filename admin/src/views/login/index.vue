<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const form = ref({
  username: '',
  password: ''
})

const loading = ref(false)

// ========== 登录处理 ==========
const handleLogin = async () => {
  // 1. 表单验证
  if (!form.value.username || !form.value.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }

  loading.value = true

  try {
    // 2. 调用 userStore.login 完成登录
    await userStore.login(form.value)

    // 3. 弹出成功提示
    ElMessage.success('登录成功！')

    // 4. 编程式导航跳转到仪表盘
    router.push('/dashboard')
  } catch (error) {
    // 错误处理
    console.error('登录失败:', error)

    if (error.response) {
      // 后端返回错误
      const errMsg = error.response.data?.message || error.response.statusText
      ElMessage.error(`登录失败: ${errMsg}`)
    } else {
      // 网络错误（已在 store 中处理模拟登录）
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <!-- 背景装饰 -->
    <div class="bg-decoration">
      <div class="bg-circle bg-circle-1"></div>
      <div class="bg-circle bg-circle-2"></div>
      <div class="bg-circle bg-circle-3"></div>
    </div>

    <div class="login-wrapper">
      <!-- 标题 -->
      <div class="login-header">
        <div class="brand-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
            <path d="M12 2L2 7v10l10 5 10-5V7L12 2z" fill="currentColor" opacity="0.3"/>
            <path d="M12 2L2 7v2l10-5 10 5V7L12 2z" fill="currentColor"/>
            <path d="M2 17l10 5 10-5v-3L12 14 2 11v6z" fill="currentColor" opacity="0.2"/>
          </svg>
        </div>
        <h1 class="title">AI伴学平台</h1>
        <p class="subtitle">管理后台</p>
      </div>

      <!-- 表单 -->
      <el-form class="login-form" :model="form" @keyup.enter="handleLogin">
        <el-form-item>
          <el-input
            v-model="form.username"
            placeholder="请输入用户名"
            :prefix-icon="User"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="请输入密码"
            :prefix-icon="Lock"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            登 录
          </el-button>
        </el-form-item>

        <div class="tips">
          <p>提示：后端未启动时将自动使用模拟登录</p>
        </div>

        <div class="register-link">
          <span>还没有账号？</span>
          <el-button type="primary" link @click="router.push('/register')">立即注册</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%);
  padding: 20px;
  position: relative;
  overflow: hidden;
}

/* 背景装饰圆 */
.bg-decoration {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.bg-circle {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
}

.bg-circle-1 {
  width: 400px;
  height: 400px;
  background: rgba(99, 102, 241, 0.15);
  top: -100px;
  right: -100px;
}

.bg-circle-2 {
  width: 300px;
  height: 300px;
  background: rgba(20, 184, 166, 0.1);
  bottom: -50px;
  left: -50px;
}

.bg-circle-3 {
  width: 200px;
  height: 200px;
  background: rgba(99, 102, 241, 0.08);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.login-wrapper {
  width: 100%;
  max-width: 420px;
  background: rgba(255, 255, 255, 0.98);
  border-radius: var(--radius-xl);
  padding: 48px 40px;
  box-shadow: var(--shadow-xl);
  position: relative;
  z-index: 1;
  backdrop-filter: blur(20px);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.brand-icon {
  width: 56px;
  height: 56px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-bottom: 20px;
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 6px;
  letter-spacing: 1px;
}

.subtitle {
  color: var(--color-text-tertiary);
  font-size: var(--font-md);
  font-weight: 400;
}

.login-form {
  width: 100%;
}

.login-form :deep(.el-form-item) {
  margin-bottom: 22px;
}

.login-form :deep(.el-input__wrapper) {
  border-radius: var(--radius-md);
  padding: 4px 16px;
}

.login-form :deep(.el-input__inner) {
  height: 44px;
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: var(--font-lg);
  border-radius: var(--radius-md);
  letter-spacing: 4px;
  margin-top: 4px;
}

.tips {
  text-align: center;
  margin-top: 20px;
}

.tips p {
  color: var(--color-text-tertiary);
  font-size: var(--font-xs);
  margin: 0;
}

.register-link {
  text-align: center;
  margin-top: 16px;
  font-size: var(--font-base);
  color: var(--color-text-tertiary);
}
</style>

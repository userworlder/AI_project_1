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
    <div class="login-wrapper">
      <div class="login-header">
        <h1 class="title">AI伴学平台</h1>
        <p class="subtitle">管理后台登录</p>
      </div>

      <el-form class="login-form" :model="form" @keyup.enter="handleLogin">
        <el-form-item>
          <el-input
            v-model="form.username"
            placeholder="用户名"
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
            placeholder="密码"
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
            登录
          </el-button>
        </el-form-item>

        <!-- 提示信息 -->
        <div class="tips">
          <p>提示：后端未启动时将自动使用模拟登录</p>
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-wrapper {
  width: 100%;
  max-width: 420px;
  background: #fff;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.title {
  font-size: 32px;
  font-weight: bold;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 8px;
}

.subtitle {
  color: #999;
  font-size: 14px;
}

.login-form {
  width: 100%;
}

.login-form :deep(.el-form-item) {
  margin-bottom: 20px;
}

.login-form :deep(.el-input) {
  border-radius: 8px;
}

.login-btn {
  width: 100%;
  height: 48px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border: none;
  font-size: 16px;
  border-radius: 8px;
}

.login-btn:hover {
  opacity: 0.9;
}

.tips {
  text-align: center;
  margin-top: 16px;
}

.tips p {
  color: #999;
  font-size: 12px;
  margin: 0;
}
</style>

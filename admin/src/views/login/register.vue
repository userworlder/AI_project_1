<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { User, Lock, Message, Phone } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()

const form = ref({
  username: '',
  password: '',
  confirmPassword: '',
  nickname: '',
  email: '',
  phone: ''
})

const loading = ref(false)
const formRef = ref(null)

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名为 3-20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 30, message: '密码为 6-30 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== form.value.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  nickname: [
    { min: 1, max: 20, message: '昵称为 1-20 个字符', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      await request({
        url: '/auth/register',
        method: 'post',
        data: {
          username: form.value.username,
          password: form.value.password,
          nickname: form.value.nickname || form.value.username,
          email: form.value.email || undefined,
          phone: form.value.phone || undefined
        }
      })
      ElMessage.success('注册成功，请登录！')
      router.push('/login')
    } catch (error) {
      console.error('注册失败:', error)
      // 后端未启动时给出友好提示
      if (!error.response) {
        ElMessage.warning('后端服务未启动，注册功能暂不可用，请稍后再试')
        return
      }
      const errMsg = error.response?.data?.message || error.message || '注册失败'
      ElMessage.error(errMsg)
    } finally {
      loading.value = false
    }
  })
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<template>
  <div class="register-container">
    <!-- 背景装饰 -->
    <div class="bg-decoration">
      <div class="bg-circle bg-circle-1"></div>
      <div class="bg-circle bg-circle-2"></div>
      <div class="bg-circle bg-circle-3"></div>
    </div>

    <div class="register-wrapper">
      <!-- 标题 -->
      <div class="register-header">
        <div class="brand-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
            <path d="M12 2L2 7v10l10 5 10-5V7L12 2z" fill="currentColor" opacity="0.3"/>
            <path d="M12 2L2 7v2l10-5 10 5V7L12 2z" fill="currentColor"/>
            <path d="M2 17l10 5 10-5v-3L12 14 2 11v6z" fill="currentColor" opacity="0.2"/>
          </svg>
        </div>
        <h1 class="title">注册账号</h1>
        <p class="subtitle">加入 AI伴学平台</p>
      </div>

      <!-- 表单 -->
      <el-form
        ref="formRef"
        class="register-form"
        :model="form"
        :rules="rules"
        @keyup.enter="handleRegister"
      >
        <el-form-item prop="username">
          <el-input
            v-model="form.username"
            placeholder="请输入用户名 *"
            :prefix-icon="User"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item prop="nickname">
          <el-input
            v-model="form.nickname"
            placeholder="请输入昵称"
            :prefix-icon="User"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item prop="email">
          <el-input
            v-model="form.email"
            placeholder="请输入邮箱"
            :prefix-icon="Message"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item prop="phone">
          <el-input
            v-model="form.phone"
            placeholder="请输入手机号"
            :prefix-icon="Phone"
            size="large"
            clearable
            maxlength="11"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="请输入密码 *"
            :prefix-icon="Lock"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <el-input
            v-model="form.confirmPassword"
            type="password"
            show-password
            placeholder="请确认密码 *"
            :prefix-icon="Lock"
            size="large"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="register-btn"
            :loading="loading"
            @click="handleRegister"
          >
            注 册
          </el-button>
        </el-form-item>

        <div class="login-link">
          <span>已有账号？</span>
          <el-button type="primary" link @click="goToLogin">立即登录</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<style scoped>
.register-container {
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

.register-wrapper {
  width: 100%;
  max-width: 440px;
  background: rgba(255, 255, 255, 0.98);
  border-radius: var(--radius-xl);
  padding: 40px 36px;
  box-shadow: var(--shadow-xl);
  position: relative;
  z-index: 1;
  backdrop-filter: blur(20px);
}

.register-header {
  text-align: center;
  margin-bottom: 32px;
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
  margin-bottom: 16px;
}

.title {
  font-size: 26px;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 4px;
  letter-spacing: 1px;
}

.subtitle {
  color: var(--color-text-tertiary);
  font-size: var(--font-md);
  font-weight: 400;
}

.register-form {
  width: 100%;
}

.register-form :deep(.el-form-item) {
  margin-bottom: 20px;
}

.register-form :deep(.el-input__wrapper) {
  border-radius: var(--radius-md);
  padding: 4px 16px;
}

.register-form :deep(.el-input__inner) {
  height: 44px;
}

.register-btn {
  width: 100%;
  height: 48px;
  font-size: var(--font-lg);
  border-radius: var(--radius-md);
  letter-spacing: 4px;
  margin-top: 4px;
}

.login-link {
  text-align: center;
  margin-top: 16px;
  font-size: var(--font-base);
  color: var(--color-text-tertiary);
}
</style>

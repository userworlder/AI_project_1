<template>
  <div class="page-container">
    <div class="page-header">
      <h2>用户信息表单</h2>
      <span class="page-desc">reactive 响应式示例</span>
    </div>

    <el-card class="demo-card" shadow="never">
      <!-- 表单区域 -->
      <div class="form-area">
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-width="100px"
          class="user-form"
        >
          <el-form-item label="昵称" prop="nickname">
            <el-input
              v-model="form.nickname"
              placeholder="请输入昵称"
              clearable
            />
          </el-form-item>

          <el-form-item label="手机号" prop="phone">
            <el-input
              v-model="form.phone"
              placeholder="请输入手机号"
              maxlength="11"
              clearable
            />
          </el-form-item>

          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model="form.email"
              placeholder="请输入邮箱"
              clearable
            />
          </el-form-item>

          <el-form-item label="性别" prop="gender">
            <el-radio-group v-model="form.gender">
              <el-radio label="1">男</el-radio>
              <el-radio label="2">女</el-radio>
              <el-radio label="0">保密</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="系统角色" prop="role">
            <el-select
              v-model="form.role"
              placeholder="请选择角色"
              style="width: 100%"
            >
              <el-option label="管理员" value="admin" />
              <el-option label="教师" value="teacher" />
              <el-option label="学生" value="student" />
            </el-select>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" @click="submitForm">提交</el-button>
            <el-button @click="resetForm">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- reactive 使用说明 -->
      <el-divider>ref 与 reactive 的区别</el-divider>
      <div class="explanation">
        <el-alert
          title="reactive 使用场景"
          type="info"
          :closable="false"
          description="reactive 用于定义复杂类型数据（对象、数组）。直接返回响应式代理对象，在 JavaScript 和模板中都可以直接访问和修改属性，无需使用 .value。"
        />
        <div class="code-example">
          <pre><code>// ========== reactive 响应式对象 ==========
// reactive 用于定义复杂类型数据的响应式引用
const form = reactive({
  nickname: '',
  phone: '',
  email: '',
  gender: '0',
  role: ''
})

// 在 JavaScript 中直接访问/修改属性（不需要 .value）
console.log(form.nickname)  // ''
form.nickname = '张三'       // 直接修改

// 在模板中也是直接使用
// &lt;el-input v-model="form.nickname" /&gt;</code></pre>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElCard, ElForm, ElFormItem, ElInput, ElRadioGroup, ElRadio, ElSelect, ElOption, ElButton, ElDivider, ElAlert, ElMessage } from 'element-plus'

const formRef = ref(null)

const form = reactive({
  nickname: '',
  phone: '',
  email: '',
  gender: '0',
  role: ''
})

const rules = {
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度为 2-20 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  gender: [
    { required: true, message: '请选择性别', trigger: 'change' }
  ],
  role: [
    { required: true, message: '请选择系统角色', trigger: 'change' }
  ]
}

const submitForm = async () => {
  if (!formRef.value) return

  await formRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('表单提交成功！')
      console.log('提交的表单数据：', { ...form })
    } else {
      ElMessage.error('表单验证失败，请检查输入')
      return false
    }
  })
}

const resetForm = () => {
  formRef.value?.resetFields()
}
</script>

<style scoped>
.page-container {
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: var(--spacing-lg);
}

.page-header h2 {
  font-size: var(--font-2xl);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0;
}

.page-desc {
  font-size: var(--font-sm);
  color: var(--color-text-tertiary);
}

.demo-card {
  border-radius: var(--radius-lg);
}

.demo-card :deep(.el-card__body) {
  padding: 32px;
}

.form-area {
  max-width: 600px;
  margin: 0 auto;
  padding: 24px 0;
}

.user-form {
  margin-top: 10px;
}

.user-form :deep(.el-form-item) {
  margin-bottom: 22px;
}

.explanation {
  margin-top: 20px;
}

.code-example {
  margin-top: 15px;
  background: #1E293B;
  border-radius: var(--radius-md);
  padding: 20px;
  overflow-x: auto;
}

.code-example pre {
  margin: 0;
}

.code-example code {
  color: #A5B4FC;
  font-family: 'JetBrains Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.7;
}
</style>

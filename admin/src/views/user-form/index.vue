<template>
  <div class="page-container">
    <el-card shadow="hover">
      <template #header>
        <div class="page-header">
          <span class="page-title">用户信息表单 - reactive 响应式示例</span>
        </div>
      </template>

      <!-- 表单区域 -->
      <div class="form-area">
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-width="100px"
          class="user-form"
        >
          <!-- 昵称 -->
          <el-form-item label="昵称" prop="nickname">
            <el-input
              v-model="form.nickname"
              placeholder="请输入昵称"
              clearable
            />
          </el-form-item>

          <!-- 手机号 -->
          <el-form-item label="手机号" prop="phone">
            <el-input
              v-model="form.phone"
              placeholder="请输入手机号"
              maxlength="11"
              clearable
            />
          </el-form-item>

          <!-- 邮箱 -->
          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model="form.email"
              placeholder="请输入邮箱"
              clearable
            />
          </el-form-item>

          <!-- 性别 -->
          <el-form-item label="性别" prop="gender">
            <el-radio-group v-model="form.gender">
              <el-radio label="1">男</el-radio>
              <el-radio label="2">女</el-radio>
              <el-radio label="0">保密</el-radio>
            </el-radio-group>
          </el-form-item>

          <!-- 系统角色 -->
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

          <!-- 表单操作按钮 -->
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

// ========== 表单引用 ==========
const formRef = ref(null)

// ========== reactive 响应式对象 ==========
// 使用 reactive 定义表单对象，适用于复杂类型数据（对象、数组）
// reactive 直接返回响应式代理，无需 .value 访问
const form = reactive({
  nickname: '',   // 昵称
  phone: '',       // 手机号
  email: '',       // 邮箱
  gender: '0',     // 性别：0-保密，1-男，2-女
  role: ''         // 系统角色：admin-管理员，teacher-教师，student-学生
})

// ========== 表单校验规则 ==========
const rules = {
  // 昵称：必填
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度为 2-20 个字符', trigger: 'blur' }
  ],
  // 手机号：必填 + 11位手机号格式
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ],
  // 邮箱：必填 + 标准邮箱格式
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  // 性别：必填
  gender: [
    { required: true, message: '请选择性别', trigger: 'change' }
  ],
  // 系统角色：必填
  role: [
    { required: true, message: '请选择系统角色', trigger: 'change' }
  ]
}

// ========== 表单提交 ==========
const submitForm = async () => {
  // 触发表单验证
  if (!formRef.value) return

  await formRef.value.validate((valid) => {
    if (valid) {
      // 验证通过，弹出成功提示
      ElMessage.success('表单提交成功！')
      console.log('提交的表单数据：', { ...form })
    } else {
      // 验证失败
      ElMessage.error('表单验证失败，请检查输入')
      return false
    }
  })
}

// ========== 表单重置 ==========
const resetForm = () => {
  // 重置表单字段值和验证状态
  formRef.value?.resetFields()
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.page-title {
  font-size: 16px;
  font-weight: 600;
}

.form-area {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px 0;
}

.user-form {
  margin-top: 10px;
}

.explanation {
  margin-top: 20px;
}

.code-example {
  margin-top: 15px;
  background: #1e1e1e;
  border-radius: 8px;
  padding: 15px;
  overflow-x: auto;
}

.code-example pre {
  margin: 0;
}

.code-example code {
  color: #9cdcfe;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.5;
}
</style>

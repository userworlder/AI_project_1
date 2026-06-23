<script setup>
import { ref, onMounted } from 'vue'
import { Plus, Edit, Delete, Search, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserList, createUser, updateUser, deleteUser } from '@/api/user'

// ========== 状态定义 ==========
// 用户列表数据
const tableData = ref([])

// 列表加载状态
const loading = ref(false)

// 搜索关键词
const searchQuery = ref('')

// 分页配置
const pagination = ref({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

// ========== 弹窗与表单状态 ==========
// 弹窗显示状态
const showModal = ref(false)

// 表单引用（用于触发表单验证）
const formRef = ref(null)

// 弹窗标题
const title = ref('新增用户')

// 编辑模式下的用户 ID
const editingId = ref(null)

// 表单数据
const form = ref({
  username: '',
  nickname: '',
  email: '',
  role: 'student'
})

// 提交按钮加载状态
const submitLoading = ref(false)

// ========== 表单校验规则 ==========
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 20, message: '用户名为 2-20 个字符', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 1, max: 20, message: '昵称为 1-20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

// ========== 角色选项 ==========
const roleOptions = [
  { label: '管理员', value: 'admin' },
  { label: '教师', value: 'teacher' },
  { label: '学生', value: 'student' }
]

// ========== 表格列配置 ==========
const tableColumns = [
  { prop: 'username', label: '用户名', align: 'center' },
  { prop: 'nickname', label: '昵称', align: 'center' },
  { prop: 'email', label: '邮箱', align: 'center' },
  { prop: 'role', label: '角色', align: 'center', formatter: (row) => {
    const map = { admin: '管理员', teacher: '教师', student: '学生' }
    return map[row.role] || row.role
  }},
  { prop: 'createdAt', label: '创建时间', align: 'center', width: 180 }
]

// ========== 生命周期 ==========
onMounted(() => {
  fetchUserList()
})

// ========== 方法函数 ==========

// 获取用户列表
const fetchUserList = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.value.currentPage,
      pageSize: pagination.value.pageSize,
      keyword: searchQuery.value.trim()
    }
    const response = await getUserList(params)
    tableData.value = response.list || []
    pagination.value.total = response.total || 0
  } catch (error) {
    console.error('获取用户列表失败:', error)
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索用户
const handleSearch = () => {
  pagination.value.currentPage = 1
  fetchUserList()
}

// 页码切换
const handlePageChange = (page) => {
  pagination.value.currentPage = page
  fetchUserList()
}

// 每页条数切换
const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.currentPage = 1
  fetchUserList()
}

// 刷新列表
const handleRefresh = () => {
  fetchUserList()
  ElMessage.success('数据已刷新')
}

// 点击新增按钮
const handleAdd = () => {
  title.value = '新增用户'
  editingId.value = null
  resetForm()
  showModal.value = true
}

// 编辑用户
const handleEdit = (row) => {
  title.value = '编辑用户'
  editingId.value = row.id
  form.value = {
    username: row.username,
    nickname: row.nickname,
    email: row.email,
    role: row.role
  }
  showModal.value = true
}

// 删除用户
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除用户「${row.nickname}」吗？`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await deleteUser(row.id)
      ElMessage.success('删除成功')
      // 刷新列表
      fetchUserList()
    } catch (error) {
      console.error('删除用户失败:', error)
      ElMessage.error('删除用户失败')
    }
  }).catch(() => {
    // 用户取消删除
  })
}

// 重置表单
const resetForm = () => {
  form.value = {
    username: '',
    nickname: '',
    email: '',
    role: 'student'
  }
  formRef.value?.resetFields()
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) {
      return false
    }

    submitLoading.value = true

    try {
      if (editingId.value === null) {
        // 新增用户
        await createUser(form.value)
        ElMessage.success('新增用户成功')
      } else {
        // 编辑用户
        await updateUser(editingId.value, form.value)
        ElMessage.success('编辑用户成功')
      }

      // 关闭弹窗
      showModal.value = false

      // 重置表单
      resetForm()

      // 刷新列表
      fetchUserList()
    } catch (error) {
      console.error('提交失败:', error)
      ElMessage.error('操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}

// 弹窗关闭时自动重置表单
const handleDialogClose = () => {
  resetForm()
}
</script>

<template>
  <div class="user-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>用户管理</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">新增用户</el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-input
        v-model="searchQuery"
        placeholder="搜索用户名、昵称或邮箱"
        prefix-icon="Search"
        class="search-input"
        clearable
        @keyup.enter="handleSearch"
      />
      <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
      <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table
        :data="tableData"
        border
        stripe
        style="width: 100%"
        v-loading="loading"
      >
        <el-table-column
          v-for="col in tableColumns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
          :align="col.align || 'left'"
          :width="col.width"
        >
          <template #default="scope">
            {{ col.formatter ? col.formatter(scope.row) : scope.row[col.prop] }}
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="160" fixed="right">
          <template #default="scope">
            <el-button type="primary" link size="small" :icon="Edit" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button type="danger" link size="small" :icon="Delete" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        :current-page="pagination.currentPage"
        :page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      :title="title"
      v-model="showModal"
      width="500px"
      :before-close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="80px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="form.username"
            placeholder="请输入用户名"
            clearable
          />
        </el-form-item>

        <el-form-item label="昵称" prop="nickname">
          <el-input
            v-model="form.nickname"
            placeholder="请输入昵称"
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

        <el-form-item label="角色" prop="role">
          <el-select
            v-model="form.role"
            placeholder="请选择角色"
            style="width: 100%"
          >
            <el-option
              v-for="item in roleOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showModal = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitLoading"
          @click="handleSubmit"
        >
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.user-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.search-card {
  margin-bottom: 20px;
  display: flex;
  gap: 12px;
  align-items: center;
}

.search-input {
  width: 300px;
}

.table-card {
  padding: 20px;
}

.table-card :deep(.el-pagination) {
  margin-top: 20px;
  text-align: right;
}
</style>
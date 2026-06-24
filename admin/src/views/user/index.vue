<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { Plus, Edit, Delete, Search, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getUserList, createUser, updateUser, deleteUser } from '@/api/user'

// ========== Mock 数据兜底 ==========
const mockUserList = [
  { id: 1, username: 'admin', nickname: '管理员', email: 'admin@example.com', role: 'admin', createTime: '2024-01-01 00:00:00' },
  { id: 2, username: 'zhangsan', nickname: '张三', email: 'zhangsan@example.com', role: 'student', createTime: '2024-01-15 10:30:00' },
  { id: 3, username: 'lisi', nickname: '李四', email: 'lisi@example.com', role: 'student', createTime: '2024-01-16 14:20:00' },
  { id: 4, username: 'wangwu', nickname: '王五', email: 'wangwu@example.com', role: 'teacher', createTime: '2024-01-17 09:15:00' }
]

// ========== 状态定义 ==========
const tableData = ref([])
const loading = ref(false)
const searchQuery = ref('')

const pagination = ref({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

const showModal = ref(false)
const formRef = ref(null)
const title = ref('新增用户')
const editingId = ref(null)

const form = ref({
  username: '',
  nickname: '',
  email: '',
  password: '',
  role: 'student'
})

const submitLoading = ref(false)

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 2, max: 20, message: '用户名为 2-20 个字符', trigger: 'blur' }
  ],
  password: [
    { min: 6, max: 30, message: '密码为 6-30 个字符', trigger: 'blur' }
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

const roleOptions = [
  { label: '管理员', value: 'admin' },
  { label: '教师', value: 'teacher' },
  { label: '学生', value: 'student' }
]

const tableColumns = [
  { prop: 'username', label: '用户名', align: 'center' },
  { prop: 'nickname', label: '昵称', align: 'center' },
  { prop: 'email', label: '邮箱', align: 'center', minWidth: 200 },
  { prop: 'role', label: '角色', align: 'center', formatter: (row) => {
    const map = { admin: '管理员', teacher: '教师', student: '学生' }
    return map[row.role] || row.role || '学生'
  }},
  { prop: 'createTime', label: '创建时间', align: 'center', width: 180 }
]

onMounted(() => {
  fetchUserList()
})

const fetchUserList = async () => {
  loading.value = true
  try {
    // 模拟登录时跳过真实 API 请求
    const userStore = useUserStore()
    if (userStore.isMockLogin) {
      tableData.value = mockUserList
      pagination.value.total = mockUserList.length
      return
    }
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

const handleSearch = () => {
  pagination.value.currentPage = 1
  fetchUserList()
}

const handlePageChange = (page) => {
  pagination.value.currentPage = page
  fetchUserList()
}

const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.currentPage = 1
  fetchUserList()
}

const handleRefresh = () => {
  fetchUserList()
  ElMessage.success('数据已刷新')
}

const handleAdd = () => {
  title.value = '新增用户'
  editingId.value = null
  resetForm()
  showModal.value = true
}

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
      fetchUserList()
    } catch (error) {
      console.error('删除用户失败:', error)
      ElMessage.error('删除用户失败')
    }
  }).catch(() => {
  })
}

const resetForm = () => {
  form.value = {
    username: '',
    nickname: '',
    email: '',
    password: '',
    role: 'student'
  }
  formRef.value?.resetFields()
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) {
      return false
    }

    submitLoading.value = true

    try {
      if (editingId.value === null) {
        await createUser(form.value)
        ElMessage.success('新增用户成功')
      } else {
        await updateUser(editingId.value, form.value)
        ElMessage.success('编辑用户成功')
      }
      showModal.value = false
      resetForm()
      fetchUserList()
    } catch (error) {
      console.error('提交失败:', error)
      ElMessage.error('操作失败')
    } finally {
      submitLoading.value = false
    }
  })
}

const handleDialogClose = () => {
  resetForm()
}
</script>

<template>
  <div class="user-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="page-title-group">
        <h2>用户管理</h2>
        <span class="page-desc">管理系统中的所有用户账号</span>
      </div>
      <el-button type="primary" :icon="Plus" @click="handleAdd">新增用户</el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <el-input
          v-model="searchQuery"
          placeholder="搜索用户名、昵称或邮箱"
          :prefix-icon="Search"
          class="search-input"
          clearable
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
      </div>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card" shadow="never">
      <el-table
        :data="tableData"
        style="width: 100%"
        v-loading="loading"
        :header-cell-style="{ background: 'var(--color-bg)', color: 'var(--color-text-primary)', fontWeight: 600 }"
      >
        <el-table-column
          v-for="col in tableColumns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
          :align="col.align || 'left'"
          :width="col.width"
          :min-width="col.minWidth"
        >
          <template #default="scope">
            <span v-if="col.prop === 'role'">
              <el-tag
                :type="scope.row.role === 'admin' ? 'danger' : scope.row.role === 'teacher' ? 'warning' : 'info'"
                size="small"
                effect="plain"
              >
                {{ col.formatter ? col.formatter(scope.row) : scope.row[col.prop] }}
              </el-tag>
            </span>
            <span v-else>
              {{ col.formatter ? col.formatter(scope.row) : scope.row[col.prop] }}
            </span>
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
      <div class="pagination-wrap">
        <el-pagination
          :current-page="pagination.currentPage"
          :page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      :title="title"
      v-model="showModal"
      width="520px"
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

        <el-form-item label="密码" prop="password" v-if="editingId === null">
          <el-input
            v-model="form.password"
            type="password"
            show-password
            placeholder="请输入密码"
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
          确 定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.user-page {
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

/* 页面头部 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-lg);
}

.page-title-group {
  display: flex;
  align-items: baseline;
  gap: 12px;
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

/* 搜索栏 */
.search-card {
  margin-bottom: var(--spacing-lg);
  border-radius: var(--radius-lg);
  --el-card-padding: 16px 20px;
}

.search-bar {
  display: flex;
  gap: 12px;
  align-items: center;
}

.search-input {
  width: 320px;
}

/* 表格卡片 */
.table-card {
  border-radius: var(--radius-lg);
  --el-card-padding: 0;
}

.table-card :deep(.el-table) {
  border: none;
}

.table-card :deep(.el-table th.el-table__cell) {
  background: var(--color-bg) !important;
}

.table-card :deep(.el-table__body tr:hover > td) {
  background: var(--color-primary-bg) !important;
}

.pagination-wrap {
  padding: 16px 20px;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid var(--color-border-light);
}
</style>

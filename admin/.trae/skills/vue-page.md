---
name: vue-page-standard
description: 按照项目规范创建Vue3业务列表页面，包含标准布局、搜索栏、表格、分页
globs: ["src/views/**/*.vue"]
alwaysApply: false
---

# Vue3 业务页面开发规范
## 适用场景
创建管理后台业务列表页，统一页面结构、交互逻辑与代码风格。

## 文件放置规则
- 页面文件放入 `src/views/模块名/` 目录
- 文件名使用大驼峰命名，如 `OrderList.vue`
- 对应 API 同步封装到 `src/api/模块名.js` 中

## 标准代码模板
```vue
<template>
  <div class="page-container">
    <el-card shadow="hover">
      <template #header>
        <div class="page-header">
          <span class="page-title">{{ pageTitle }}</span>
        </div>
      </template>

      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input v-model="searchForm.keyword" placeholder="请输入关键词" clearable style="width: 200px; margin-right: 10px" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button type="success" style="margin-left: auto" @click="handleAdd">新增</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table :data="tableData" border style="margin-top: 15px" v-loading="loading">
        <el-table-column prop="name" label="名称" align="center" />
        <el-table-column prop="status" label="状态" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" align="center" width="180" />
        <el-table-column label="操作" align="center" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="pagination.pageNum"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="getList"
          @current-change="getList"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getList, deleteById } from '@/api/模块名'

const pageTitle = ref('页面标题')
const loading = ref(false)
const tableData = ref([])

const searchForm = reactive({
  keyword: ''
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 获取列表数据
const getList = async () => {
  loading.value = true
  try {
    const res = await getList({
      ...searchForm,
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize
    })
    tableData.value = res.data.records
    pagination.total = res.data.total
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  getList()
}

// 重置
const handleReset = () => {
  searchForm.keyword = ''
  handleSearch()
}

// 新增
const handleAdd = () => {
  // 新增弹窗逻辑
}

// 编辑
const handleEdit = (row) => {
  // 编辑弹窗逻辑
}

// 删除
const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该数据吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await deleteById(row.id)
    ElMessage.success('删除成功')
    getList()
  })
}

onMounted(() => {
  getList()
})
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
.search-bar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}
.pagination-wrap {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
编码约束
必须使用 <script setup> Composition API，禁止 Options API
全程使用 JavaScript，禁止引入 TypeScript
样式必须加 scoped，禁止全局样式污染
API 请求必须调用 api/ 目录封装方法，禁止组件内直接写 axios
状态列必须用 el-tag 区分颜色
删除操作必须加二次确认弹窗
数据加载必须加 v-loading 加载态
参考文件
页面参考：src/views/user/index.vue
API 封装参考：src/api/user.js
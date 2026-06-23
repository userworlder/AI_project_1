<script setup>
import { ref, computed } from 'vue'
import { mockRecordList } from '@/mock/record'
import { Search, Refresh } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// ========== 状态定义 ==========
// 全量数据（来自 Mock）
const allData = ref(mockRecordList)

// 搜索关键词
const searchKeyword = ref('')

// 分页配置
const pagination = ref({
  currentPage: 1,
  pageSize: 10
})

// ========== 计算属性 ==========
// 根据关键词过滤全量数据（模糊搜索）
const filteredData = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase()
  if (!keyword) {
    return allData.value
  }
  return allData.value.filter(item =>
    item.username.toLowerCase().includes(keyword)
  )
})

// 过滤后的总数据条数
const total = computed(() => filteredData.value.length)

// 当前页展示的数据（切片实现）
const list = computed(() => {
  const start = (pagination.value.currentPage - 1) * pagination.value.pageSize
  const end = start + pagination.value.pageSize
  return filteredData.value.slice(start, end)
})

// ========== 方法函数 ==========
// 搜索（重置页码为第1页）
const handleSearch = () => {
  pagination.value.currentPage = 1
}

// 清空搜索
const handleClear = () => {
  searchKeyword.value = ''
  pagination.value.currentPage = 1
}

// 页码切换
const handlePageChange = (page) => {
  pagination.value.currentPage = page
}

// 每页条数切换
const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.currentPage = 1
}

// 回车触发搜索
const handleKeyUp = (e) => {
  if (e.key === 'Enter') {
    handleSearch()
  }
}

// 刷新数据
const handleRefresh = () => {
  ElMessage.success('数据已刷新')
}

// ========== 表格列配置 ==========
const tableColumns = [
  { prop: 'id', label: 'ID', width: 80, align: 'center' },
  { prop: 'username', label: '用户名', align: 'center' },
  { prop: 'skill', label: '学习技能', align: 'center' },
  { prop: 'duration', label: '学习时长(分钟)', width: 140, align: 'center' },
  { prop: 'score', label: '得分', width: 100, align: 'center' },
  {
    prop: 'createdAt',
    label: '学习时间',
    width: 180,
    align: 'center'
  }
]

// 得分格式化
const formatScore = (score) => {
  if (score >= 90) return { text: score, type: 'success' }
  if (score >= 70) return { text: score, type: 'warning' }
  return { text: score, type: 'danger' }
}
</script>

<template>
  <div class="page-container">
    <el-card shadow="hover">
      <template #header>
        <div class="page-header">
          <span class="page-title">学习记录</span>
        </div>
      </template>

      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="请输入用户名关键词搜索"
          prefix-icon="Search"
          clearable
          class="search-input"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table
        :data="list"
        border
        stripe
        style="margin-top: 15px"
        v-loading="false"
      >
        <el-table-column
          v-for="col in tableColumns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
          :width="col.width"
          :align="col.align || 'left'"
        >
          <!-- 得分列使用 el-tag 显示 -->
          <template #default="{ row }" v-if="col.prop === 'score'">
            <el-tag :type="formatScore(row.score).type">
              {{ formatScore(row.score).text }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

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
  gap: 12px;
}

.search-input {
  width: 300px;
}

.pagination-wrap {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>

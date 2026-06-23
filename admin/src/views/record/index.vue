<script setup>
import { ref, onMounted } from 'vue'
import { getRecordList } from '@/api/record'
import { Search, Refresh } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// ========== Mock 数据兜底 ==========
const mockRecordList = [
  { id: 1, username: '张三', skill: 'JavaScript 基础', duration: 120, score: 95, createdAt: '2024-01-15 10:30:00' },
  { id: 2, username: '李四', skill: 'Vue3 核心原理', duration: 180, score: 88, createdAt: '2024-01-16 14:20:00' },
  { id: 3, username: '王五', skill: 'Python 数据分析', duration: 90, score: 72, createdAt: '2024-01-17 09:15:00' },
  { id: 4, username: '赵六', skill: 'Spring Boot 实战', duration: 240, score: 91, createdAt: '2024-01-18 16:45:00' },
  { id: 5, username: '钱七', skill: 'TypeScript 进阶', duration: 150, score: 85, createdAt: '2024-01-19 11:00:00' },
  { id: 6, username: '孙八', skill: 'React 组件开发', duration: 200, score: 79, createdAt: '2024-01-20 13:30:00' },
  { id: 7, username: '周九', skill: 'Node.js 服务端开发', duration: 160, score: 83, createdAt: '2024-01-21 15:20:00' },
  { id: 8, username: '吴十', skill: 'Docker 容器化', duration: 100, score: 68, createdAt: '2024-01-22 10:00:00' },
  { id: 9, username: '郑十一', skill: 'MySQL 数据库优化', duration: 130, score: 90, createdAt: '2024-01-23 14:15:00' },
  { id: 10, username: '陈十二', skill: 'Redis 缓存实战', duration: 80, score: 76, createdAt: '2024-01-24 09:45:00' },
  { id: 11, username: '刘十三', skill: 'Git 版本控制', duration: 60, score: 92, createdAt: '2024-01-25 16:30:00' },
  { id: 12, username: '黄十四', skill: '微服务架构设计', duration: 220, score: 87, createdAt: '2024-01-26 11:20:00' }
]

// ========== 状态定义 ==========
const tableData = ref([])
const loading = ref(false)
const searchKeyword = ref('')

const pagination = ref({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

// ========== 方法函数 ==========
const fetchRecords = async () => {
  loading.value = true
  try {
    const response = await getRecordList({
      current: pagination.value.currentPage,
      size: pagination.value.pageSize
    })
    // 后端有数据就用后端数据
    if (response && response.records && response.records.length > 0) {
      tableData.value = response.records
      pagination.value.total = response.total || 0
    } else {
      throw new Error('no data')
    }
  } catch (error) {
    console.warn('获取学习记录失败，使用 Mock 数据:', error)
    // Mock：搜索过滤 + 分页
    let filtered = [...mockRecordList]
    if (searchKeyword.value.trim()) {
      const kw = searchKeyword.value.trim().toLowerCase()
      filtered = filtered.filter(item =>
        item.username.toLowerCase().includes(kw) ||
        item.skill.toLowerCase().includes(kw)
      )
    }
    pagination.value.total = filtered.length
    const start = (pagination.value.currentPage - 1) * pagination.value.pageSize
    tableData.value = filtered.slice(start, start + pagination.value.pageSize)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.value.currentPage = 1
  fetchRecords()
}

const handlePageChange = (page) => {
  pagination.value.currentPage = page
  fetchRecords()
}

const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.currentPage = 1
  fetchRecords()
}

const handleRefresh = () => {
  fetchRecords()
  ElMessage.success('数据已刷新')
}

const tableColumns = [
  { prop: 'id', label: 'ID', width: 80, align: 'center' },
  { prop: 'content', label: '学习内容', align: 'center', formatter: true },
  { prop: 'username', label: '用户名', align: 'center' },
  { prop: 'skill', label: '学习技能', align: 'center' },
  { prop: 'duration', label: '学习时长(分钟)', width: 140, align: 'center' },
  { prop: 'score', label: '得分', width: 100, align: 'center' },
  { prop: 'createTime', label: '学习时间', width: 180, align: 'center', formatter: true }
]

const formatScore = (score) => {
  if (score >= 90) return { text: score, type: 'success' }
  if (score >= 70) return { text: score, type: 'warning' }
  return { text: score, type: 'danger' }
}

onMounted(() => {
  fetchRecords()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <div class="title-group">
        <h2>学习记录</h2>
        <span class="page-desc">查看学生的学习历史</span>
      </div>
    </div>

    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="请输入用户名关键词搜索"
          :prefix-icon="Search"
          clearable
          class="search-input"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
      </div>
    </el-card>

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
          :prop="col.formatter ? undefined : col.prop"
          :label="col.label"
          :width="col.width"
          :align="col.align || 'left'"
        >
          <template #default="{ row }">
            <template v-if="col.prop === 'score'">
              <el-tag :type="formatScore(row.score).type" effect="plain">
                {{ formatScore(row.score).text }}
              </el-tag>
            </template>
            <template v-else-if="col.prop === 'content'">
              {{ row.content || row.skill || '-' }}
            </template>
            <template v-else-if="col.prop === 'createTime'">
              {{ row.createTime || row.createdAt || '-' }}
            </template>
            <template v-else>
              {{ row[col.prop] || '-' }}
            </template>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="pagination.currentPage"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
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
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: var(--spacing-lg);
}

.title-group {
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

.search-card {
  margin-bottom: var(--spacing-lg);
  border-radius: var(--radius-lg);
  --el-card-padding: 16px 20px;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 12px;
}

.search-input {
  width: 320px;
}

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

.pagination-wrap {
  padding: 16px 20px;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid var(--color-border-light);
}
</style>

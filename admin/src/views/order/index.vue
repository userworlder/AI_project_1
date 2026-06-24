<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '@/stores/user'
import { getOrderList, deleteOrder } from '@/api/order'

// ========== Mock 数据兜底 ==========
const mockOrderList = [
  { id: 1001, username: '张三', product: '灵思·AI学伴季卡', amount: 299, status: 'paid', createTime: '2024-01-15 10:30:00' },
  { id: 1002, username: '李四', product: '灵思·AI学伴月卡', amount: 99, status: 'pending', createTime: '2024-01-16 14:20:00' },
  { id: 1003, username: '王五', product: 'VIP年卡', amount: 999, status: 'completed', createTime: '2024-01-17 09:15:00' },
  { id: 1004, username: '赵六', product: '灵思·AI学伴季卡', amount: 299, status: 'cancelled', createTime: '2024-01-18 16:45:00' },
  { id: 1005, username: '钱七', product: '灵思·AI学伴月卡', amount: 99, status: 'paid', createTime: '2024-01-19 11:00:00' }
]
import { Search, Delete, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox, ElTable, ElTableColumn, ElPagination, ElInput, ElButton, ElSelect, ElOption } from 'element-plus'

const tableData = ref([])
const loading = ref(false)
const total = ref(0)

const searchForm = reactive({
  keyword: '',
  status: ''
})

const pagination = reactive({
  current: 1,
  size: 10
})

const statusOptions = [
  { label: '全部', value: '' },
  { label: '待支付', value: 'pending' },
  { label: '已支付', value: 'paid' },
  { label: '已完成', value: 'completed' },
  { label: '已取消', value: 'cancelled' }
]

const statusConfig = {
  'pending': { label: '待支付', color: '#F59E0B', bg: 'rgba(245,158,11,0.1)' },
  'paid': { label: '已支付', color: '#6366F1', bg: 'rgba(99,102,241,0.1)' },
  'completed': { label: '已完成', color: '#10B981', bg: 'rgba(16,185,129,0.1)' },
  'cancelled': { label: '已取消', color: '#EF4444', bg: 'rgba(239,68,68,0.1)' }
}

const getStatusConfig = (status) => {
  return statusConfig[status] || { label: status, color: '#94A3B8', bg: 'rgba(148,163,184,0.1)' }
}

const loadData = async () => {
  loading.value = true
  try {
    // 模拟登录时跳过真实 API 请求
    const userStore = useUserStore()
    if (userStore.isMockLogin) {
      tableData.value = mockOrderList
      total.value = mockOrderList.length
      return
    }
    const params = {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword,
      status: searchForm.status
    }
    const data = await getOrderList(params)
    // 支持 records 和 list 两种格式
    tableData.value = data.records || data.list || data || []
    total.value = data.total || 0
  } catch (error) {
    console.error('加载订单列表失败:', error)
    ElMessage.error('加载订单列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.current = 1
  loadData()
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.status = ''
  pagination.current = 1
  loadData()
}

const handlePageChange = (page) => {
  pagination.current = page
  loadData()
}

const handleSizeChange = (size) => {
  pagination.size = size
  pagination.current = 1
  loadData()
}

const handleDelete = async (id) => {
  try {
    await deleteOrder(id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    console.error('删除订单失败:', error)
    ElMessage.error('删除订单失败')
  }
}

const confirmDelete = (id) => {
  ElMessageBox.confirm(
    '确定要删除这个订单吗？',
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    handleDelete(id)
  }).catch(() => {
    ElMessage.info('已取消删除')
  })
}

loadData()
</script>

<template>
  <div class="order-container">
    <div class="page-header">
      <div class="title-group">
        <h2 class="title">订单管理</h2>
        <span class="page-desc">查看和管理平台所有订单</span>
      </div>
    </div>

    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <div class="search-group">
          <ElInput
            v-model="searchForm.keyword"
            placeholder="请输入订单号或用户昵称搜索"
            :prefix-icon="Search"
            class="search-input"
            @keyup.enter="handleSearch"
          />
        </div>

        <div class="search-group">
          <ElSelect
            v-model="searchForm.status"
            placeholder="订单状态"
            class="status-select"
          >
            <ElOption
              v-for="option in statusOptions"
              :key="option.value"
              :label="option.label"
              :value="option.value"
            />
          </ElSelect>
        </div>

        <div class="btn-group">
          <ElButton type="primary" :icon="Search" @click="handleSearch">搜索</ElButton>
          <ElButton :icon="Refresh" @click="handleReset">重置</ElButton>
        </div>
      </div>
    </el-card>

    <el-card class="table-card" shadow="never">
      <ElTable
        v-loading="loading"
        :data="tableData"
        style="width: 100%"
        :empty-text="loading ? '加载中...' : '暂无数据'"
        :header-cell-style="{ background: 'var(--color-bg)', color: 'var(--color-text-primary)', fontWeight: 600 }"
      >
        <ElTableColumn prop="orderNo" label="订单号" min-width="180" />
        <ElTableColumn prop="userNickname" label="用户昵称" min-width="120" />
        <ElTableColumn prop="amount" label="支付金额" min-width="120" align="right">
          <template #default="scope">
            <span style="font-weight: 600; color: var(--color-text-primary)">
              ¥{{ scope.row.amount?.toFixed(2) }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="status" label="状态" min-width="100" align="center">
          <template #default="scope">
            <span
              class="status-badge"
              :style="{
                background: getStatusConfig(scope.row.status).bg,
                color: getStatusConfig(scope.row.status).color
              }"
            >
              {{ getStatusConfig(scope.row.status).label }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="createTime" label="创建时间" min-width="160" />
        <ElTableColumn label="操作" min-width="120" align="center" fixed="right">
          <template #default="scope">
            <ElButton
              type="danger"
              size="small"
              text
              :icon="Delete"
              @click="confirmDelete(scope.row.id)"
            >
              删除
            </ElButton>
          </template>
        </ElTableColumn>
      </ElTable>

      <div class="pagination-wrapper">
        <ElPagination
          :current-page="pagination.current"
          :page-size="pagination.size"
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
.order-container {
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

.title {
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
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.search-group {
  display: flex;
  align-items: center;
}

.search-input {
  width: 300px;
}

.status-select {
  width: 150px;
}

.btn-group {
  display: flex;
  gap: 8px;
  margin-left: auto;
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

/* 状态徽章 */
.status-badge {
  display: inline-block;
  padding: 4px 14px;
  border-radius: var(--radius-full);
  font-size: var(--font-xs);
  font-weight: 600;
}

.pagination-wrapper {
  padding: 16px 20px;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid var(--color-border-light);
}
</style>

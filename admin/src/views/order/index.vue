<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { getOrderList, deleteOrder } from '@/api/order'
import { Search, Delete, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElTable, ElTableColumn, ElPagination, ElInput, ElButton, ElSelect, ElOption } from 'element-plus'

const router = useRouter()

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

const getStatusText = (status) => {
  const map = {
    'pending': '待支付',
    'paid': '已支付',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return map[status] || status
}

const getStatusClass = (status) => {
  const map = {
    'pending': 'status-pending',
    'paid': 'status-paid',
    'completed': 'status-completed',
    'cancelled': 'status-cancelled'
  }
  return map[status] || ''
}

const loadData = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword,
      status: searchForm.status
    }
    const data = await getOrderList(params)
    tableData.value = data.list || data
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
  ElMessage.confirm(
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
      <h2 class="title">订单管理</h2>
    </div>

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
        <ElButton type="primary" @click="handleSearch">
          <Search />
          搜索
        </ElButton>
        <ElButton @click="handleReset">
          <Refresh />
          重置
        </ElButton>
      </div>
    </div>

    <div class="table-wrapper">
      <ElTable
        v-loading="loading"
        :data="tableData"
        border
        style="width: 100%"
        :empty-text="loading ? '加载中...' : '暂无数据'"
      >
        <ElTableColumn
          prop="orderNo"
          label="订单号"
          min-width="180"
        />
        <ElTableColumn
          prop="userNickname"
          label="用户昵称"
          min-width="120"
        />
        <ElTableColumn
          prop="amount"
          label="支付金额"
          min-width="120"
          align="right"
          :formatter="(row) => `¥${row.amount.toFixed(2)}`"
        />
        <ElTableColumn
          prop="status"
          label="状态"
          min-width="100"
          align="center"
        >
          <template #default="scope">
            <span :class="['status-tag', getStatusClass(scope.row.status)]">
              {{ getStatusText(scope.row.status) }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn
          prop="createTime"
          label="创建时间"
          min-width="160"
        />
        <ElTableColumn
          label="操作"
          min-width="120"
          align="center"
          fixed="right"
        >
          <template #default="scope">
            <ElButton
              type="danger"
              size="small"
              :icon="Delete"
              @click="confirmDelete(scope.row.id)"
            >
              删除
            </ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </div>

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
  </div>
</template>

<style scoped>
.order-container {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  min-height: calc(100vh - 180px);
}

.page-header {
  margin-bottom: 20px;
}

.title {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
  padding: 16px 20px;
  background: #f8f9fa;
  border-radius: 8px;
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

.table-wrapper {
  margin-bottom: 20px;
}

.status-tag {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.status-pending {
  background: #fff7e6;
  color: #d48806;
}

.status-paid {
  background: #e6f7ff;
  color: #1890ff;
}

.status-completed {
  background: #f6ffed;
  color: #52c41a;
}

.status-cancelled {
  background: #fff1f0;
  color: #ff4d4f;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}
</style>

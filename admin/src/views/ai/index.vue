<script setup>import { ref, onMounted } from 'vue';
import { getAiList, deleteAi, getAiStats } from '@/api/ai';
import { Plus, Edit, Delete, Search, Refresh } from '@element-plus/icons-vue';
const tableData = ref([]);
const loading = ref(false);
const searchQuery = ref('');
const pagination = ref({
 currentPage: 1,
 pageSize: 10,
 total: 0
});
const showModal = ref(false);
const form = ref({
 id: null,
 name: '',
 model: '',
 apiKey: '',
 enabled: true,
 params: {}
});
const title = ref('添加AI配置');
const stats = ref({
 totalRequests: 0,
 successRate: 0,
 avgResponseTime: 0,
 todayRequests: 0
});
onMounted(() => {
 loadConfigs();
 loadStats();
});
const loadConfigs = async () => {
 loading.value = true;
 try {
 const data = await getAiList({
 page: pagination.value.currentPage,
 size: pagination.value.pageSize,
 keyword: searchQuery.value
 });
 tableData.value = data.list;
 pagination.value.total = data.total;
 }
 catch (error) {
 console.error('加载AI配置失败:', error);
 }
 finally {
 loading.value = false;
 }
};
const loadStats = async () => {
 try {
 stats.value = await getAiStats();
 }
 catch (error) {
 console.error('加载AI统计失败:', error);
 }
};
const handleSearch = () => {
 pagination.value.currentPage = 1;
 loadConfigs();
};
const handlePageChange = (page) => {
 pagination.value.currentPage = page;
 loadConfigs();
};
const handleSizeChange = (size) => {
 pagination.value.pageSize = size;
 pagination.value.currentPage = 1;
 loadConfigs();
};
const handleAdd = () => {
 title.value = '添加AI配置';
 form.value = { id: null, name: '', model: '', apiKey: '', enabled: true, params: {} };
 showModal.value = true;
};
const handleEdit = (row) => {
 title.value = '编辑AI配置';
 form.value = { ...row };
 showModal.value = true;
};
const handleDelete = async (id) => {
 try {
 await deleteAi(id);
 loadConfigs();
 }
 catch (error) {
 console.error('删除AI配置失败:', error);
 }
};
const handleSubmit = () => {
 showModal.value = false;
 loadConfigs();
};
const tableColumns = [
 { prop: 'name', label: '配置名称' },
 { prop: 'model', label: '模型名称' },
 { prop: 'enabled', label: '状态', formatter: (row) => row.enabled ? '启用' : '禁用' },
 { prop: 'createdAt', label: '创建时间' },
 { prop: 'updatedAt', label: '更新时间' }
];
const statItems = [
 { key: 'totalRequests', label: '总请求数', suffix: '次' },
 { key: 'successRate', label: '成功率', suffix: '%' },
 { key: 'avgResponseTime', label: '平均响应时间', suffix: 'ms' },
 { key: 'todayRequests', label: '今日请求', suffix: '次' }
];
</script>

<template>
  <div class="ai-page">
    <div class="page-header">
      <h2>AI功能管理</h2>
      <el-button type="primary" icon="Plus" @click="handleAdd">添加配置</el-button>
    </div>

    <div class="stats-row">
      <el-card
        v-for="item in statItems"
        :key="item.key"
        class="stat-card"
      >
        <div class="stat-value">{{ stats[item.key] }}{{ item.suffix }}</div>
        <div class="stat-label">{{ item.label }}</div>
      </el-card>
    </div>

    <el-card class="search-card">
      <el-input
        v-model="searchQuery"
        placeholder="搜索配置名称"
        prefix-icon="Search"
        class="search-input"
        @keyup.enter="handleSearch"
      />
      <el-button icon="Refresh" @click="loadConfigs">刷新</el-button>
    </el-card>

    <el-card class="table-card">
      <el-table
        :data="tableData"
        :loading="loading"
        border
        style="width: 100%"
      >
        <el-table-column
          v-for="col in tableColumns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
        >
          <template #default="scope">
            {{ col.formatter ? col.formatter(scope.row) : scope.row[col.prop] }}
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button icon="Edit" size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button :icon="Delete" size="small" type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        :current-page="pagination.currentPage"
        :page-size="pagination.pageSize"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </el-card>

    <el-dialog :title="title" v-model="showModal" width="400px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="配置名称">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="模型名称">
          <el-input v-model="form.model" />
        </el-form-item>
        <el-form-item label="API Key">
          <el-input v-model="form.apiKey" type="password" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showModal = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.ai-page {
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
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  padding: 16px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #999;
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

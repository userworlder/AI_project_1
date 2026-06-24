<script setup>import { ref, onMounted } from 'vue';
import { useUserStore } from '@/stores/user';
import { getAiList, deleteAi, getAiStats } from '@/api/ai';
import { Delete, Search, Refresh } from '@element-plus/icons-vue';

// ========== Mock 数据兜底 ==========
const mockAiList = [
 { id: 1, name: '智能问答', model: 'gpt-4', enabled: true, createdAt: '2024-01-15' },
 { id: 2, name: '代码审查', model: 'claude-3', enabled: true, createdAt: '2024-01-20' },
 { id: 3, name: '语音识别', model: 'whisper', enabled: false, createdAt: '2024-02-01' }
];
const mockStats = {
 totalRequests: 12580,
 successRate: 98.5,
 avgResponseTime: 320,
 todayRequests: 285
};

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
 // 模拟登录时跳过真实 API 请求
 const userStore = useUserStore()
 if (userStore.isMockLogin) {
 tableData.value = mockAiList;
 pagination.value.total = mockAiList.length;
 return
 }
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
 // 模拟登录时跳过真实 API 请求
 const userStore = useUserStore()
 if (userStore.isMockLogin) {
 stats.value = mockStats;
 return
 }
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
 {
   prop: 'enabled',
   label: '状态',
   formatter: (row) => ({ text: row.enabled ? '启用' : '禁用', type: row.enabled ? 'success' : 'info' })
 },
 { prop: 'createdAt', label: '创建时间' },
 { prop: 'updatedAt', label: '更新时间' }
];
const statItems = [
 { key: 'totalRequests', label: '总请求数', suffix: '次', color: '#6366F1', bg: 'rgba(99,102,241,0.08)' },
 { key: 'successRate', label: '成功率', suffix: '%', color: '#10B981', bg: 'rgba(16,185,129,0.08)' },
 { key: 'avgResponseTime', label: '平均响应时间', suffix: 'ms', color: '#F59E0B', bg: 'rgba(245,158,11,0.08)' },
 { key: 'todayRequests', label: '今日请求', suffix: '次', color: '#14B8A6', bg: 'rgba(20,184,166,0.08)' }
];
</script>

<template>
  <div class="ai-page">
    <div class="page-header">
      <div class="title-group">
        <h2>AI功能管理</h2>
        <span class="page-desc">管理 AI 模型配置与调用</span>
      </div>
      <el-button type="primary" @click="handleAdd">
        <template #icon><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></template>
        添加配置
      </el-button>
    </div>

    <div class="stats-row">
      <el-card
        v-for="item in statItems"
        :key="item.key"
        class="stat-card"
        shadow="never"
      >
        <div class="stat-content">
          <div class="stat-icon" :style="{ background: item.bg }">
            <span :style="{ color: item.color }">{{ stats[item.key] }}{{ item.suffix }}</span>
          </div>
          <div class="stat-label">{{ item.label }}</div>
        </div>
      </el-card>
    </div>

    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <el-input
          v-model="searchQuery"
          placeholder="搜索配置名称"
          :prefix-icon="Search"
          class="search-input"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="loadConfigs">刷新</el-button>
      </div>
    </el-card>

    <el-card class="table-card" shadow="never">
      <el-table
        :data="tableData"
        :loading="loading"
        style="width: 100%"
        :header-cell-style="{ background: 'var(--color-bg)', color: 'var(--color-text-primary)', fontWeight: 600 }"
      >
        <el-table-column
          v-for="col in tableColumns"
          :key="col.prop"
          :prop="col.prop"
          :label="col.label"
        >
          <template #default="scope">
            <template v-if="col.prop === 'enabled'">
              <el-tag :type="col.formatter(scope.row).type" effect="plain" size="small">
                {{ col.formatter(scope.row).text }}
              </el-tag>
            </template>
            <template v-else>
              {{ scope.row[col.prop] }}
            </template>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
            <el-button size="small" text @click="handleEdit(scope.row)">
              <template #icon><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></template>
              编辑
            </el-button>
            <el-button :icon="Delete" size="small" type="danger" text @click="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          :current-page="pagination.currentPage"
          :page-size="pagination.pageSize"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <el-dialog :title="title" v-model="showModal" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="配置名称">
          <el-input v-model="form.name" placeholder="请输入配置名称" />
        </el-form-item>
        <el-form-item label="模型名称">
          <el-input v-model="form.model" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="API Key">
          <el-input v-model="form.apiKey" type="password" placeholder="请输入 API Key" show-password />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showModal = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.ai-page {
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.stat-card {
  --el-card-padding: 20px;
  border-radius: var(--radius-lg);
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--font-lg);
  font-weight: 700;
  flex-shrink: 0;
}

.stat-label {
  font-size: var(--font-sm);
  color: var(--color-text-secondary);
}

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
  width: 300px;
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

@media (max-width: 1200px) {
  .stats-row {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .stats-row {
    grid-template-columns: 1fr;
  }
}
</style>

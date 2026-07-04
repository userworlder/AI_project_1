<script setup>import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus, Edit, Delete, Search, Refresh, Filter } from '@element-plus/icons-vue';
import { getSkillTree, getSkillTreeByCategory, createSkill, updateSkill, deleteSkill } from '@/api/skill';
import { useUserStore } from '@/stores/user';
// ========== 状态定义 ==========
const allData = ref([]);
const treeData = ref([]);
const searchQuery = ref('');
const filterCategory = ref('');
const loading = ref(false);
const pagination = ref({
 currentPage: 1,
 pageSize: 10
});
const showModal = ref(false);
const formRef = ref(null);
const title = ref('新增技能');
const editingId = ref(null);
const form = ref({
 id: null,
 name: '',
 category: '',
 level: 1,
 description: ''
});
const submitLoading = ref(false);
const rules = {
 name: [
 { required: true, message: '请输入技能名称', trigger: 'blur' },
 { min: 2, max: 50, message: '技能名称为 2-50 个字符', trigger: 'blur' }
 ],
 category: [
 { required: true, message: '请输入分类', trigger: 'blur' },
 { min: 2, max: 20, message: '分类为 2-20 个字符', trigger: 'blur' }
 ],
 level: [
 { required: true, message: '请选择难度等级', trigger: 'change' }
 ],
 description: [
 { required: true, message: '请输入描述', trigger: 'blur' },
 { min: 5, max: 200, message: '描述为 5-200 个字符', trigger: 'blur' }
 ]
};
const levelOptions = [
 { label: '1 - 入门', value: 1 },
 { label: '2 - 基础', value: 2 },
 { label: '3 - 进阶', value: 3 },
 { label: '4 - 高级', value: 4 },
 { label: '5 - 专家', value: 5 }
];
const categoryOptions = [
 { label: '前端开发', value: '前端开发' },
 { label: '后端开发', value: '后端开发' },
 { label: '数据库', value: '数据库' },
 { label: '运维部署', value: '运维部署' },
 { label: '架构设计', value: '架构设计' },
 { label: '工具', value: '工具' }
];
const filteredData = computed(() => {
 const keyword = searchQuery.value.trim().toLowerCase();
 if (!keyword) {
 return allData.value;
 }
 return allData.value.filter(item => item.name.toLowerCase().includes(keyword) ||
 item.category.toLowerCase().includes(keyword));
});
const total = computed(() => filteredData.value.length);
const list = computed(() => {
 const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
 const end = start + pagination.value.pageSize;
 return filteredData.value.slice(start, end);
});
const fetchTree = async () => {
 loading.value = true;
 try {
 const userStore = useUserStore()
 if (userStore.isMockLogin) {
 treeData.value = []
 return
 }
 if (filterCategory.value) {
 treeData.value = await getSkillTreeByCategory(filterCategory.value);
 }
 else {
 treeData.value = await getSkillTree();
 }
 // 同步 allData，供搜索/筛选使用
 allData.value = treeData.value.flatMap(cat => cat.children || [])
 }
 catch (error) {
 console.error('获取技能树失败:', error);
 ElMessage.error('获取技能树失败');
 }
 finally {
 loading.value = false;
 }
};
const handleSearch = () => {
 pagination.value.currentPage = 1;
};
const handleCategoryChange = () => {
 fetchTree();
};
const handlePageChange = (page) => {
 pagination.value.currentPage = page;
};
const handleSizeChange = (size) => {
 pagination.value.pageSize = size;
 pagination.value.currentPage = 1;
};
const handleRefresh = () => {
 searchQuery.value = '';
 filterCategory.value = '';
 pagination.value.currentPage = 1;
 fetchTree();
 ElMessage.success('数据已刷新');
};
const handleAdd = () => {
 title.value = '新增技能';
 editingId.value = null;
 resetForm();
 showModal.value = true;
};
const handleEdit = (row) => {
 title.value = '编辑技能';
 editingId.value = row.id;
 form.value = { ...row };
 showModal.value = true;
};
const handleDelete = async (row) => {
 try {
 await ElMessageBox.confirm(`确定要删除技能「${row.name}」吗？`, '确认删除', {
 confirmButtonText: '确定',
 cancelButtonText: '取消',
 type: 'warning'
 });
 await deleteSkill(row.id);
 await fetchTree();
 ElMessage.success('删除成功');
 } catch (error) {
 if (error !== 'cancel') {
 console.error('删除技能失败:', error);
 if (error?.message) ElMessage.error(error.message);
 }
 }
};
const resetForm = () => {
 form.value = {
 id: null,
 name: '',
 category: '',
 level: 1,
 description: ''
 };
 formRef.value?.resetFields();
};
const handleSubmit = async () => {
 if (!formRef.value) return;
 await formRef.value.validate(async (valid) => {
 if (!valid) return;
 submitLoading.value = true;
 try {
 const submitData = {
 name: form.value.name,
 category: form.value.category,
 level: form.value.level,
 description: form.value.description
 };
 if (editingId.value === null) {
 await createSkill(submitData);
 ElMessage.success('新增技能成功');
 } else {
 await updateSkill(editingId.value, submitData);
 ElMessage.success('编辑技能成功');
 }
 await fetchTree();
 showModal.value = false;
 resetForm();
 } catch (error) {
 console.error('保存技能失败:', error);
 ElMessage.error(error?.message || '保存失败');
 } finally {
 submitLoading.value = false;
 }
 });
};
const handleDialogClose = () => {
 resetForm();
};
const getLevelType = (level) => {
 const types = ['', 'success', 'primary', 'warning', 'danger', 'danger'];
 return types[level] || 'info';
};
const getLevelText = (level) => {
 const texts = ['', '入门', '基础', '进阶', '高级', '专家'];
 return texts[level] || `等级 ${level}`;
};

onMounted(() => {
 fetchTree();
});
</script>

<template>
  <div class="skill-page">
    <div class="page-header">
      <div class="page-title-group">
        <h2>技能树管理</h2>
        <span class="page-desc">管理平台中的技能体系</span>
      </div>
      <el-button type="primary" :icon="Plus" @click="handleAdd">新增技能</el-button>
    </div>

    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <el-input
          v-model="searchQuery"
          placeholder="搜索技能名称或分类"
          :prefix-icon="Search"
          class="search-input"
          clearable
          @keyup.enter="handleSearch"
        />
        <el-select
          v-model="filterCategory"
          placeholder="按分类筛选"
          class="category-select"
          clearable
          @change="handleCategoryChange"
        >
          <el-option
            v-for="item in categoryOptions"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </el-select>
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
      </div>
    </el-card>

    <el-card class="tree-card" shadow="never">
      <el-tree
        v-loading="loading"
        :data="treeData"
        :props="{ label: 'label', children: 'children' }"
        :default-expand-all="true"
        class="skill-tree"
      >
        <template #default="{ node, data }">
          <div class="tree-node-content">
            <span class="tree-node-label">
              <component :is="node.isLeaf ? null : Filter" class="category-icon" />
              <span v-if="node.isLeaf" class="skill-icon">○</span>
              <span v-if="data.children" class="tree-parent">{{ data.label }}</span>
              <span v-else class="tree-child">
                <span class="skill-name">{{ data.label }}</span>
                <el-tag size="small" :type="getLevelType(data.level)" class="level-tag">
                  {{ getLevelText(data.level) }}
                </el-tag>
              </span>
            </span>
            <span class="tree-node-actions">
              <template v-if="!data.children">
                <el-button type="primary" link size="small" icon="Edit" @click.stop="handleEdit(data)">编辑</el-button>
                <el-button type="danger" link size="small" icon="Delete" @click.stop="handleDelete(data)">删除</el-button>
              </template>
            </span>
          </div>
        </template>
      </el-tree>
    </el-card>

    <el-card class="table-card" v-if="false">
      <el-table
        :data="list"
        border
        stripe
        style="width: 100%"
      >
        <el-table-column prop="name" label="技能名称" align="center" />
        <el-table-column prop="category" label="分类" align="center" />
        <el-table-column prop="level" label="难度等级" align="center" width="120">
          <template #default="{ row }">
            <el-tag :type="getLevelType(row.level)">
              {{ getLevelText(row.level) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="createdAt" label="创建时间" align="center" width="180" />
        <el-table-column label="操作" align="center" width="160">
          <template #default="{ row }">
            <el-button type="primary" link size="small" :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link size="small" :icon="Delete" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="pagination.currentPage"
        v-model:page-size="pagination.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </el-card>

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
        label-width="90px"
      >
        <el-form-item label="技能名称" prop="name">
          <el-input
            v-model="form.name"
            placeholder="请输入技能名称"
            clearable
          />
        </el-form-item>

        <el-form-item label="分类" prop="category">
          <el-select
            v-model="form.category"
            placeholder="请选择分类"
            style="width: 100%"
          >
            <el-option
              v-for="item in categoryOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="难度等级" prop="level">
          <el-select
            v-model="form.level"
            placeholder="请选择难度等级"
            style="width: 100%"
          >
            <el-option
              v-for="item in levelOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            placeholder="请输入技能描述"
            :rows="3"
            type="textarea"
          />
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
.skill-page {
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

.category-select {
  width: 180px;
}

.tree-card {
  border-radius: var(--radius-lg);
  --el-card-padding: 16px;
}

.skill-tree {
  max-height: 600px;
  overflow-y: auto;
}

.skill-tree :deep(.el-tree-node__content) {
  height: auto;
  padding: 8px 0;
}

.skill-tree :deep(.el-tree-node__expand-icon) {
  font-size: 14px;
  color: var(--color-text-tertiary);
  margin-left: 4px;
}

.skill-tree :deep(.el-tree-node:not(.is-leaf) > .el-tree-node__content) {
  font-weight: 600;
  color: var(--color-text-primary);
  padding: 10px 0;
}

.tree-node-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding-right: 12px;
}

.tree-node-label {
  display: flex;
  align-items: center;
  gap: 8px;
}

.category-icon {
  font-size: 14px;
  color: var(--color-primary);
}

.skill-icon {
  font-size: 8px;
  color: var(--color-text-tertiary);
}

.tree-parent {
  font-weight: 600;
  color: var(--color-text-primary);
  font-size: var(--font-md);
}

.tree-child {
  display: flex;
  align-items: center;
  gap: 12px;
}

.skill-name {
  color: var(--color-text-primary);
  font-size: var(--font-base);
}

.level-tag {
  font-size: 11px;
  padding: 2px 8px;
}

.tree-node-actions {
  opacity: 0;
  transition: opacity var(--transition-fast);
}

.el-tree-node:hover .tree-node-actions {
  opacity: 1;
}

.table-card {
  padding: 20px;
}

.table-card :deep(.el-pagination) {
  margin-top: 20px;
  text-align: right;
}
</style>

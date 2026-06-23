<script setup>import { ref, computed, onMounted } from 'vue';
import { mockSkillList } from '@/mock/skill';
import { getSkillTree, getSkillTreeByCategory } from '@/api/skill';
import { Plus, Edit, Delete, Search, Refresh, Filter } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
// ========== 状态定义 ==========
// 全量数据（来自 Mock）
const allData = ref(mockSkillList);
// 树形数据
const treeData = ref([]);
// 搜索关键词
const searchQuery = ref('');
// 分类筛选
const filterCategory = ref('');
// 加载状态
const loading = ref(false);
// 分页配置
const pagination = ref({
 currentPage: 1,
 pageSize: 10
});
// ========== 弹窗与表单状态 ==========
// 弹窗显示状态
const showModal = ref(false);
// 表单引用（用于触发表单验证）
const formRef = ref(null);
// 弹窗标题
const title = ref('新增技能');
// 当前编辑的 ID（为 null 时是新增模式）
const editingId = ref(null);
// 表单数据
const form = ref({
 id: null,
 name: '',
 category: '',
 level: 1,
 description: ''
});
// 提交按钮加载状态
const submitLoading = ref(false);
// ========== 表单校验规则 ==========
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
// ========== 难度等级选项 ==========
const levelOptions = [
 { label: '1 - 入门', value: 1 },
 { label: '2 - 基础', value: 2 },
 { label: '3 - 进阶', value: 3 },
 { label: '4 - 高级', value: 4 },
 { label: '5 - 专家', value: 5 }
];
// ========== 分类选项（用于下拉选择）==========
const categoryOptions = [
 { label: '前端开发', value: '前端开发' },
 { label: '后端开发', value: '后端开发' },
 { label: '数据库', value: '数据库' },
 { label: '运维部署', value: '运维部署' },
 { label: '架构设计', value: '架构设计' },
 { label: '工具', value: '工具' }
];
// ========== 计算属性 ==========
// 根据关键词过滤全量数据（支持技能名称和分类模糊搜索）
const filteredData = computed(() => {
 const keyword = searchQuery.value.trim().toLowerCase();
 if (!keyword) {
 return allData.value;
 }
 return allData.value.filter(item => item.name.toLowerCase().includes(keyword) ||
 item.category.toLowerCase().includes(keyword));
});
// 过滤后的总数据条数
const total = computed(() => filteredData.value.length);
// 当前页展示的数据（切片实现）
const list = computed(() => {
 const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
 const end = start + pagination.value.pageSize;
 return filteredData.value.slice(start, end);
});
// ========== 方法函数 ==========
// 获取技能树数据
const fetchTree = async () => {
 loading.value = true;
 try {
 if (filterCategory.value) {
 // 按分类查询
 treeData.value = await getSkillTreeByCategory(filterCategory.value);
 }
 else {
 // 获取全量技能树
 treeData.value = await getSkillTree();
 }
 }
 catch (error) {
 console.error('获取技能树失败:', error);
 ElMessage.error('获取技能树失败');
 }
 finally {
 loading.value = false;
 }
};
// 搜索（重置页码为第1页）
const handleSearch = () => {
 pagination.value.currentPage = 1;
};
// 分类筛选变化
const handleCategoryChange = () => {
 fetchTree();
};
// 页码切换
const handlePageChange = (page) => {
 pagination.value.currentPage = page;
};
// 每页条数切换
const handleSizeChange = (size) => {
 pagination.value.pageSize = size;
 pagination.value.currentPage = 1;
};
// 刷新数据
const handleRefresh = () => {
 searchQuery.value = '';
 filterCategory.value = '';
 pagination.value.currentPage = 1;
 fetchTree();
 ElMessage.success('数据已刷新');
};
// 点击新增按钮
const handleAdd = () => {
 title.value = '新增技能';
 editingId.value = null;
 resetForm();
 showModal.value = true;
};
// 点击编辑按钮
const handleEdit = (row) => {
 title.value = '编辑技能';
 editingId.value = row.id;
 form.value = { ...row };
 showModal.value = true;
};
// 删除技能（带二次确认）
const handleDelete = (row) => {
 ElMessageBox.confirm(`确定要删除技能「${row.name}」吗？`, '确认删除', {
 confirmButtonText: '确定',
 cancelButtonText: '取消',
 type: 'warning'
 }).then(() => {
 // 用户确认删除
 const index = allData.value.findIndex(item => item.id === row.id);
 if (index > -1) {
 allData.value.splice(index, 1);
 // 同步更新树形数据
 fetchTree();
 ElMessage.success('删除成功');
 }
 }).catch(() => {
 // 用户取消删除
 ElMessage.info('已取消删除');
 });
};
// 重置表单
const resetForm = () => {
 form.value = {
 id: null,
 name: '',
 category: '',
 level: 1,
 description: ''
 };
 // 重置表单验证状态
 formRef.value?.resetFields();
};
// 提交表单
const handleSubmit = async () => {
 // 触发表单验证
 if (!formRef.value)
 return;
 await formRef.value.validate((valid) => {
 if (!valid) {
 // 验证不通过，不执行后续逻辑
 return false;
 }
 // 验证通过，设置加载状态
 submitLoading.value = true;
 try {
 if (editingId.value === null) {
 // ========== 新增模式 ==========
 const newSkill = {
 id: Date.now(), // 用时间戳模拟唯一 ID
 name: form.value.name,
 category: form.value.category,
 level: form.value.level,
 description: form.value.description,
 createdAt: new Date().toLocaleString('zh-CN', {
 year: 'numeric',
 month: '2-digit',
 day: '2-digit',
 hour: '2-digit',
 minute: '2-digit',
 second: '2-digit'
 }).replace(/\//g, '-')
 };
 // 添加到列表开头
 allData.value.unshift(newSkill);
 ElMessage.success('新增技能成功');
 }
 else {
 // ========== 编辑模式 ==========
 const index = allData.value.findIndex(item => item.id === editingId.value);
 if (index > -1) {
 allData.value[index] = {
 ...allData.value[index],
 name: form.value.name,
 category: form.value.category,
 level: form.value.level,
 description: form.value.description
 };
 ElMessage.success('编辑技能成功');
 }
 }
 // 同步更新树形数据
 fetchTree();
 // 关闭弹窗
 showModal.value = false;
 // 重置表单
 resetForm();
 }
 finally {
 // 取消加载状态
 submitLoading.value = false;
 }
 });
};
// 弹窗关闭时自动重置表单
const handleDialogClose = () => {
 resetForm();
};
// 获取难度等级的样式类型
const getLevelType = (level) => {
 const types = ['', 'success', 'primary', 'warning', 'danger', 'danger'];
 return types[level] || 'info';
};
// 获取难度等级的标签文本
const getLevelText = (level) => {
 const texts = ['', '入门', '基础', '进阶', '高级', '专家'];
 return texts[level] || `等级 ${level}`;
};

// ========== 生命周期 ==========
onMounted(() => {
 fetchTree();
});
</script>

<template>
  <div class="skill-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <h2>技能树管理</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">新增技能</el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-input
        v-model="searchQuery"
        placeholder="搜索技能名称或分类"
        prefix-icon="Search"
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
    </el-card>

    <!-- 树形结构展示 -->
    <el-card class="tree-card">
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

    <!-- 数据表格（保留原有表格视图作为备用） -->
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

      <!-- 分页 -->
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
          <el-textarea
            v-model="form.description"
            placeholder="请输入技能描述"
            :rows="3"
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
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.skill-page {
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

.category-select {
  width: 180px;
}

.tree-card {
  padding: 20px;
}

.skill-tree {
  max-height: 600px;
  overflow-y: auto;
}

.tree-node-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.tree-node-label {
  display: flex;
  align-items: center;
  gap: 8px;
}

.category-icon {
  font-size: 14px;
  color: #667eea;
}

.skill-icon {
  font-size: 8px;
  color: #999;
}

.tree-parent {
  font-weight: 600;
  color: #333;
  font-size: 15px;
}

.tree-child {
  display: flex;
  align-items: center;
  gap: 12px;
}

.skill-name {
  color: #333;
}

.level-tag {
  font-size: 11px;
  padding: 2px 8px;
}

.tree-node-actions {
  opacity: 0;
  transition: opacity 0.2s;
}

.el-tree-node:hover .tree-node-actions {
  opacity: 1;
}

.tree-actions {
  display: flex;
  gap: 8px;
}

.table-card {
  padding: 20px;
}

.table-card :deep(.el-pagination) {
  margin-top: 20px;
  text-align: right;
}
</style>

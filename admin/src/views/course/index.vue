<script setup>
import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus, Edit, Delete, Search, Refresh, FolderOpened, QuestionFilled } from '@element-plus/icons-vue';
import { getCourseList, getCourseById, createCourse, updateCourse, deleteCourse, getCourseSections, createSection, updateSection, deleteSection, getSectionQuestions, createQuestion, updateQuestion, deleteQuestion } from '@/api/course';
import { getSkillList } from '@/api/skill';

// ========== 课程状态 ==========
const courseList = ref([]);
const skillOptions = ref([]);
const searchQuery = ref('');
const filterSkillId = ref('');
const loading = ref(false);
const pagination = ref({
  currentPage: 1,
  pageSize: 10
});
const total = ref(0);

// ========== 课程表单 ==========
const showCourseModal = ref(false);
const courseFormRef = ref(null);
const courseTitle = ref('新增课程');
const editingCourseId = ref(null);
const courseForm = ref({
  name: '',
  description: '',
  skill_id: null,
  difficulty_level: 1,
  sort_order: 0,
  status: 'draft'
});
const submitLoading = ref(false);

const courseRules = {
  name: [
    { required: true, message: '请输入课程名称', trigger: 'blur' },
    { min: 2, max: 100, message: '课程名称为 2-100 个字符', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请输入课程描述', trigger: 'blur' }
  ],
  skill_id: [
    { required: true, message: '请选择所属技能', trigger: 'change' }
  ],
  difficulty_level: [
    { required: true, message: '请选择难度等级', trigger: 'change' }
  ]
};

const difficultyOptions = [
  { label: '1 - 入门', value: 1 },
  { label: '2 - 基础', value: 2 },
  { label: '3 - 进阶', value: 3 },
  { label: '4 - 高级', value: 4 },
  { label: '5 - 专家', value: 5 }
];

const statusOptions = [
  { label: '草稿', value: 'draft' },
  { label: '已发布', value: 'published' }
];

// ========== 章节状态 ==========
const showSectionModal = ref(false);
const currentCourseId = ref(null);
const currentCourseName = ref('');
const sections = ref([]);
const sectionLoading = ref(false);
const showSectionForm = ref(false);
const sectionFormRef = ref(null);
const sectionTitle = ref('新增章节');
const editingSectionId = ref(null);
const sectionForm = ref({
  name: '',
  description: '',
  sort_order: 0
});
const sectionSubmitLoading = ref(false);

const sectionRules = {
  name: [
    { required: true, message: '请输入章节名称', trigger: 'blur' },
    { min: 2, max: 100, message: '章节名称为 2-100 个字符', trigger: 'blur' }
  ]
};

// ========== 题目状态 ==========
const showQuestionModal = ref(false);
const currentSectionId = ref(null);
const currentSectionName = ref('');
const questions = ref([]);
const questionLoading = ref(false);
const showQuestionForm = ref(false);
const questionFormRef = ref(null);
const questionTitle = ref('新增题目');
const editingQuestionId = ref(null);
const questionForm = ref({
  content: '',
  type: 'choice',
  options: '',
  correct_answer: '',
  analysis: ''
});
const questionSubmitLoading = ref(false);

const questionRules = {
  content: [
    { required: true, message: '请输入题目内容', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择题目类型', trigger: 'change' }
  ],
  correct_answer: [
    { required: true, message: '请输入正确答案', trigger: 'blur' }
  ]
};

const questionTypeOptions = [
  { label: '选择题', value: 'choice' },
  { label: '判断题', value: 'true_false' }
];

// ========== 计算属性 ==========
const filteredList = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase();
  if (!keyword && !filterSkillId.value) {
    return courseList.value;
  }
  return courseList.value.filter(item => {
    let match = true;
    if (keyword) {
      match = match && (item.name.toLowerCase().includes(keyword) || (item.teacher || '').toLowerCase().includes(keyword));
    }
    if (filterSkillId.value) {
      match = match && String(item.skill_id) === String(filterSkillId.value);
    }
    return match;
  });
});

const paginatedList = computed(() => {
  const start = (pagination.value.currentPage - 1) * pagination.value.pageSize;
  const end = start + pagination.value.pageSize;
  return filteredList.value.slice(start, end);
});

// ========== 课程方法 ==========
const fetchCourses = async () => {
  loading.value = true;
  try {
    const res = await getCourseList({ page: pagination.value.currentPage, pageSize: pagination.value.pageSize });
    if (res && res.rows) {
      courseList.value = res.rows;
      total.value = res.count || res.rows.length;
    } else if (Array.isArray(res)) {
      courseList.value = res;
      total.value = res.length;
    } else {
      courseList.value = [];
      total.value = 0;
    }
  } catch (error) {
    console.error('获取课程列表失败:', error);
    ElMessage.error('获取课程列表失败');
  } finally {
    loading.value = false;
  }
};

const fetchSkillOptions = async () => {
  try {
    const res = await getSkillList({ pageSize: 999 });
    if (Array.isArray(res)) {
      skillOptions.value = res;
    } else if (res && res.rows) {
      skillOptions.value = res.rows;
    } else {
      skillOptions.value = [];
    }
  } catch (error) {
    console.error('获取技能列表失败:', error);
    skillOptions.value = [];
  }
};

const handleSearch = () => {
  pagination.value.currentPage = 1;
};

const handleRefresh = () => {
  searchQuery.value = '';
  filterSkillId.value = '';
  pagination.value.currentPage = 1;
  fetchCourses();
  ElMessage.success('数据已刷新');
};

const handlePageChange = (page) => {
  pagination.value.currentPage = page;
};

const handleSizeChange = (size) => {
  pagination.value.pageSize = size;
  pagination.value.currentPage = 1;
};

// ========== 课程 CRUD ==========
const resetCourseForm = () => {
  courseForm.value = {
    name: '',
    description: '',
    skill_id: null,
    difficulty_level: 1,
    sort_order: 0,
    status: 'draft'
  };
  courseFormRef.value?.resetFields();
};

const handleAddCourse = () => {
  courseTitle.value = '新增课程';
  editingCourseId.value = null;
  resetCourseForm();
  showCourseModal.value = true;
};

const handleEditCourse = (row) => {
  courseTitle.value = '编辑课程';
  editingCourseId.value = row.id;
  courseForm.value = {
    name: row.name,
    description: row.description || '',
    skill_id: row.skill_id,
    difficulty_level: row.difficulty_level || 1,
    sort_order: row.sort_order || 0,
    status: row.status || 'draft'
  };
  showCourseModal.value = true;
};

const handleDeleteCourse = async (row) => {
  try {
    await ElMessageBox.confirm(`确定要删除课程「${row.name}」吗？`, '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deleteCourse(row.id);
    await fetchCourses();
    ElMessage.success('删除成功');
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除课程失败:', error);
      if (error?.message) ElMessage.error(error.message);
    }
  }
};

const handleCourseSubmit = async () => {
  if (!courseFormRef.value) return;
  await courseFormRef.value.validate(async (valid) => {
    if (!valid) return;
    submitLoading.value = true;
    try {
      const submitData = {
        name: courseForm.value.name,
        description: courseForm.value.description,
        skill_id: courseForm.value.skill_id,
        difficulty_level: courseForm.value.difficulty_level,
        sort_order: courseForm.value.sort_order,
        status: courseForm.value.status
      };
      if (editingCourseId.value === null) {
        await createCourse(submitData);
        ElMessage.success('新增课程成功');
      } else {
        await updateCourse(editingCourseId.value, submitData);
        ElMessage.success('编辑课程成功');
      }
      await fetchCourses();
      showCourseModal.value = false;
      resetCourseForm();
    } catch (error) {
      console.error('保存课程失败:', error);
      ElMessage.error(error?.message || '保存失败');
    } finally {
      submitLoading.value = false;
    }
  });
};

const handleCourseDialogClose = () => {
  resetCourseForm();
};

// ========== 章节方法 ==========
const openSectionModal = async (row) => {
  currentCourseId.value = row.id;
  currentCourseName.value = row.name;
  showSectionForm.value = false;
  showSectionModal.value = true;
  await fetchSections();
};

const fetchSections = async () => {
  if (!currentCourseId.value) return;
  sectionLoading.value = true;
  try {
    const res = await getCourseSections(currentCourseId.value);
    if (Array.isArray(res)) {
      sections.value = res;
    } else if (res && res.rows) {
      sections.value = res.rows;
    } else {
      sections.value = [];
    }
  } catch (error) {
    console.error('获取章节列表失败:', error);
    ElMessage.error('获取章节列表失败');
  } finally {
    sectionLoading.value = false;
  }
};

const resetSectionForm = () => {
  sectionForm.value = {
    name: '',
    description: '',
    sort_order: 0
  };
  sectionFormRef.value?.resetFields();
};

const handleAddSection = () => {
  sectionTitle.value = '新增章节';
  editingSectionId.value = null;
  resetSectionForm();
  showSectionForm.value = true;
};

const handleEditSection = (row) => {
  sectionTitle.value = '编辑章节';
  editingSectionId.value = row.id;
  sectionForm.value = {
    name: row.name,
    description: row.description || '',
    sort_order: row.sort_order || 0
  };
  showSectionForm.value = true;
};

const handleDeleteSection = async (row) => {
  try {
    await ElMessageBox.confirm(`确定要删除章节「${row.name}」吗？`, '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deleteSection(row.id);
    await fetchSections();
    ElMessage.success('删除章节成功');
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除章节失败:', error);
      if (error?.message) ElMessage.error(error.message);
    }
  }
};

const handleSectionSubmit = async () => {
  if (!sectionFormRef.value) return;
  await sectionFormRef.value.validate(async (valid) => {
    if (!valid) return;
    sectionSubmitLoading.value = true;
    try {
      const submitData = {
        name: sectionForm.value.name,
        description: sectionForm.value.description,
        sort_order: sectionForm.value.sort_order
      };
      if (editingSectionId.value === null) {
        await createSection(currentCourseId.value, submitData);
        ElMessage.success('新增章节成功');
      } else {
        await updateSection(editingSectionId.value, submitData);
        ElMessage.success('编辑章节成功');
      }
      await fetchSections();
      showSectionForm.value = false;
      resetSectionForm();
    } catch (error) {
      console.error('保存章节失败:', error);
      ElMessage.error(error?.message || '保存失败');
    } finally {
      sectionSubmitLoading.value = false;
    }
  });
};

// ========== 题目方法 ==========
const openQuestionModal = async (row) => {
  currentSectionId.value = row.id;
  currentSectionName.value = row.name;
  showQuestionForm.value = false;
  showQuestionModal.value = true;
  await fetchQuestions();
};

const fetchQuestions = async () => {
  if (!currentSectionId.value) return;
  questionLoading.value = true;
  try {
    const res = await getSectionQuestions(currentSectionId.value);
    if (Array.isArray(res)) {
      questions.value = res;
    } else if (res && res.rows) {
      questions.value = res.rows;
    } else {
      questions.value = [];
    }
  } catch (error) {
    console.error('获取题目列表失败:', error);
    ElMessage.error('获取题目列表失败');
  } finally {
    questionLoading.value = false;
  }
};

const resetQuestionForm = () => {
  questionForm.value = {
    content: '',
    type: 'choice',
    options: '',
    correct_answer: '',
    analysis: ''
  };
  questionFormRef.value?.resetFields();
};

const handleAddQuestion = () => {
  questionTitle.value = '新增题目';
  editingQuestionId.value = null;
  resetQuestionForm();
  showQuestionForm.value = true;
};

const handleEditQuestion = (row) => {
  questionTitle.value = '编辑题目';
  editingQuestionId.value = row.id;
  questionForm.value = {
    content: row.content,
    type: row.type || 'choice',
    options: row.options ? (typeof row.options === 'string' ? row.options : JSON.stringify(row.options, null, 2)) : '',
    correct_answer: row.correct_answer,
    analysis: row.analysis || ''
  };
  showQuestionForm.value = true;
};

const handleDeleteQuestion = async (row) => {
  try {
    await ElMessageBox.confirm(`确定要删除此题目吗？`, '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deleteQuestion(row.id);
    await fetchQuestions();
    ElMessage.success('删除题目成功');
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除题目失败:', error);
      if (error?.message) ElMessage.error(error.message);
    }
  }
};

const handleQuestionSubmit = async () => {
  if (!questionFormRef.value) return;
  await questionFormRef.value.validate(async (valid) => {
    if (!valid) return;
    questionSubmitLoading.value = true;
    try {
      let options = questionForm.value.options;
      if (questionForm.value.type === 'choice' && options) {
        try {
          options = JSON.parse(options);
        } catch (e) {
          ElMessage.warning('选项格式不正确，请填写合法的JSON');
          questionSubmitLoading.value = false;
          return;
        }
      } else if (questionForm.value.type === 'true_false') {
        options = null;
      }
      const submitData = {
        content: questionForm.value.content,
        type: questionForm.value.type,
        options: options,
        correct_answer: questionForm.value.correct_answer,
        analysis: questionForm.value.analysis
      };
      if (editingQuestionId.value === null) {
        await createQuestion(currentSectionId.value, submitData);
        ElMessage.success('新增题目成功');
      } else {
        await updateQuestion(editingQuestionId.value, submitData);
        ElMessage.success('编辑题目成功');
      }
      await fetchQuestions();
      showQuestionForm.value = false;
      resetQuestionForm();
    } catch (error) {
      console.error('保存题目失败:', error);
      ElMessage.error(error?.message || '保存失败');
    } finally {
      questionSubmitLoading.value = false;
    }
  });
};

// ========== 工具方法 ==========
const getDifficultyType = (level) => {
  const types = ['', 'success', 'primary', 'warning', 'danger', 'danger'];
  return types[level] || 'info';
};

const getDifficultyText = (level) => {
  const texts = ['', '入门', '基础', '进阶', '高级', '专家'];
  return texts[level] || `等级 ${level}`;
};

const getStatusType = (status) => {
  const types = { draft: 'info', published: 'success' };
  return types[status] || 'info';
};

const getStatusText = (status) => {
  const texts = { draft: '草稿', published: '已发布' };
  return texts[status] || status;
};

const getSkillName = (skillId) => {
  if (!skillId) return '-';
  const skill = skillOptions.value.find(s => String(s.id) === String(skillId));
  return skill ? skill.name : `ID: ${skillId}`;
};

const getQuestionTypeText = (type) => {
  const types = { choice: '选择题', true_false: '判断题' };
  return types[type] || type;
};

onMounted(() => {
  fetchCourses();
  fetchSkillOptions();
});
</script>

<template>
  <div class="course-page">
    <!-- ===== 页面头部 ===== -->
    <div class="page-header">
      <div class="page-title-group">
        <h2>课程管理</h2>
        <span class="page-desc">管理平台中的课程体系</span>
      </div>
      <el-button type="primary" :icon="Plus" @click="handleAddCourse">新增课程</el-button>
    </div>

    <!-- ===== 搜索卡片 ===== -->
    <el-card class="search-card" shadow="never">
      <div class="search-bar">
        <el-input
          v-model="searchQuery"
          placeholder="搜索课程名称或教师"
          :prefix-icon="Search"
          class="search-input"
          clearable
          @keyup.enter="handleSearch"
        />
        <el-select
          v-model="filterSkillId"
          placeholder="按技能筛选"
          class="skill-select"
          clearable
        >
          <el-option
            v-for="item in skillOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
        <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
        <el-button :icon="Refresh" @click="handleRefresh">刷新</el-button>
      </div>
    </el-card>

    <!-- ===== 课程表格 ===== -->
    <el-card class="table-card" shadow="never">
      <el-table
        :data="paginatedList"
        v-loading="loading"
        border
        stripe
        style="width: 100%"
      >
        <el-table-column prop="name" label="课程名称" align="center" min-width="160" />
        <el-table-column label="所属技能" align="center" width="130">
          <template #default="{ row }">
            {{ getSkillName(row.skill_id) }}
          </template>
        </el-table-column>
        <el-table-column label="难度等级" align="center" width="110">
          <template #default="{ row }">
            <el-tag :type="getDifficultyType(row.difficulty_level)" size="small">
              {{ getDifficultyText(row.difficulty_level) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" align="center" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="teacher" label="授课教师" align="center" width="120" />
        <el-table-column prop="created_at" label="创建时间" align="center" width="180" />
        <el-table-column label="操作" align="center" width="230" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" :icon="Edit" @click="handleEditCourse(row)">编辑</el-button>
            <el-button type="danger" link size="small" :icon="Delete" @click="handleDeleteCourse(row)">删除</el-button>
            <el-button type="warning" link size="small" :icon="FolderOpened" @click="openSectionModal(row)">章节</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="pagination.currentPage"
        v-model:page-size="pagination.pageSize"
        :total="filteredList.length"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </el-card>

    <!-- ============================================================ -->
    <!-- ===== 课程新增/编辑弹窗 ===== -->
    <!-- ============================================================ -->
    <el-dialog
      :title="courseTitle"
      v-model="showCourseModal"
      width="580px"
      :before-close="handleCourseDialogClose"
    >
      <el-form
        ref="courseFormRef"
        :model="courseForm"
        :rules="courseRules"
        label-width="100px"
      >
        <el-form-item label="课程名称" prop="name">
          <el-input
            v-model="courseForm.name"
            placeholder="请输入课程名称"
            clearable
          />
        </el-form-item>

        <el-form-item label="课程描述" prop="description">
          <el-input
            v-model="courseForm.description"
            placeholder="请输入课程描述"
            :rows="3"
            type="textarea"
          />
        </el-form-item>

        <el-form-item label="所属技能" prop="skill_id">
          <el-select
            v-model="courseForm.skill_id"
            placeholder="请选择所属技能"
            style="width: 100%"
            clearable
            filterable
          >
            <el-option
              v-for="item in skillOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="难度等级" prop="difficulty_level">
          <el-select
            v-model="courseForm.difficulty_level"
            placeholder="请选择难度等级"
            style="width: 100%"
          >
            <el-option
              v-for="item in difficultyOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="排序" prop="sort_order">
          <el-input-number
            v-model="courseForm.sort_order"
            :min="0"
            :max="9999"
          />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select
            v-model="courseForm.status"
            placeholder="请选择状态"
            style="width: 100%"
          >
            <el-option
              v-for="item in statusOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCourseModal = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitLoading"
          @click="handleCourseSubmit"
        >
          确 定
        </el-button>
      </template>
    </el-dialog>

    <!-- ============================================================ -->
    <!-- ===== 章节管理弹窗 ===== -->
    <!-- ============================================================ -->
    <el-dialog
      :title="`章节管理 - ${currentCourseName}`"
      v-model="showSectionModal"
      width="700px"
    >
      <div class="section-toolbar">
        <el-button type="primary" size="small" :icon="Plus" @click="handleAddSection">新增章节</el-button>
      </div>

      <el-table
        :data="sections"
        v-loading="sectionLoading"
        border
        stripe
        style="width: 100%"
        size="small"
      >
        <el-table-column prop="sort_order" label="排序" align="center" width="70" />
        <el-table-column prop="name" label="章节名称" align="center" min-width="160" />
        <el-table-column prop="description" label="描述" align="center" min-width="180" show-overflow-tooltip />
        <el-table-column label="操作" align="center" width="260" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" :icon="Edit" @click="handleEditSection(row)">编辑</el-button>
            <el-button type="danger" link size="small" :icon="Delete" @click="handleDeleteSection(row)">删除</el-button>
            <el-button type="success" link size="small" :icon="QuestionFilled" @click="openQuestionModal(row)">题目</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 章节新增/编辑表单 -->
      <el-form
        v-if="showSectionForm"
        ref="sectionFormRef"
        :model="sectionForm"
        :rules="sectionRules"
        label-width="90px"
        class="section-form"
      >
        <el-divider />
        <h4 class="form-title">{{ sectionTitle }}</h4>
        <el-form-item label="章节名称" prop="name">
          <el-input
            v-model="sectionForm.name"
            placeholder="请输入章节名称"
            clearable
          />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="sectionForm.description"
            placeholder="请输入章节描述"
            :rows="2"
            type="textarea"
          />
        </el-form-item>
        <el-form-item label="排序" prop="sort_order">
          <el-input-number
            v-model="sectionForm.sort_order"
            :min="0"
            :max="9999"
          />
        </el-form-item>
        <div class="section-form-actions">
          <el-button @click="showSectionForm = false">取消</el-button>
          <el-button
            type="primary"
            :loading="sectionSubmitLoading"
            @click="handleSectionSubmit"
          >
            确 定
          </el-button>
        </div>
      </el-form>
    </el-dialog>

    <!-- ============================================================ -->
    <!-- ===== 题目管理弹窗 ===== -->
    <!-- ============================================================ -->
    <el-dialog
      :title="`题目管理 - ${currentSectionName}`"
      v-model="showQuestionModal"
      width="750px"
    >
      <div class="question-toolbar">
        <el-button type="primary" size="small" :icon="Plus" @click="handleAddQuestion">新增题目</el-button>
      </div>

      <el-table
        :data="questions"
        v-loading="questionLoading"
        border
        stripe
        style="width: 100%"
        size="small"
      >
        <el-table-column prop="content" label="题目内容" align="center" min-width="240" show-overflow-tooltip />
        <el-table-column label="类型" align="center" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === 'choice' ? 'primary' : 'success'" size="small">
              {{ getQuestionTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="correct_answer" label="正确答案" align="center" width="100" show-overflow-tooltip />
        <el-table-column label="操作" align="center" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" :icon="Edit" @click="handleEditQuestion(row)">编辑</el-button>
            <el-button type="danger" link size="small" :icon="Delete" @click="handleDeleteQuestion(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 题目新增/编辑表单 -->
      <el-form
        v-if="showQuestionForm"
        ref="questionFormRef"
        :model="questionForm"
        :rules="questionRules"
        label-width="100px"
        class="question-form"
      >
        <el-divider />
        <h4 class="form-title">{{ questionTitle }}</h4>
        <el-form-item label="题目内容" prop="content">
          <el-input
            v-model="questionForm.content"
            placeholder="请输入题目内容"
            :rows="3"
            type="textarea"
          />
        </el-form-item>
        <el-form-item label="题目类型" prop="type">
          <el-select
            v-model="questionForm.type"
            placeholder="请选择题型"
            style="width: 100%"
          >
            <el-option
              v-for="item in questionTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="questionForm.type === 'choice'" label="选项" prop="options">
          <el-input
            v-model="questionForm.options"
            placeholder='JSON格式，如：[{"label":"A","value":"A选项内容"}]'
            :rows="3"
            type="textarea"
          />
          <div class="form-tip">选择题请填写 JSON 格式的选项数组</div>
        </el-form-item>
        <el-form-item label="正确答案" prop="correct_answer">
          <el-input
            v-model="questionForm.correct_answer"
            placeholder="请输入正确答案"
            clearable
          />
        </el-form-item>
        <el-form-item label="解析" prop="analysis">
          <el-input
            v-model="questionForm.analysis"
            placeholder="请输入题目解析（可选）"
            :rows="3"
            type="textarea"
          />
        </el-form-item>
        <div class="question-form-actions">
          <el-button @click="showQuestionForm = false">取消</el-button>
          <el-button
            type="primary"
            :loading="questionSubmitLoading"
            @click="handleQuestionSubmit"
          >
            确 定
          </el-button>
        </div>
      </el-form>
    </el-dialog>
  </div>
</template>

<style scoped>
.course-page {
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

.skill-select {
  width: 180px;
}

.table-card {
  border-radius: var(--radius-lg);
  --el-card-padding: 16px;
}

.table-card :deep(.el-pagination) {
  margin-top: 20px;
  text-align: right;
}

/* ===== 章节管理 ===== */
.section-toolbar {
  margin-bottom: 12px;
}

.section-form {
  margin-top: 16px;
}

.section-form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}

/* ===== 题目管理 ===== */
.question-toolbar {
  margin-bottom: 12px;
}

.question-form {
  margin-top: 16px;
}

.question-form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}

.form-title {
  font-size: var(--font-md);
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0 0 16px;
}

.form-tip {
  font-size: 12px;
  color: var(--color-text-tertiary);
  margin-top: 4px;
  line-height: 1.4;
}
</style>

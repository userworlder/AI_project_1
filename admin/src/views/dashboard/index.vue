<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue';
import * as echarts from 'echarts';
import { useUserStore } from '@/stores/user';
import { getDashboardStats } from '@/api/dashboard';
import { UserFilled, Notebook, MagicStick, TrendCharts } from '@element-plus/icons-vue';

// ========== 状态定义 ==========
const stats = ref({
  totalUsers: 0,
  totalLearningHours: 0,
  aiInteractions: 0,
  activeUsers: 0
});

// ========== 图表实例引用 ==========
const growthChart = ref(null);
const learningChart = ref(null);
const aiCallChart = ref(null);
const userGrowthChart = ref(null);

// ========== 统计卡片配置 ==========
const statCards = [
  { key: 'totalUsers', label: '总用户数', icon: UserFilled, color: '#6366F1', bg: 'rgba(99,102,241,0.08)' },
  { key: 'totalLearningHours', label: '学习时长', icon: Notebook, color: '#14B8A6', bg: 'rgba(20,184,166,0.08)' },
  { key: 'aiInteractions', label: 'AI交互次数', icon: MagicStick, color: '#10B981', bg: 'rgba(16,185,129,0.08)' },
  { key: 'activeUsers', label: '活跃用户', icon: TrendCharts, color: '#F59E0B', bg: 'rgba(245,158,11,0.08)' }
];

// ========== Mock 数据 - 近30天用户增长 ==========
const getMockUserGrowthData = () => {
  const today = new Date();
  const dates = [];
  const values = [];

  for (let i = 29; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    dates.push(`${month}-${day}`);

    const dayOfWeek = date.getDay();
    let baseValue = Math.floor(Math.random() * 60) + 20;
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      baseValue += Math.floor(Math.random() * 30) + 10;
    }
    values.push(baseValue);
  }

  return { dates, values };
};

// ========== Mock 数据 - 近7天AI调用次数 ==========
const getMockAICallData = () => {
  const today = new Date();
  const dates = [];
  const values = [];

  for (let i = 6; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    dates.push(`${month}-${day}`);
    values.push(Math.floor(Math.random() * 400) + 100);
  }

  return { dates, values };
};

// ========== 渲染用户增长趋势图 ==========
const renderGrowthChart = () => {
  const growthDom = document.getElementById('growthChart');
  if (!growthDom) return;

  if (growthChart.value) {
    growthChart.value.dispose();
  }

  growthChart.value = echarts.init(growthDom);
  growthChart.value.setOption({
    grid: { left: '3%', right: '4%', bottom: '3%', top: '12%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月'],
      axisLine: { lineStyle: { color: '#E2E8F0' } },
      axisLabel: { color: '#94A3B8' },
      axisTick: { show: false }
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisLabel: { color: '#94A3B8' },
      splitLine: { lineStyle: { color: '#F1F5F9' } }
    },
    series: [{
      name: '用户数',
      type: 'line',
      smooth: true,
      data: [120, 200, 340, 450, 520, 680],
      symbol: 'circle',
      symbolSize: 6,
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(99, 102, 241, 0.35)' },
          { offset: 1, color: 'rgba(99, 102, 241, 0.02)' }
        ])
      },
      lineStyle: { color: '#6366F1', width: 3 },
      itemStyle: { color: '#6366F1', borderWidth: 2, borderColor: '#fff' }
    }]
  });
};

// ========== 渲染学习时长分布图 ==========
const renderLearningChart = () => {
  const learningDom = document.getElementById('learningChart');
  if (!learningDom) return;

  if (learningChart.value) {
    learningChart.value.dispose();
  }

  learningChart.value = echarts.init(learningDom);
  learningChart.value.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)',
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderWidth: 0,
      boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
    },
    series: [{
      name: '学习时长',
      type: 'pie',
      radius: ['42%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 6,
        borderColor: '#fff',
        borderWidth: 3
      },
      label: { show: false },
      emphasis: {
        label: { show: true, fontSize: 14, fontWeight: 'bold' },
        itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0, 0, 0, 0.15)' }
      },
      data: [
        { value: 335, name: '编程', itemStyle: { color: '#6366F1' } },
        { value: 278, name: '数学', itemStyle: { color: '#14B8A6' } },
        { value: 189, name: '英语', itemStyle: { color: '#F59E0B' } },
        { value: 145, name: '物理', itemStyle: { color: '#EF4444' } },
        { value: 103, name: '其他', itemStyle: { color: '#94A3B8' } }
      ]
    }]
  });
};

// ========== 渲染AI调用趋势图 ==========
const renderAICallChart = () => {
  const aiCallDom = document.getElementById('aiCallChart');
  if (!aiCallDom) return;

  if (aiCallChart.value) {
    aiCallChart.value.dispose();
  }

  aiCallChart.value = echarts.init(aiCallDom);
  const { dates, values } = getMockAICallData();

  aiCallChart.value.setOption({
    grid: { left: '3%', right: '4%', bottom: '3%', top: '15%', containLabel: true },
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter: '{b}<br/>AI调用次数: {c}次',
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderWidth: 0
    },
    xAxis: {
      type: 'category',
      data: dates,
      axisLine: { show: false },
      axisLabel: { color: '#94A3B8' },
      axisTick: { show: false }
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisLabel: { color: '#94A3B8' },
      splitLine: { lineStyle: { color: '#F1F5F9' } }
    },
    series: [{
      name: 'AI调用次数',
      type: 'bar',
      data: values,
      barWidth: '40%',
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#818CF8' },
          { offset: 1, color: '#6366F1' }
        ]),
        borderRadius: [8, 8, 0, 0]
      },
      emphasis: {
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#A5B4FC' },
            { offset: 1, color: '#818CF8' }
          ])
        }
      }
    }]
  });
};

// ========== 渲染近30天用户增长趋势图 ==========
const renderUserGrowthChart = () => {
  const userGrowthDom = document.getElementById('userGrowthChart');
  if (!userGrowthDom) return;

  if (userGrowthChart.value) {
    userGrowthChart.value.dispose();
  }

  userGrowthChart.value = echarts.init(userGrowthDom);
  const { dates, values } = getMockUserGrowthData();

  userGrowthChart.value.setOption({
    grid: { left: '3%', right: '4%', bottom: '3%', top: '15%', containLabel: true },
    tooltip: {
      trigger: 'axis',
      formatter: '{b}<br/>新增用户: {c}人',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderWidth: 0
    },
    xAxis: {
      type: 'category',
      data: dates,
      axisLine: { lineStyle: { color: '#E2E8F0' } },
      axisLabel: {
        color: '#94A3B8',
        interval: 4,
        fontSize: 11
      },
      axisTick: { show: false }
    },
    yAxis: {
      type: 'value',
      name: '新增用户',
      nameTextStyle: { color: '#94A3B8', fontSize: 12 },
      axisLine: { show: false },
      axisLabel: { color: '#94A3B8' },
      splitLine: { lineStyle: { color: '#F1F5F9' } }
    },
    series: [{
      name: '新增用户',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 5,
      data: values,
      lineStyle: { color: '#6366F1', width: 2.5 },
      itemStyle: {
        color: '#6366F1',
        borderWidth: 2,
        borderColor: '#fff'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(99, 102, 241, 0.3)' },
          { offset: 1, color: 'rgba(99, 102, 241, 0.02)' }
        ])
      },
      emphasis: {
        itemStyle: {
          color: '#6366F1',
          borderColor: '#6366F1',
          borderWidth: 3,
          shadowBlur: 10,
          shadowColor: 'rgba(99, 102, 241, 0.4)'
        }
      }
    }]
  });
};

// ========== Mock 数据 - 统计卡片（后端未启动时使用） ==========
const getMockStats = () => ({
  totalUsers: 1250,
  totalLearningHours: 3800,
  aiInteractions: 2800,
  activeUsers: 860
})

// ========== 加载统计数据 ==========
const loadStats = async () => {
  const userStore = useUserStore()
  // 如果是模拟登录或 token 是 mock 的，直接使用 mock 数据，避免触发 401
  if (userStore.isMockLogin) {
    stats.value = getMockStats()
    return
  }
  try {
    stats.value = await getDashboardStats();
  } catch (error) {
    console.error('加载统计数据失败:', error);
    // API 请求失败时使用 mock 数据兜底
    stats.value = getMockStats()
  }
};

// ========== 初始化图表 ==========
const initCharts = async () => {
  await nextTick();
  renderGrowthChart();
  renderLearningChart();
  renderAICallChart();
  renderUserGrowthChart();
};

// ========== 窗口resize处理 ==========
const handleResize = () => {
  growthChart.value?.resize();
  learningChart.value?.resize();
  aiCallChart.value?.resize();
  userGrowthChart.value?.resize();
};

// ========== 生命周期 ==========
onMounted(() => {
  loadStats();
  initCharts();
  window.addEventListener('resize', handleResize);
});

onBeforeUnmount(() => {
  growthChart.value?.dispose();
  learningChart.value?.dispose();
  aiCallChart.value?.dispose();
  userGrowthChart.value?.dispose();
  window.removeEventListener('resize', handleResize);
});
</script>

<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <div class="stat-cards">
      <el-card
        v-for="card in statCards"
        :key="card.key"
        class="stat-card"
      >
        <div class="stat-content">
          <div class="stat-icon" :style="{ background: card.bg }">
            <component :is="card.icon" :style="{ color: card.color }" />
          </div>
          <div class="stat-info">
            <p class="stat-value">{{ stats[card.key].toLocaleString() }}</p>
            <p class="stat-label">{{ card.label }}</p>
          </div>
        </div>
        <div class="stat-trend" :style="{ color: card.color }">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
            <polyline points="17 6 23 6 23 12"></polyline>
          </svg>
          <span class="trend-value">+12.5%</span>
          <span class="trend-label">较上月</span>
        </div>
      </el-card>
    </div>

    <!-- 图表行 -->
    <div class="charts-row">
      <el-card class="chart-card">
        <template #header>
          <div class="chart-header">
            <span>用户增长趋势</span>
            <el-tag size="small" type="primary">年度</el-tag>
          </div>
        </template>
        <div id="growthChart" class="chart"></div>
      </el-card>
      <el-card class="chart-card">
        <template #header>
          <div class="chart-header">
            <span>学习时长分布</span>
            <el-tag size="small" type="success">占比</el-tag>
          </div>
        </template>
        <div id="learningChart" class="chart"></div>
      </el-card>
    </div>

    <div class="charts-row">
      <el-card class="chart-card full-width">
        <template #header>
          <div class="chart-header">
            <span>近7天AI调用趋势</span>
            <el-tag size="small" type="primary">趋势</el-tag>
          </div>
        </template>
        <div id="aiCallChart" class="chart"></div>
      </el-card>
    </div>

    <div class="charts-row">
      <el-card class="chart-card full-width">
        <template #header>
          <div class="chart-header">
            <span>近30天用户增长趋势</span>
            <el-tag size="small" type="primary">日报</el-tag>
          </div>
        </template>
        <div id="userGrowthChart" class="chart"></div>
      </el-card>
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

/* ===== 统计卡片 ===== */
.stat-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.stat-card {
  --el-card-padding: 20px;
  border-radius: var(--radius-lg);
  cursor: default;
  position: relative;
  overflow: hidden;
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
  font-size: 22px;
  flex-shrink: 0;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: var(--font-3xl);
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 2px;
  line-height: 1.2;
}

.stat-label {
  font-size: var(--font-sm);
  color: var(--color-text-tertiary);
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--color-border-light);
  font-size: var(--font-xs);
}

.trend-value {
  font-weight: 600;
}

.trend-label {
  color: var(--color-text-tertiary);
}

/* ===== 图表卡片 ===== */
.charts-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.charts-row:last-child {
  margin-bottom: 0;
}

.chart-card {
  --el-card-padding: 0;
  border-radius: var(--radius-lg);
}

.chart-card :deep(.el-card__header) {
  padding: 16px 20px;
  border-bottom: 1px solid var(--color-border-light);
}

.chart-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: var(--font-md);
  font-weight: 600;
  color: var(--color-text-primary);
}

.chart-card.full-width {
  grid-column: span 2;
}

.chart {
  height: 300px;
  padding: 4px;
}

/* ===== 响应式 ===== */
@media (max-width: 1200px) {
  .stat-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  .charts-row {
    grid-template-columns: 1fr;
  }
  .chart-card.full-width {
    grid-column: span 1;
  }
}

@media (max-width: 768px) {
  .dashboard {
    padding: var(--spacing-md);
  }
  .stat-cards {
    grid-template-columns: 1fr;
  }
}
</style>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue';
import * as echarts from 'echarts';
import { getDashboardStats, getUserGrowth, getLearningStats } from '@/api/dashboard';
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
const aiCallChart = ref(null); // AI调用次数柱状图
const userGrowthChart = ref(null); // 新增：近30天用户增长趋势折线图

// ========== 统计卡片配置 ==========
const statCards = [
  { key: 'totalUsers', label: '总用户数', icon: UserFilled, color: '#667eea' },
  { key: 'totalLearningHours', label: '学习时长', icon: Notebook, color: '#f093fb' },
  { key: 'aiInteractions', label: 'AI交互次数', icon: MagicStick, color: '#4ade80' },
  { key: 'activeUsers', label: '活跃用户', icon: TrendCharts, color: '#fbbf24' }
];

// ========== Mock 数据 - 近30天用户增长 ==========
const getMockUserGrowthData = () => {
  const today = new Date();
  const dates = [];
  const values = [];
  
  // 生成近30天日期和模拟数据
  for (let i = 29; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    dates.push(`${month}-${day}`);
    
    // 生成模拟的每日新增用户数（20-100之间的随机数，周末略高）
    const dayOfWeek = date.getDay();
    let baseValue = Math.floor(Math.random() * 60) + 20;
    // 周末用户增长略高
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
  
  // 生成近7天日期和模拟数据
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    dates.push(`${month}-${day}`);
    
    // 生成模拟的AI调用次数（100-500之间的随机数）
    values.push(Math.floor(Math.random() * 400) + 100);
  }
  
  return { dates, values };
};

// ========== 渲染用户增长趋势图（折线图） ==========
const renderGrowthChart = () => {
  const growthDom = document.getElementById('growthChart');
  if (!growthDom) return;
  
  if (growthChart.value) {
    growthChart.value.dispose();
  }
  
  growthChart.value = echarts.init(growthDom);
  growthChart.value.setOption({
    title: { 
      text: '用户增长趋势', 
      left: 'center', 
      textStyle: { fontSize: 14, color: '#666' } 
    },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月'],
      axisLine: { lineStyle: { color: '#eee' } }
    },
    yAxis: { type: 'value', axisLine: { lineStyle: { color: '#eee' } } },
    series: [{
      name: '用户数',
      type: 'line',
      smooth: true,
      data: [120, 200, 340, 450, 520, 680],
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(102, 126, 234, 0.4)' },
          { offset: 1, color: 'rgba(102, 126, 234, 0.05)' }
        ])
      },
      lineStyle: { color: '#667eea', width: 3 },
      itemStyle: { color: '#667eea' }
    }]
  });
};

// ========== 渲染学习时长分布图（饼图） ==========
const renderLearningChart = () => {
  const learningDom = document.getElementById('learningChart');
  if (!learningDom) return;
  
  if (learningChart.value) {
    learningChart.value.dispose();
  }
  
  learningChart.value = echarts.init(learningDom);
  learningChart.value.setOption({
    title: { 
      text: '学习时长分布', 
      left: 'center', 
      textStyle: { fontSize: 14, color: '#666' } 
    },
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    series: [{
      name: '学习时长',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      data: [
        { value: 335, name: '编程' },
        { value: 278, name: '数学' },
        { value: 189, name: '英语' },
        { value: 145, name: '物理' },
        { value: 103, name: '其他' }
      ],
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: { show: false },
      emphasis: {
        label: { show: true, fontSize: 16, fontWeight: 'bold' },
        itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0, 0, 0, 0.2)' }
      }
    }]
  });
};

// ========== 渲染AI调用趋势图（柱状图） ==========
const renderAICallChart = () => {
  const aiCallDom = document.getElementById('aiCallChart');
  if (!aiCallDom) return;
  
  if (aiCallChart.value) {
    aiCallChart.value.dispose();
  }
  
  aiCallChart.value = echarts.init(aiCallDom);
  
  // 获取Mock数据
  const { dates, values } = getMockAICallData();
  
  aiCallChart.value.setOption({
    title: { 
      text: '近7天AI调用趋势', 
      left: 'center', 
      textStyle: { fontSize: 14, color: '#666' } 
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: '{b}<br/>AI调用次数: {c}次'
    },
    xAxis: {
      type: 'category',
      data: dates,
      axisLine: { lineStyle: { color: '#eee' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      name: '调用次数',
      axisLine: { lineStyle: { color: '#eee' } },
      axisLabel: { color: '#666' }
    },
    series: [{
      name: 'AI调用次数',
      type: 'bar',
      data: values,
      barWidth: '50%',
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#4ade80' },
          { offset: 1, color: '#22c55e' }
        ]),
        borderRadius: [6, 6, 0, 0]
      },
      emphasis: {
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#86efac' },
            { offset: 1, color: '#4ade80' }
          ])
        }
      }
    }]
  });
};

// ========== 渲染近30天用户增长趋势图（折线图） ==========
const renderUserGrowthChart = () => {
  const userGrowthDom = document.getElementById('userGrowthChart');
  if (!userGrowthDom) return;
  
  if (userGrowthChart.value) {
    userGrowthChart.value.dispose();
  }
  
  userGrowthChart.value = echarts.init(userGrowthDom);
  
  // 获取Mock数据
  const { dates, values } = getMockUserGrowthData();
  
  userGrowthChart.value.setOption({
    title: { 
      text: '近30天用户增长趋势', 
      left: 'center', 
      textStyle: { fontSize: 14, color: '#666' } 
    },
    tooltip: {
      trigger: 'axis',
      formatter: '{b}<br/>新增用户: {c}人',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#eee',
      borderWidth: 1,
      textStyle: { color: '#333' }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '15%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: dates,
      axisLine: { lineStyle: { color: '#eee' } },
      axisLabel: { 
        color: '#666',
        interval: 4, // 每隔4个显示一个标签，避免重叠
        fontSize: 11
      },
      axisTick: { show: false }
    },
    yAxis: {
      type: 'value',
      name: '新增用户',
      nameTextStyle: { color: '#999', fontSize: 12 },
      axisLine: { lineStyle: { color: '#eee' } },
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f5f5f5' } }
    },
    series: [{
      name: '新增用户',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      data: values,
      lineStyle: { 
        color: '#667eea', 
        width: 3 
      },
      itemStyle: { 
        color: '#667eea',
        borderWidth: 2,
        borderColor: '#fff'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(102, 126, 234, 0.35)' },
          { offset: 1, color: 'rgba(102, 126, 234, 0.05)' }
        ])
      },
      emphasis: {
        itemStyle: {
          color: '#667eea',
          borderColor: '#667eea',
          borderWidth: 3,
          shadowBlur: 10,
          shadowColor: 'rgba(102, 126, 234, 0.5)'
        }
      }
    }]
  });
};

// ========== 加载统计数据 ==========
const loadStats = async () => {
  try {
    stats.value = await getDashboardStats();
  } catch (error) {
    console.error('加载统计数据失败:', error);
  }
};

// ========== 初始化图表 ==========
const initCharts = async () => {
  // 等待DOM渲染完成
  await nextTick();
  
  renderGrowthChart();
  renderLearningChart();
  renderAICallChart();
  renderUserGrowthChart(); // 新增：近30天用户增长趋势图
};

// ========== 窗口resize处理 ==========
const handleResize = () => {
  growthChart.value?.resize();
  learningChart.value?.resize();
  aiCallChart.value?.resize();
  userGrowthChart.value?.resize(); // 新增：近30天用户增长趋势图
};

// ========== 生命周期 ==========
onMounted(() => {
  loadStats();
  initCharts();
  window.addEventListener('resize', handleResize);
});

onBeforeUnmount(() => {
  // 销毁图表实例，避免内存泄漏
  growthChart.value?.dispose();
  learningChart.value?.dispose();
  aiCallChart.value?.dispose();
  userGrowthChart.value?.dispose(); // 新增：近30天用户增长趋势图
  
  // 移除事件监听
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
          <div class="stat-icon" :style="{ background: card.color + '20' }">
            <component :is="card.icon" :style="{ color: card.color }" />
          </div>
          <div class="stat-info">
            <p class="stat-value">{{ stats[card.key].toLocaleString() }}</p>
            <p class="stat-label">{{ card.label }}</p>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 第一行图表：用户增长趋势 + 学习时长分布 -->
    <div class="charts-row">
      <el-card class="chart-card">
        <div id="growthChart" class="chart"></div>
      </el-card>
      <el-card class="chart-card">
        <div id="learningChart" class="chart"></div>
      </el-card>
    </div>

    <!-- 第二行图表：近7天AI调用趋势 -->
    <div class="charts-row">
      <el-card class="chart-card full-width">
        <div id="aiCallChart" class="chart"></div>
      </el-card>
    </div>

    <!-- 第三行图表：近30天用户增长趋势（新增） -->
    <div class="charts-row">
      <el-card class="chart-card full-width">
        <div id="userGrowthChart" class="chart"></div>
      </el-card>
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #999;
}

.charts-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.charts-row:last-child {
  margin-bottom: 0;
}

.chart-card {
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.chart-card.full-width {
  grid-column: span 2;
}

.chart {
  height: 300px;
}

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
  .stat-cards {
    grid-template-columns: 1fr;
  }
}
</style>
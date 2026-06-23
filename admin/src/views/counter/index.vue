<template>
  <div class="page-container">
    <el-card shadow="hover">
      <template #header>
        <div class="page-header">
          <span class="page-title">计数器 - ref 响应式示例</span>
        </div>
      </template>

      <!-- 计数器展示区域 -->
      <div class="counter-area">
        <div class="counter-display" @click="increment">
          <span class="counter-number">{{ count }}</span>
          <span class="counter-hint">点击数字 +1</span>
        </div>

        <div class="counter-actions">
          <el-button type="danger" @click="decrement">-1</el-button>
          <el-button @click="reset">重置</el-button>
        </div>
      </div>

      <!-- ref 使用说明 -->
      <el-divider>ref 与 reactive 的区别</el-divider>
      <div class="explanation">
        <el-alert
          title="ref 使用场景"
          type="info"
          :closable="false"
          description="ref 用于定义基本类型数据（字符串、数字、布尔值等）。在 JavaScript 中需要通过 .value 访问和修改值，但在模板中可以直接使用变量名。"
        />
        <div class="code-example">
          <pre><code>// 定义响应式数据
const count = ref(0)

// 在 JavaScript 中访问/修改（必须加 .value）
console.log(count.value)  // 0
count.value++              // 1

// 在模板中直接使用（不需要 .value）
// &lt;div&gt;{{ count }}&lt;/div&gt;</code></pre>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElCard, ElButton, ElDivider, ElAlert } from 'element-plus'

// ========== ref 响应式变量 ==========
// ref 用于定义基本类型数据的响应式引用
// 初始值为 0
const count = ref(0)

// ========== 事件处理函数 ==========
// 点击数字自增
const increment = () => {
  // 在 JS 中修改 ref 值必须使用 .value
  count.value++
}

// 点击按钮减1
const decrement = () => {
  count.value--
}

// 重置计数器
const reset = () => {
  count.value = 0
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.page-title {
  font-size: 16px;
  font-weight: 600;
}

.counter-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 20px;
}

.counter-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: transform 0.2s;
  padding: 30px 60px;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 8px 16px rgba(102, 126, 234, 0.3);
}

.counter-display:hover {
  transform: scale(1.05);
}

.counter-display:active {
  transform: scale(0.95);
}

.counter-number {
  font-size: 72px;
  font-weight: bold;
  line-height: 1;
}

.counter-hint {
  font-size: 14px;
  margin-top: 10px;
  opacity: 0.8;
}

.counter-actions {
  display: flex;
  gap: 15px;
  margin-top: 30px;
}

.explanation {
  margin-top: 20px;
}

.code-example {
  margin-top: 15px;
  background: #1e1e1e;
  border-radius: 8px;
  padding: 15px;
  overflow-x: auto;
}

.code-example pre {
  margin: 0;
}

.code-example code {
  color: #9cdcfe;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.5;
}
</style>

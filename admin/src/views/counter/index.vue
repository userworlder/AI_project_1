<template>
  <div class="page-container">
    <div class="page-header">
      <h2>计数器</h2>
      <span class="page-desc">ref 响应式示例</span>
    </div>

    <el-card class="demo-card" shadow="never">
      <!-- 计数器展示区域 -->
      <div class="counter-area">
        <div class="counter-display" @click="increment">
          <transition name="counter-bounce" mode="out-in">
            <span class="counter-number" :key="count">{{ count }}</span>
          </transition>
          <span class="counter-hint">点击数字 +1</span>
        </div>

        <div class="counter-actions">
          <el-button type="danger" plain @click="decrement">-1</el-button>
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

const count = ref(0)

const increment = () => {
  count.value++
}

const decrement = () => {
  count.value--
}

const reset = () => {
  count.value = 0
}
</script>

<style scoped>
.page-container {
  padding: var(--spacing-lg);
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: var(--spacing-lg);
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

.demo-card {
  border-radius: var(--radius-lg);
}

.demo-card :deep(.el-card__body) {
  padding: 32px;
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
  padding: 36px 80px;
  border-radius: var(--radius-xl);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%);
  color: white;
  box-shadow: 0 8px 32px rgba(99, 102, 241, 0.3);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  user-select: none;
}

.counter-display:hover {
  transform: scale(1.03);
  box-shadow: 0 12px 40px rgba(99, 102, 241, 0.4);
}

.counter-display:active {
  transform: scale(0.97);
}

.counter-number {
  font-size: 72px;
  font-weight: 800;
  line-height: 1;
  letter-spacing: -2px;
}

.counter-hint {
  font-size: var(--font-base);
  margin-top: 12px;
  opacity: 0.8;
  font-weight: 400;
}

.counter-actions {
  display: flex;
  gap: 16px;
  margin-top: 32px;
}

.explanation {
  margin-top: 20px;
}

.code-example {
  margin-top: 15px;
  background: #1E293B;
  border-radius: var(--radius-md);
  padding: 20px;
  overflow-x: auto;
}

.code-example pre {
  margin: 0;
}

.code-example code {
  color: #A5B4FC;
  font-family: 'JetBrains Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.7;
}

/* 数字切换动画 */
.counter-bounce-enter-active {
  animation: bounce-in 0.25s ease;
}
.counter-bounce-leave-active {
  animation: bounce-in 0.15s ease reverse;
}
@keyframes bounce-in {
  0% { transform: scale(0.5); opacity: 0.3; }
  100% { transform: scale(1); opacity: 1; }
}
</style>

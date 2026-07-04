<template>
  <div class="not-found-page">
    <div class="not-found-content">
      <div class="error-code">404</div>
      <h1 class="error-title">页面未找到</h1>
      <p class="error-desc">抱歉，您访问的页面不存在或已被移除</p>
      <div class="action-btns">
        <el-button type="primary" @click="$router.push('/dashboard')">返回首页</el-button>
        <el-button @click="$router.back()">返回上一页</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.not-found-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f6fa;
}

.not-found-content {
  text-align: center;
  padding: 40px;
}

.error-code {
  font-size: 120px;
  font-weight: 700;
  color: #6366f1;
  line-height: 1;
  margin-bottom: 16px;
  opacity: 0.8;
}

.error-title {
  font-size: 28px;
  color: #333;
  margin: 0 0 12px 0;
  font-weight: 600;
}

.error-desc {
  font-size: 16px;
  color: #999;
  margin: 0 0 32px 0;
}

.action-btns {
  display: flex;
  gap: 12px;
  justify-content: center;
}
</style>

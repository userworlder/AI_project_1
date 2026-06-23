# AI 智能聊天页面使用指南

## 📋 功能概述

本项目实现了一个完整的 AI 智能聊天页面，包含以下功能：

### ✅ 基础功能
1. **完整的聊天界面**
   - 顶部标题栏（返回按钮、标题、清空按钮）
   - 消息列表区域（空状态提示 + 消息气泡）
   - 底部输入栏（文本输入 + 发送按钮）

2. **消息样式区分**
   - 用户消息：右对齐，蓝色气泡（#409EFF），白色文字
   - AI 消息：左对齐，灰色气泡（#F4F4F5），深色文字
   - 每条消息下方显示格式化时间

3. **自动滚动**
   - 发送消息后自动滚动到最新消息

4. **Dify API 接入**
   - 调用本地部署的 Dify 平台 API
   - 支持阻塞模式响应

### 🚀 进阶练习一：多轮对话（上下文连续）
- ViewModel 中维护 `conversationId`
- 首次请求传空字符串，后续请求携带返回的 `conversation_id`
- 点击"清空"按钮时重置会话 ID

### 🎨 进阶练习二：Markdown 渲染
- 自定义 `MarkdownRenderer` 组件
- 支持以下语法：
  - `**加粗文本**` → 粗体显示
  - `` `行内代码` `` → 等宽字体、浅灰背景、圆角边框
  - `\n` 换行 → 正确分段显示

---

## 📁 文件结构

```
entry/src/main/ets/
├── pages/
│   └── Chat.ets                    # 聊天页面（主入口）
├── model/
│   ├── ChatMessage.ets             # 数据模型（ChatMessage, ChatRequest, DifyResponse）
│   └── ChatViewModel.ets           # ViewModel 层（业务逻辑）
├── components/
│   └── MarkdownRenderer.ets        # Markdown 渲染器组件（练习二）
├── http/
│   └── DifyApi.ets                 # Dify API 接口封装
└── common/
    └── DateUtil.ets                # 日期格式化工具类
```

---

## 🔧 配置说明

### 1. Dify API 配置

打开 `entry/src/main/ets/http/DifyApi.ets`，修改以下配置：

```typescript
// Dify API 基地址
private static readonly BASE_URL: string = 'http://10.0.2.2/v1'
// 替换为你的实际 API Key
private static readonly API_KEY: string = 'app-xxx'
```

**注意：**
- 模拟器使用 `10.0.2.2` 访问电脑本地服务
- 真机调试时，需将 `10.0.2.2` 替换为电脑的局域网 IP（如 `192.168.1.100`）
- `app-xxx` 需替换为你在 Dify 平台创建的应用 API Key

### 2. 路由注册

已在 `main_pages.json` 中自动注册：
```json
{
  "src": [
    ...
    "pages/Chat"
  ]
}
```

### 3. 入口按钮

已在 Home 页面添加"AI智能对话"按钮，点击即可跳转到聊天页面。

---

## 🚀 使用方法

### 启动步骤

1. **确保 Dify 平台已启动**
   ```bash
   # 假设 Dify 运行在本地 80 端口
   # 访问 http://localhost/v1/chat-messages 测试
   ```

2. **配置 API Key**
   - 在 Dify 平台创建应用
   - 复制 API Key 到 `DifyApi.ets` 的 `API_KEY` 字段

3. **编译运行**
   ```bash
   # 使用 DevEco Studio 编译运行
   # 或使用命令行
   hvigorw assembleHap
   ```

4. **进入聊天页面**
   - 启动应用后，在 Home 页面点击"AI智能对话"按钮
   - 或在代码中使用路由跳转：
     ```typescript
     router.pushUrl({ url: 'pages/Chat' })
     ```

### 基本操作

- **发送消息**：在输入框输入问题，点击"发送"或按回车
- **清空对话**：点击右上角"清空"按钮
- **返回上一页**：点击左上角返回箭头

---

## 💡 核心代码解析

### 1. ViewModel 层（ChatViewModel.ets）

```typescript
@Observed
export class ChatViewModel {
  messages: ChatMessage[] = []      // 消息列表
  sending: boolean = false          // 发送状态
  conversationId: string = ''       // 会话 ID（练习一）

  async sendMessage(content: string): Promise<void> {
    // 1. 添加用户消息
    // 2. 调用 Dify API
    // 3. 保存 conversation_id
    // 4. 添加 AI 回复
    // 5. 错误处理
  }

  clearMessages(): void {
    this.messages = []
    this.conversationId = ''  // 重置会话 ID
  }
}
```

**关键点：**
- 使用 `@Observed` 装饰器实现响应式
- `conversationId` 在首次请求后从响应中提取
- 清空时同时重置会话 ID

### 2. Markdown 渲染器（MarkdownRenderer.ets）

```typescript
@Component
export struct MarkdownRenderer {
  @Prop content: string = ''

  build() {
    Column() {
      ForEach(this.parseContent(), (paragraph, index) => {
        this.renderParagraph(paragraph, index)
      })
    }
  }

  private tokenize(text: string): Token[] {
    // 正则匹配：**加粗**、`代码`、普通文本
  }
}
```

**支持的语法：**
- `**text**` → 粗体
- `` `code` `` → 代码块
- `\n` → 换行分段

### 3. 日期格式化（DateUtil.ets）

```typescript
static formatFriendly(timestamp: number): string {
  // 今天 → "HH:mm"
  // 昨天 → "昨天 HH:mm"
  // 其他 → "MM-dd HH:mm"
}
```

---

## 🐛 常见问题

### 1. API 请求失败
**原因：**
- Dify 服务未启动
- API Key 配置错误
- 网络地址不正确（模拟器 vs 真机）

**解决：**
- 检查 Dify 服务是否正常运行
- 确认 API Key 是否正确
- 模拟器用 `10.0.2.2`，真机用电脑局域网 IP

### 2. Markdown 渲染不生效
**原因：**
- AI 回复不包含 Markdown 语法
- 正则表达式匹配失败

**解决：**
- 在 Dify 平台测试时，要求 AI 返回带格式的文本
- 检查 `tokenize` 方法的正则表达式

### 3. 消息列表不滚动
**原因：**
- `scroller.scrollToIndex` 调用时机不对

**解决：**
- 已在 `setTimeout` 中调用，确保 DOM 更新后滚动

---

## 📝 扩展建议

### 1. 流式响应（SSE）
当前使用阻塞模式（`response_mode: 'blocking'`），可改为流式：
```typescript
response_mode: 'streaming'
// 使用 EventSource 接收实时推送
```

### 2. 消息持久化
使用 `preferences` 保存聊天记录：
```typescript
import dataPreferences from '@ohos.data.preferences'
// 保存/加载 messages 数组
```

### 3. 更多 Markdown 语法
扩展 `MarkdownRenderer` 支持：
- 列表（`- item`）
- 链接（`[text](url)`）
- 图片（`![alt](url)`）
- 代码块（`` ```code``` ``）

### 4. 表情和富媒体
- 支持 Emoji 表情
- 支持图片消息
- 支持语音消息

---

## 📚 相关文档

- [ArkTS 官方文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-get-started-0000001773123637-V3)
- [ArkUI 声明式开发](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkui-ts-declarative-development-overview-0000001773123649-V3)
- [Dify API 文档](https://docs.dify.ai/v/zh-hans/advanced/api-reference)

---

## ✨ 总结

本项目完整实现了：
1. ✅ 基础聊天功能（消息收发、样式区分、自动滚动）
2. ✅ 多轮对话上下文（练习一）
3. ✅ Markdown 富文本渲染（练习二）

所有代码符合 ArkTS 规范，可直接运行。只需配置好 Dify API 地址和 Key 即可使用！

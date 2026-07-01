# AI 聊天流式响应修复说明

## 问题描述
后端能正常返回 AI 回复内容，但移动端一直显示"思考中..."加载状态或"AI 响应超时"。

## 根本原因
**HarmonyOS `@ohos.net.http` 模块的 `dataReceive` 事件不支持真正的 SSE 流式接收**。该事件在请求完成后才会触发，而不是实时接收数据流。

### 技术细节
- HarmonyOS HTTP 模块设计用于普通 HTTP 请求/响应模式
- `dataReceive` 事件在完整响应到达后触发，而非每个数据包
- SSE 需要真正的流式处理能力，当前模块不支持

## 修复方案

### 核心思路：从 SSE 流式改为普通 HTTP 请求 + 响应解析

由于 HarmonyOS HTTP 模块不支持真正的 SSE 流式，我们改用**阻塞模式**接收完整响应，然后在客户端解析 SSE 格式。

### 1. 修改 ChatApiService.ets（关键）

**之前**：使用 `dataReceive` 事件监听流式数据（不工作）
```typescript
// ❌ 旧代码 - dataReceive 不会实时触发
request.on('dataReceive', (data: ArrayBuffer) => {
  // ...
})
```

**现在**：等待完整响应后解析
```typescript
// ✅ 新代码 - 普通 HTTP 请求 + 响应解析
const response = await request.request(url, {
  method: http.RequestMethod.POST,
  header: headers,
  extraData: body,
  connectTimeout: 30000,
  readTimeout: 60000 // 设置 60 秒超时
})

if (response.responseCode === 200) {
  const resultStr = response.result.toString()
  const lines = resultStr.split('\n')
  
  for (const line of lines) {
    if (line.trim().startsWith('data:')) {
      const data = line.trim().slice(5).trim()
      if (data !== '[DONE]') {
        callbacks.onData(data)
      }
    }
  }
  callbacks.onComplete()
}
```
### 2. 超时机制（ChatViewModel.ets）

虽然改为阻塞模式，但保留超时机制防止请求卡死：
- **首次响应超时**：30 秒（给后端足够的 AI 推理时间）
- **读取超时**：60 秒（HTTP 请求层面）

```typescript
// 首次响应超时（5 秒）
firstResponseTimeoutId = setTimeout(() => {
  if (!isCompleted && fullReply.length === 0) {
    console.warn('[ChatViewModel] 首次响应超时')
    this.messages[aiMsgIndex].content = '抱歉，AI 响应超时，请稍后重试。'
    this.sending = false
    this.chatApi.cancel()
  }
}, 5000)

// 空闲超时（10 秒）
idleTimeoutId = setTimeout(() => {
  if (!isCompleted) {
    console.warn('[ChatViewModel] 空闲超时，强制结束')
    this.sending = false
    this.chatApi.cancel()
  }
}, 10000)
```

### 3. 增强日志输出

增加详细的请求/响应日志，方便排查问题：
- 请求体内容
- 响应状态码
- 响应数据类型和长度
- 每行解析结果

## 验证步骤

### 1. 重新编译运行
```bash
# 在 DevEco Studio 中重新构建并运行项目
```

### 2. 查看日志输出
使用 DevEco Studio 的 Log 窗口或 hdc 命令查看日志：

```bash
# 过滤关键日志
hdc shell hilog | grep -E "ChatViewModel|ChatApiService"
```

#### ✅ 正常流程日志示例：
```
[ChatViewModel] 初始化完成，sessionId=xxx
[ChatApiService] SSE 请求开始: POST http://10.0.2.2:8080/api/ai/chat/message/stream
[ChatApiService] 请求体: {"sessionId":"xxx","message":"你好"}
[ChatApiService] 响应状态码: 200
[ChatApiService] 响应数据类型: string
[ChatApiService] 响应内容长度: 128
[ChatApiService] 响应内容: data: {"content":"你好"}\ndata: {"content":"！"}\ndata: [DONE]
[ChatApiService] 响应共 3 行
[ChatApiService] 解析到数据: {"content":"你好"}
[ChatApiService] 提取 content: 你好
[ChatApiService] 解析到数据: {"content":"！"}
[ChatApiService] 提取 content: ！
[ChatApiService] 收到 [DONE] 信号
[ChatApiService] 调用 onComplete
[ChatViewModel] 流式接收完成，总长度=6
```

#### ❌ 异常情况日志示例：
```
[ChatApiService] 响应状态码: 401
[ChatApiService] 请求失败，状态码: 401
// 或
[ChatApiService] 请求异常: code=408, message=timeout
// 或
[ChatViewModel] 首次响应超时（30秒）
```

### 3. 测试场景

#### 场景 1：正常对话
- 输入问题并发送
- 预期：等待后端响应（最多 60 秒），然后一次性显示完整 AI 回复

#### 场景 2：后端延迟响应
- 模拟后端处理时间 > 30 秒
- 预期：30 秒后显示"AI 响应超时"

#### 场景 3：后端返回错误
- 模拟后端返回 401/500 等错误
- 预期：显示具体错误信息

#### 场景 4：网络异常
- 断网或服务器不可达
- 预期：显示连接错误

## 后端建议

### 重要：后端响应格式

虽然前端改为阻塞模式，但后端**仍需返回 SSE 格式**（按行分割的 `data:` 前缀格式）。

#### 标准 SSE 格式示例
```
data: {"content":"你好"}
data: {"content":"！"}
data: [DONE]

```

**注意**：
1. ✅ 每个事件以 `data:` 开头
2. ✅ 每个事件以换行符 `\n` 结尾
3. ✅ 最后发送 `[DONE]` 信号表示结束
4. ✅ 整个响应完成后关闭 HTTP 连接
data: {"content":"你好"}

data: {"content":"！"}

data: [DONE]

```

### Spring Boot 示例（阻塞模式）

```java
@PostMapping("/api/ai/chat/message/stream")
public ResponseEntity<String> streamChat(@RequestBody ChatRequest request) {
    StringBuilder response = new StringBuilder();
    
    // 模拟 AI 推理过程
    String aiResponse = chatService.generateResponse(request.getMessage());
    
    // 按字符或词元分割，生成 SSE 格式响应
    for (char c : aiResponse.toCharArray()) {
        response.append("data: {\"content\":\"")
                .append(c)
                .append("\"}\n");
    }
    
    // 添加结束信号
    response.append("data: [DONE]\n");
    
    return ResponseEntity.ok()
            .contentType(MediaType.TEXT_PLAIN)
            .body(response.toString());
}
```

**或者使用真正的流式（如果后端支持）**：

```java
@GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<ServerSentEvent<String>> streamChat(@RequestBody ChatRequest request) {
    return chatService.streamChat(request)
        .map(content -> ServerSentEvent.<String>builder()
            .data("{\"content\":\"" + content + "\"}")
            .build())
        .concatWith(Mono.just(ServerSentEvent.<String>builder()
            .data("[DONE]")
            .build()));
}
```

**关键点**：
1. ✅ 每个事件以双换行 `\n\n` 结尾（或单 `\n`）
2. ✅ 最后发送 `[DONE]` 信号
3. ✅ 整个响应完成后关闭 HTTP 连接

## 常见问题排查

### Q1: 仍然一直显示"思考中..."
**检查日志**：
- 是否有 `[ChatApiService] 响应状态码` 日志？
  - ❌ 没有 → 网络不通或后端未响应，检查 URL 和网络
  - ✅ 有 → 继续检查下一项
- 响应内容长度是否为 0？
  - ✅ 是 → 后端返回空响应
  - ❌ 否 → 继续检查下一项
- 是否有 `[ChatApiService] 解析到数据` 日志？
  - ❌ 没有 → SSE 格式不正确，检查后端是否按 `data:` 前缀格式返回
  - ✅ 有 → 继续检查下一项
- 是否有 `[ChatApiService] 提取 content` 日志？
  - ❌ 没有 → JSON 格式不正确，检查后端返回的 JSON 结构
  - ✅ 有 → 问题应该解决了

### Q2: 显示"AI 响应超时"
**原因**：后端处理时间超过 30 秒
**解决**：
- 优化后端 AI 推理速度
- 或增加超时时间（修改 `ChatViewModel.ets` 第 69 行）

### Q3: 响应内容为空或显示不完整
**原因**：SSE 格式解析失败
**解决**：
- 查看日志中的 `[ChatApiService] 响应内容`，确认后端返回的格式
- 确保每行以 `data:` 开头
- 确保 JSON 格式正确：`{"content":"xxx"}`

### Q4: 显示 "JSON 解析失败"
**原因**：后端返回的内容不是有效的 JSON
**解决**：
- 检查后端是否正确转义特殊字符
- 或者后端直接返回纯文本（不带 JSON 包装）

## 修改文件清单
1. `entry/src/main/ets/http/ChatApiService.ets` - 从 SSE 流式改为阻塞模式 + 响应解析
2. `entry/src/main/ets/model/ChatViewModel.ets` - 超时机制调整（30秒首次响应）

# Dify API 快速配置指南

## 🎯 配置步骤

### 第一步：获取 Dify API Key

1. **访问 Dify 平台**
   - 本地部署：http://localhost
   - 或你的 Dify 服务器地址

2. **创建应用**
   - 点击"创建应用"
   - 选择"聊天助手"类型
   - 填写应用名称（如"灵思·AI学伴助手"）

3. **获取 API Key**
   - 进入应用详情页
   - 点击左侧"API 密钥"菜单
   - 复制 API Key（格式类似：`app-xxxxxxxxxxxxxxxxxxxx`）

---

### 第二步：修改配置文件

打开文件：`entry/src/main/ets/http/DifyApi.ets`

找到以下代码（第 9-11 行）：

```typescript
private static readonly BASE_URL: string = 'http://10.0.2.2:8080/v1'
private static readonly API_KEY: string = 'app-xxx'
```

**修改为：**

```typescript
// 模拟器使用 10.0.2.2，真机使用电脑局域网 IP
// 注意：需要根据你的 Dify 服务实际端口修改（常见端口：80, 5001, 8080）
private static readonly BASE_URL: string = 'http://10.0.2.2:8080/v1'
// 替换为你实际的 API Key
private static readonly API_KEY: string = 'app-你的实际APIKey'
```

---

### 第三步：选择正确的网络地址

根据你的运行环境选择：

#### 场景 A：鸿蒙模拟器
```typescript
// 如果 Dify 运行在默认端口 80
private static readonly BASE_URL: string = 'http://10.0.2.2/v1'

// 如果 Dify 运行在端口 8080（推荐）
private static readonly BASE_URL: string = 'http://10.0.2.2:8080/v1'

// 如果 Dify 运行在端口 5001
private static readonly BASE_URL: string = 'http://10.0.2.2:5001/v1'
```
**说明：** `10.0.2.2` 是模拟器访问电脑本地的特殊地址，后面需要加上 Dify 服务的端口号

#### 场景 B：真机调试（USB 连接）
```typescript
// 假设电脑局域网 IP 为 192.168.1.100，Dify 运行在端口 8080
private static readonly BASE_URL: string = 'http://192.168.1.100:8080/v1'
```
**如何查看电脑 IP：**
- Windows：打开命令提示符，输入 `ipconfig`，查看 IPv4 地址
- Mac/Linux：打开终端，输入 `ifconfig` 或 `ip addr`

**如何查看 Dify 端口：**
- 查看 Dify 启动日志或配置文件
- 常见端口：80（默认）、5001、8080
- Docker 部署：查看 docker-compose.yml 中的端口映射

#### 场景 C：Dify 部署在远程服务器
```typescript
private static readonly BASE_URL: string = 'https://your-dify-domain.com/v1'
```

---

### 第四步：测试连接

#### 方法 1：使用 curl 测试（推荐）

在命令行执行：

```bash
# 模拟器环境（端口 8080）
curl -X POST http://10.0.2.2:8080/v1/chat-messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer app-你的APIKey" \
  -d '{
    "query": "你好",
    "conversation_id": "",
    "response_mode": "blocking",
    "user": "test-user"
  }'
```

**预期响应：**
```json
{
  "answer": "你好！有什么可以帮助你的吗？",
  "conversation_id": "xxx-xxx-xxx",
  "message_id": "yyy-yyy-yyy",
  "created_at": 1234567890
}
```

#### 方法 2：使用 Postman

1. 新建 POST 请求
2. URL：`http://10.0.2.2:8080/v1/chat-messages`（注意端口号）
3. Headers：
   - `Content-Type`: `application/json`
   - `Authorization`: `Bearer app-你的APIKey`
4. Body（raw JSON）：
   ```json
   {
     "query": "你好",
     "conversation_id": "",
     "response_mode": "blocking",
     "user": "test-user"
   }
   ```
5. 点击 Send

---

## ⚠️ 常见问题

### 问题 1：连接超时

**错误信息：**
```
[DifyApi] 请求异常: 连接超时
```

**解决方案：**
1. 确认 Dify 服务已启动
   ```bash
   # 检查 Dify 容器是否运行
   docker ps | grep dify
   ```

2. 确认防火墙允许访问
   ```bash
   # Windows：添加入站规则允许 80 端口
   # Linux：sudo ufw allow 80/tcp
   ```

3. 测试本地访问
   ```bash
   curl http://localhost/v1/chat-messages
   ```

---

### 问题 2：401 Unauthorized

**错误信息：**
```
[DifyApi] 请求失败，状态码：401
```

**解决方案：**
1. 检查 API Key 是否正确（注意不要有多余空格）
2. 确认 API Key 未过期
3. 在 Dify 平台重新生成 API Key

---

### 问题 3：404 Not Found

**错误信息：**
```
[DifyApi] 请求失败，状态码：404
```

**解决方案：**
1. 检查 BASE_URL 是否正确
   - 应该包含端口号，如 `http://10.0.2.2:8080/v1`
   - 确认端口号与 Dify 服务实际运行的端口一致
2. 确认 Dify 版本支持 API v1
3. 查看 Dify 文档确认 API 路径
4. 测试本地访问：
   ```bash
   # 测试不同端口
   curl http://localhost:8080/v1/chat-messages
   curl http://localhost:5001/v1/chat-messages
   curl http://localhost/v1/chat-messages
   ```

---

### 问题 4：CORS 错误（浏览器环境）

**说明：** 鸿蒙原生应用不受 CORS 限制，此问题仅在使用 Web 组件时出现

**解决方案：**
在 Dify 后端配置 CORS：
```nginx
add_header 'Access-Control-Allow-Origin' '*';
add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
```

---

## 🔧 高级配置

### 1. 修改超时时间

默认超时时间为 30 秒，如需调整：

```typescript
const response = await request.request(url, {
  method: http.RequestMethod.POST,
  header: headers,
  extraData: JSON.stringify(requestBody),
  connectTimeout: 60000,  // 连接超时 60 秒
  readTimeout: 60000      // 读取超时 60 秒
})
```

### 2. 添加请求日志

在 `DifyApi.ets` 中已有详细日志：
```typescript
console.info(`[DifyApi] 请求开始: POST ${url}`)
console.info(`[DifyApi] 请求体: ${JSON.stringify(requestBody)}`)
console.info(`[DifyApi] 响应状态码: ${response.responseCode}`)
console.info(`[DifyApi] 响应体: ${response.result.toString()}`)
```

在 DevEco Studio 的 Log 窗口过滤 `[DifyApi]` 即可查看。

### 3. 切换响应模式

当前使用阻塞模式（`blocking`），如需流式响应：

```typescript
const requestBody = {
  query: query,
  conversation_id: conversationId,
  response_mode: 'streaming',  // 改为流式
  user: 'student-001'
}
```

**注意：** 流式响应需要使用 EventSource 或 WebSocket 接收，当前代码不支持。

---

## 📋 配置检查清单

完成配置后，确认以下项：

- [ ] Dify 服务已启动并可访问
- [ ] 已创建应用并获取 API Key
- [ ] `BASE_URL` 配置正确（根据运行环境）
- [ ] `API_KEY` 已替换为实际值
- [ ] 使用 curl 或 Postman 测试通过
- [ ] 应用中发送消息能收到 AI 回复
- [ ] 控制台无错误日志

---

## 🆘 获取帮助

如果遇到问题：

1. **查看 Dify 官方文档**
   - https://docs.dify.ai/v/zh-hans/advanced/api-reference

2. **查看应用日志**
   ```bash
   # Docker 部署
   docker logs dify-api
   
   # 查看最近 100 行
   docker logs --tail 100 dify-api
   ```

3. **检查网络连接**
   ```bash
   # 测试能否访问 Dify
   ping 10.0.2.2  # 模拟器
   ping 192.168.1.100  # 真机（替换为实际 IP）
   ```

---

## ✅ 配置完成

配置完成后，你可以：

1. 编译运行应用
2. 进入聊天页面
3. 发送第一条消息测试
4. 享受 AI 对话功能！🎉

# 灵思·AI学伴 - API 接口测试指南

> 本文档面向测试人员，详细描述后端所有 API 接口的请求方式、参数和响应格式。

---

## 一、基本信息

### 1.1 环境信息
| 项目 | 内容 |
|------|------|
| 项目名 | 灵思·AI学伴 |
| 基础地址 | `http://localhost:8080` |
| API 前缀 | `/api` |
| 认证方式 | JWT Bearer Token |
| 文档格式 | Swagger / OpenAPI 3.0 |

### 1.2 统一响应格式

所有接口返回统一的 JSON 结构：

```json
{
  "code": 200,        // 状态码：200=成功，其他=失败
  "message": "操作成功",  // 提示信息
  "data": { ... }     // 具体数据（可能为 null）
}
```

### 1.3 分页响应格式

分页接口返回 `PageResult`，结构如下：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 100,       // 总记录数
    "current": 1,       // 当前页码
    "size": 10,         // 每页条数
    "records": [ ... ]  // 当前页数据列表
  }
}
```

### 1.4 状态码说明
| 状态码 | 含义 |
|-------|------|
| 200 | 请求成功 |
| 400 | 参数错误（如必填字段为空） |
| 401 | 未登录或 Token 已过期 |
| 403 | 无权限访问 |
| 500 | 服务端异常 |

### 1.5 认证方式

需要鉴权的接口需要在请求头中携带 Token：

```
Authorization: Bearer <登录时获取的token>
```

**测试步骤：**
1. 调用登录接口获取 Token
2. 将 Token 添加到请求头
3. 访问其他需鉴权的接口

---

## 二、接口分类总览

| 模块 | 分组标签 | 基础路径 |
|------|---------|---------|
| [认证管理](#21-认证管理) | 认证管理 | `/api/auth` |
| [管理员认证](#22-管理员认证) | 管理员认证 | `/api/admin` |
| [用户管理](#23-用户管理) | 用户管理 | `/api/users` |
| [技能管理](#24-技能管理) | 技能管理 | `/api/skills` |
| [学习记录管理](#25-学习记录管理) | 学习记录管理 | `/api/study-records` |
| [简历评估管理](#26-简历评估管理) | 简历评估管理 | `/api/resumes` |
| [订单管理](#27-订单管理) | 订单管理 | `/api/orders` |
| [AI配置管理](#28-ai配置管理) | AI配置管理 | `/api/ai/configs` |
| [仪表盘](#29-仪表盘) | 仪表盘 | `/api/dashboard` |

---

## 三、接口详情

### 2.1 认证管理

#### POST `/api/auth/register` — 用户注册

**请求头：** 无（无需鉴权）

**请求体（JSON）：**
```json
{
  "username": "testuser",       // 必填，3-20个字符
  "password": "123456",         // 必填，6-30个字符
  "nickname": "测试用户",       // 选填，1-20个字符
  "email": "test@example.com",  // 选填，邮箱格式
  "phone": "13800138000"        // 选填，11位手机号
}
```

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "phone": "13800138000",
    "nickname": "测试用户",
    "avatar": null,
    "role": "user",
    "status": 1,
    "createTime": "2026-06-24 10:00:00"
  }
}
```

---

#### POST `/api/auth/login` — 用户登录

**请求头：** 无（无需鉴权）

**请求体（JSON）：**
```json
{
  "username": "testuser",   // 必填
  "password": "123456"      // 必填
}
```

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "username": "testuser",
      "nickname": "测试用户",
      "email": "test@example.com",
      "phone": "13800138000",
      "avatar": null,
      "role": "user",
      "status": 1,
      "createTime": "2026-06-24 10:00:00"
    }
  }
}
```

**测试要点：**
- 登录成功后会返回 JWT Token，后续请求需携带此 Token
- Token 有效期默认为 1 天

---

#### POST `/api/auth/logout` — 用户登出

**请求头：** 需要 Bearer Token

**请求体：** 无

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "登出成功",
  "data": null
}
```

---

#### POST `/api/auth/admin/login` — 管理员登录

与用户登录接口功能相同，专为管理前端提供的兼容路径。

---

### 2.2 管理员认证

#### POST `/api/admin/login` — 管理员登录

与 `/api/auth/login` 功能一致。

---

#### GET `/api/admin/info` — 获取管理员信息

**请求头：** 需要 Bearer Token

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "管理员",
    "role": "admin",
    ...
  }
}
```

---

### 2.3 用户管理

#### GET `/api/users/me` — 获取当前登录用户信息

**请求头：** 需要 Bearer Token

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "nickname": "测试用户",
    "email": "test@example.com",
    "phone": "13800138000",
    "avatar": null,
    "role": "user",
    "status": 1,
    "createTime": "2026-06-24 10:00:00"
  }
}
```

---

#### PUT `/api/users/me/password` — 修改当前用户密码

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "oldPassword": "123456",    // 必填，旧密码
  "newPassword": "654321"     // 必填，6-30个字符，新密码
}
```

---

#### GET `/api/users/{id}` — 获取指定用户信息

**请求头：** 需要 Bearer Token

**路径参数：**
| 参数 | 类型 | 说明 |
|------|------|------|
| id   | Long | 用户ID |

---

#### PUT `/api/users/{id}` — 更新用户信息

**请求头：** 需要 Bearer Token

**路径参数：** `id` (Long)

**请求体（JSON）：**
```json
{
  "nickname": "新昵称",
  "email": "new@example.com",
  "phone": "13900139000"
}
```

---

#### GET `/api/users` 或 `/api/users/list` — 分页查询用户列表

**请求头：** 需要 Bearer Token

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| keyword | string | - | 搜索关键词（用户名/昵称） |

---

#### DELETE `/api/users/{id}` — 删除用户

**请求头：** 需要 Bearer Token

**路径参数：** `id` (Long)

---

### 2.4 技能管理

#### POST `/api/skills` — 新增技能

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "name": "Java基础",         // 必填
  "category": "后端开发",     // 必填
  "description": "Java语言基础",
  "level": 1,
  "parentId": null
}
```

---

#### PUT `/api/skills/{id}` — 更新技能

**请求头：** 需要 Bearer Token

---

#### DELETE `/api/skills/{id}` — 删除技能

**请求头：** 需要 Bearer Token

---

#### GET `/api/skills/{id}` — 获取技能详情

**请求头：** 需要 Bearer Token

---

#### GET `/api/skills` — 分页查询技能列表

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| keyword | string | - | 搜索关键词 |

---

#### GET `/api/skills/tree` — 获取技能树（全量）

**请求头：** 需要 Bearer Token

**查询参数：**
| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 选填，按分类筛选 |

---

### 2.5 学习记录管理

#### POST `/api/study-records` — 新增学习记录

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "userId": 1,
  "skillId": 1,
  "duration": 60,
  "content": "学习了Java基础语法"
}
```

---

#### PUT `/api/study-records/{id}` — 更新学习记录

#### DELETE `/api/study-records/{id}` — 删除学习记录

#### GET `/api/study-records/{id}` — 获取学习记录详情

#### GET `/api/study-records/list` — 分页查询学习记录

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| userId  | Long | - | 选填，按用户筛选 |

---

### 2.6 简历评估管理

#### POST `/api/resumes` — 创建简历评估记录

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "userId": 1,
  "content": "简历文本内容或Markdown格式"
}
```

---

#### PUT `/api/resumes/{id}` — 更新简历评估记录

#### DELETE `/api/resumes/{id}` — 删除简历评估记录

#### GET `/api/resumes/{id}` — 获取简历评估详情

#### GET `/api/resumes/user/{userId}` — 获取用户的所有简历评估

#### GET `/api/resumes/list` — 分页查询简历评估

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| userId  | Long | - | 选填，按用户筛选 |

---

### 2.7 订单管理

#### POST `/api/orders` — 新增订单

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "userId": 1,
  "product": "灵思·AI学伴季卡",
  "amount": 299,
  "status": "pending"
}
```

---

#### PUT `/api/orders/{id}` — 更新订单

#### DELETE `/api/orders/{id}` — 删除订单

#### GET `/api/orders/{id}` — 获取订单详情

#### GET `/api/orders` — 分页查询订单列表

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| keyword | string | - | 搜索关键词 |
| status  | string | - | 筛选状态：pending/paid/completed/cancelled |

---

### 2.8 AI配置管理

#### POST `/api/ai/configs` — 新增AI配置

**请求头：** 需要 Bearer Token

**请求体（JSON）：**
```json
{
  "name": "Dify配置",
  "apiKey": "app-xxx",
  "endpoint": "http://localhost/v1",
  "model": "gpt-4",
  "config": {}
}
```

---

#### PUT `/api/ai/configs/{id}` — 更新AI配置

#### DELETE `/api/ai/configs/{id}` — 删除AI配置

#### GET `/api/ai/configs/{id}` — 获取AI配置详情

#### GET `/api/ai/configs` — 分页查询AI配置列表

**查询参数：**
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| current | int | 1 | 当前页码 |
| size    | int | 10 | 每页条数 |
| keyword | string | - | 搜索关键词 |

#### GET `/api/ai/configs/stats` — 获取AI统计信息

---

### 2.9 仪表盘

#### GET `/api/dashboard/stats` — 获取仪表盘统计数据

**请求头：** 需要 Bearer Token

**成功响应（200）：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "totalUsers": 128,
    "totalLearningHours": 4560,
    "aiInteractions": 8920,
    "activeUsers": 45
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| totalUsers | Long | 总用户数 |
| totalLearningHours | Long | 总学习时长（分钟） |
| aiInteractions | Long | AI交互次数 |
| activeUsers | Long | 活跃用户数 |

---

## 四、测试流程建议

### 4.1 冒烟测试流程

```
1. 用户注册      POST /api/auth/register
2. 用户登录      POST /api/auth/login        → 获取 Token
3. 获取用户信息   GET  /api/users/me          (带 Token)
4. 获取仪表盘统计 GET  /api/dashboard/stats    (带 Token)
5. 技能分页查询   GET  /api/skills             (带 Token)
6. 用户登出      POST /api/auth/logout        (带 Token)
```

### 4.2 功能测试流程

**用户模块：** 注册 → 登录 → 获取信息 → 修改密码 → 更新资料 → 查询列表 → 删除（管理员）

**技能模块：** 新增 → 查询详情 → 更新 → 分页查询 → 获取技能树 → 删除

**学习记录模块：** 新增 → 查询详情 → 更新 → 分页查询 → 删除

**简历评估模块：** 创建 → 查询详情 → 更新 → 按用户查询 → 分页查询 → 删除

**订单模块：** 新增 → 查询详情 → 更新 → 分页查询（含状态筛选） → 删除

**AI配置模块：** 新增 → 查询详情 → 更新 → 分页查询 → 获取统计 → 删除

---

## 五、测试数据建议

### 5.1 用户测试数据
| 场景 | 用户名 | 密码 | 预期结果 |
|------|--------|------|---------|
| 正常注册 | test_001 | 123456 | 注册成功，返回用户信息 |
| 重复用户名 | test_001 | 123456 | 注册失败，提示用户名已存在 |
| 空用户名 | "" | 123456 | 参数校验失败，400错误 |
| 密码过短 | test_002 | 123 | 参数校验失败，400错误 |
| 正常登录 | test_001 | 123456 | 登录成功，返回Token |
| 错误密码 | test_001 | wrong | 登录失败，401错误 |
| 不存在的用户 | no_exist | 123456 | 登录失败，401错误 |

### 5.2 技能测试数据
| 场景 | 测试内容 | 预期结果 |
|------|---------|---------|
| 新增技能 | name="Java基础", category="后端开发" | 创建成功 |
| 技能树查询 | 无过滤条件 | 返回所有技能树结构 |
| 按分类查询 | category="后端开发" | 返回对应分类的技能列表 |

### 5.3 订单状态说明
| 状态值 | 含义 |
|--------|------|
| pending | 待支付 |
| paid    | 已支付 |
| completed | 已完成 |
| cancelled | 已取消 |

---

## 六、常见错误排查

| 问题现象 | 可能原因 | 解决方法 |
|---------|---------|---------|
| 401 Unauthorized | Token 缺失或已过期 | 重新登录获取新 Token |
| 403 Forbidden | 用户权限不足 | 使用管理员账号操作 |
| 400 Bad Request | 请求参数格式错误 | 对照接口文档检查参数 |
| 500 Internal Server Error | 服务端异常 | 查看后端日志排查 |
| 接口返回 404 | 请求路径错误 | 检查 URL 路径是否匹配 |
| 数据库连接失败 | MySQL 未启动或配置错误 | 检查 application.yml 配置 |

---

## 七、Swagger 在线文档

启动后端服务后，可通过以下地址访问 Swagger 在线 API 文档：

- **Swagger UI：** http://localhost:8080/swagger-ui.html
- **OpenAPI JSON：** http://localhost:8080/v3/api-docs

在 Swagger 页面中可以：
- 查看所有接口的详细说明
- 在线调试接口（需要先获取 Token）
- 查看数据模型定义

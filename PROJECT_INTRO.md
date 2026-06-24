# 灵思·AI学伴 — 项目完整介绍

> 版本：v2.0 | 适用对象：测试人员 | 最后更新：2026-06-24

---

## 一、项目概述

**灵思·AI学伴** 是一款面向大学生的智能学习辅助系统，以 AI 大语言模型技术为核心，提供智能问答、技能评估、简历分析、模拟面试、学习追踪等全方位学习辅助服务。

### 1.1 项目定位

- **目标用户：** 在校大学生、自学编程学习者
- **核心价值：** AI 驱动个性化学习，提升学习效率
- **使用场景：** 课后辅导、技能练习、求职准备、学习管理

### 1.2 项目构成

| 子项目 | 路径 | 技术栈 | 用途 |
|--------|------|--------|------|
| **后端服务** | `backend/` | Java 17 + Spring Boot 3.2 + MyBatis-Plus + MySQL | API 服务与业务逻辑 |
| **管理后台** | `admin/` | Vue 3 + Element Plus + ECharts + Pinia | 管理员数据管理与运营 |
| **移动端** | `app/` | HarmonyOS NEXT + ArkTS + ArkUI | 学生端 App |

---

## 二、功能模块详解

### 2.1 AI 智能对话

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 多轮对话 | 支持上下文连续对话，通过 `conversation_id` 维持会话 | Chat.ets |
| 深度思考展示 | AI 推理过程可折叠展示（`reasoningContent` 字段） | Chat.ets |
| Markdown 渲染 | 支持加粗、行内代码、换行等 Markdown 语法 | MarkdownRenderer.ets |
| Dify API 接入 | 通过 Dify 平台调用大模型，支持阻塞模式 | DifyApi.ets |
| 消息清空 | 一键清空对话历史，重置会话 ID | Chat.ets |

**测试要点：** 多轮对话上下文连续性、Markdown 渲染正确性、深度思考折叠/展开、空消息/超长消息处理

### 2.2 技能评估与技能树

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 技能树管理（管理端） | 按分类管理技能体系，支持树形展示 | Skill 管理页 |
| 技能 CRUD | 新增/编辑/删除技能，含5个难度等级 | Skill 管理页 |
| 技能浏览（移动端） | 按分类折叠展示，难度等级可视化（圆点指示） | SkillTree.ets |
| 分类筛选 | 按 `前端开发`/`后端开发`/`数据库`/`运维部署`/`架构设计`/`工具` 分类筛选 | 两端支持 |

**技能等级体系：**
| 等级 | 1 | 2 | 3 | 4 | 5 |
|------|---|---|---|---|---|
| 标签 | 入门 | 基础 | 进阶 | 高级 | 专家 |

**Mock 数据：** 12 条技能记录，覆盖 6 个分类

### 2.3 学习记录管理

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 学习记录列表 | 分页展示，支持加载更多 | StudyRecords.ets |
| 新增学习记录 | 选择类型 + 填写内容 + 设置时长 | StudyRecords.ets |
| 学习类型 | 阅读/练习/视频/测验/编程/讨论 | StudyRecords.ets |
| 状态管理 | 未开始/进行中/已完成/已取消 | StudyRecords.ets |
| 管理端查看 | 管理后台汇总查看所有用户记录 | Record 管理页 |

### 2.4 简历评估

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 简历输入 | 填写标题 + 粘贴/输入简历内容 | ResumeEditor.ets |
| AI 智能评估 | 调用 Dify 进行自动评分与分析 | ResumeEditor.ets |
| 评分展示 | 总分 + 专业知识/项目经验/综合表现 分项评分 | ResumeResult.ets |
| 优势分析 | AI 提取简历亮点 | ResumeResult.ets |
| 优化建议 | AI 给出具体改进方向 | ResumeResult.ets |
| 评估历史 | 查看历次评估记录 | ResumeList.ets |

**评分等级：** >=90 优秀 / >=80 良好 / >=70 中等 / >=60 一般 / <60 待优化

### 2.5 用户认证与管理

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 注册 | 两步注册（基础信息→详细信息） | Register.ets |
| 登录 | 支持记住密码功能 | Login.ets |
| 个人中心 | 头像、昵称、邮箱、手机、角色展示 | Profile.ets |
| 编辑资料 | 修改昵称/邮箱/手机号 | EditProfile.ets |
| 修改密码 | 原密码验证 + 新密码设置 | ChangePassword.ets |
| 退出登录 | 确认弹窗后清除 Token | Profile.ets |
| 管理端用户管理 | 用户列表、创建、编辑、删除 | User 管理页 |

### 2.6 仪表盘与数据统计

| 子功能 | 说明 | 对应页面 |
|--------|------|---------|
| 统计卡片 | 总用户数 / 学习时长 / AI交互次数 / 活跃用户 | Dashboard 页 / Home.ets |
| 用户增长趋势图 | ECharts 折线图（月度数据） | Dashboard 页 |
| 学习时长分布图 | ECharts 饼图（编程/数学/英语/物理/其他） | Dashboard 页 |
| AI 调用趋势图 | ECharts 柱状图（近7天） | Dashboard 页 |
| 近30天增长图 | ECharts 折线图（每日新增用户） | Dashboard 页 |

### 2.7 订单管理（管理端）

| 子功能 | 说明 |
|--------|------|
| 订单列表 | 分页展示所有订单 |
| 状态筛选 | 全部/待支付/已支付/已完成/已取消 |
| 关键词搜索 | 按订单号或用户昵称搜索 |
| 删除订单 | 确认弹窗后删除 |
| Mock 数据 | 5 条预设订单数据兜底 |

### 2.8 AI 配置管理（管理端）

| 子功能 | 说明 |
|--------|------|
| 配置列表 | 展示 AI 模型配置（名称、模型、状态）|
| 配置 CRUD | 新增/编辑/删除配置 |
| 统计展示 | 总请求数 / 成功率 / 平均响应时间 / 今日请求 |
| Mock 数据 | 3 条预设配置 + 统计 Mock 数据兜底 |

---

## 三、系统架构

### 3.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                   移动端（HarmonyOS NEXT）                       │
│   ArkTS + ArkUI + HttpClient                                    │
│   [登录] [首页] [聊天] [技能树] [学习记录] [简历评估] [个人中心] │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTP/JSON + JWT Bearer Token
┌──────────────────────────┴──────────────────────────────────────┐
│                    后端服务（Spring Boot 3.2）                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Controller 层：9 个控制器，40+ 个 REST 接口               │   │
│  │ Service 层：业务逻辑                                    │   │
│  │ Mapper 层：MyBatis-Plus 数据访问                        │   │
│  │ Model 层：Entity / DTO / VO                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Spring Security + JWT 鉴权  |  Swagger API 文档          │   │
│  │ MyBatis-Plus ORM  |  Global Exception 处理               │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────┬──────────────────────────────────────────────────────┘
           │                           │
           ▼                           ▼
┌──────────────────────┐    ┌──────────────────────┐
│   MySQL 8.0          │    │   Dify AI 平台        │
│   数据库：ai_companion│    │   AI 对话 / 简历评估   │
└──────────────────────┘    └──────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   管理后台（Vue 3 + Element Plus）                │
│   Element UI · ECharts · Axios · Pinia · Vue Router             │
│   [登录] [仪表盘] [用户] [技能树] [记录] [AI配置] [订单]       │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 后端分层

```
backend/src/main/java/com/aicompanion/
├── controller/          # 控制器层（9个控制器）
│   ├── AuthController.java      # 认证接口
│   ├── AdminController.java     # 管理员接口
│   ├── UserController.java      # 用户接口
│   ├── SkillController.java     # 技能接口
│   ├── StudyRecordController.java # 学习记录接口
│   ├── ResumeController.java    # 简历评估接口
│   ├── OrderController.java     # 订单接口
│   ├── AIConfigController.java  # AI配置接口
│   └── DashboardController.java # 仪表盘接口
├── service/             # 业务逻辑层
│   ├── impl/            # 业务实现类
├── mapper/              # MyBatis-Plus Mapper
├── model/
│   ├── entity/          # 实体类（对应数据库表）
│   ├── dto/             # 请求参数对象
│   └── vo/              # 响应视图对象
├── common/
│   ├── response/        # 统一响应 Result / PageResult
│   ├── exception/       # 全局异常处理
│   └── util/            # JWT工具类等
└── config/              # Spring配置 / Security / Swagger
```

### 3.3 移动端架构（MVVM）

```
entry/src/main/ets/
├── pages/               # 13个页面
│   ├── Login.ets → Register.ets → Home.ets
│   ├── Chat.ets         # AI对话
│   ├── Card.ets         # 名片
│   ├── Profile.ets → EditProfile.ets / ChangePassword.ets
│   ├── SkillTree.ets    # 技能树
│   ├── StudyRecords.ets # 学习记录
│   ├── ResumeList.ets → ResumeEditor.ets → ResumeResult.ets
│   └── Index.ets        # 初始页
├── http/                # API 接口封装
│   ├── AuthApi.ets / UserApi.ets / SkillApi.ets
│   ├── StudyRecordApi.ets / ResumeApi.ets / DashboardApi.ets
│   ├── DifyApi.ets / ResumeDifyApi.ets
├── model/               # 数据模型
│   ├── User.ets / Skill.ets / Resume.ets
│   ├── ChatMessage.ets / ChatViewModel.ets / PageResult.ets
├── components/          # 组件
│   └── MarkdownRenderer.ets
├── common/              # 工具类
│   ├── Constants.ets / HttpClient.ets / TokenUtil.ets / DateUtil.ets
```

### 3.4 管理后台结构

```
admin/src/
├── views/               # 8个页面
│   ├── login/           # 登录 / 注册
│   ├── dashboard/       # 仪表盘（4个图表）
│   ├── user/            # 用户管理
│   ├── skill/           # 技能树管理
│   ├── record/          # 学习记录
│   ├── ai/              # AI功能管理
│   ├── order/           # 订单管理
│   ├── counter/         # 计数器（示例）
│   └── user-form/       # 用户表单（示例）
├── api/                 # 7个 API 模块
├── components/layout/   # 布局组件
├── router/              # 路由配置
├── stores/              # Pinia 状态管理
├── mock/                # Mock 数据
└── utils/               # Axios封装 / Token管理
```

---

## 四、技术要点

### 4.1 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 17 | 开发语言 |
| Spring Boot | 3.2.x | 框架 |
| MyBatis-Plus | 3.5.5 | ORM |
| MySQL | 8.0 | 数据库 |
| Spring Security | - | 认证授权 |
| JWT | - | Token 鉴权 |
| Swagger / OpenAPI | 3.0 | API 文档 |
| Lombok | - | 代码简化 |
| Maven | 3.6+ | 构建工具 |

### 4.2 前端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Vue | 3.4 | 框架 |
| Element Plus | 2.6 | UI 组件库 |
| ECharts | 5.5 | 图表 |
| Pinia | 2.1 | 状态管理 |
| Vue Router | 4.3 | 路由 |
| Axios | 1.6 | HTTP 客户端 |
| Vite | 5.4 | 构建工具 |

### 4.3 移动端技术栈

| 技术 | 用途 |
|------|------|
| ArkTS | 开发语言（TypeScript 超集）|
| ArkUI | 声明式 UI 框架 |
| Stage 模型 | 应用模型 |
| @ohos.net.http | 网络请求 |
| @ohos.router | 路由跳转 |
| @ohos.data.preferences | 本地存储 |

### 4.4 数据库设计

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `user` | 用户表 | id, username, password, nickname, email, phone, avatar, role, status |
| `skill` | 技能表 | id, name, category, level, description, parent_id |
| `study_record` | 学习记录表 | id, user_id, content, duration, type, status, score |
| `resume` | 简历评估表 | id, user_id, title, content, evaluation, score, strengths, suggestions, status |
| `order` | 订单表 | id, user_id, product, amount, status, order_no |
| `ai_config` | AI 配置表 | id, name, api_key, endpoint, model, enabled, config |
| `base_entity` | 公共字段 | id, create_time, update_time, deleted（逻辑删除）|

---

## 五、环境搭建

### 5.1 环境要求

| 组件 | 版本要求 | 用途 |
|------|---------|------|
| JDK | 17+ | 运行后端 |
| MySQL | 8.0+ | 数据库 |
| Maven | 3.6+ | 构建后端 |
| Node.js | 18+ | 运行管理后台 |
| DevEco Studio | 最新版 | 运行移动端 |
| Dify 平台 | 最新版 | AI 能力提供 |

### 5.2 后端启动

```bash
# 1. 初始化数据库
# 执行 backend/src/main/resources/sql/init.sql

# 2. 修改数据库配置
# 编辑 backend/src/main/resources/application.yml
# 修改 spring.datasource 下的 url/username/password

# 3. 启动服务
cd backend
mvn clean package -DskipTests
mvn spring-boot:run

# 4. 验证
# 访问 http://localhost:8080/swagger-ui.html
```

### 5.3 管理后台启动

```bash
cd admin
npm install
npm run dev

# 访问 http://localhost:5173
# 后端未启动时支持 Mock 模式登录
```

### 5.4 移动端启动

1. 使用 DevEco Studio 打开 `app/` 目录
2. 等待依赖下载完成
3. 连接模拟器或真机
4. 点击 Run 按钮

### 5.5 Dify AI 平台配置

1. 部署 Dify 平台（Docker 或本地）
2. 创建两个应用：智能聊天 App + 简历评估 App
3. 获取各自 API Key
4. 配置以下文件：
   - `entry/src/main/ets/http/DifyApi.ets` — API Key + 地址
   - `entry/src/main/ets/http/ResumeDifyApi.ets` — API Key + 地址

---

## 六、完整页面清单

### 6.1 管理后台页面（8个路由）

| 路由 | 页面 | 功能 |
|------|------|------|
| `/login` | 登录页 | 管理员登录 |
| `/register` | 注册页 | 管理员注册 |
| `/dashboard` | 仪表盘 | 4个统计卡片 + 4个ECharts图表 |
| `/user` | 用户管理 | 用户CRUD + 分页搜索 |
| `/skill` | 技能树管理 | 树形展示 + CRUD + 分类筛选 |
| `/record` | 学习记录 | 分页查看 + 搜索 + Mock兜底 |
| `/ai` | AI功能管理 | 配置CRUD + 统计信息 |
| `/order` | 订单管理 | 列表 + 状态筛选 + 搜索 |

### 6.2 移动端页面（13个页面）

| 页面 | 文件 | 功能 |
|------|------|------|
| 首页 | Index.ets | 初始引导页 |
| 登录 | Login.ets | 用户登录 + 记住密码 |
| 注册 | Register.ets | 两步注册流程 |
| 首页 | Home.ets | 欢迎语 + 统计卡片 + 6个功能入口 |
| AI对话 | Chat.ets | 多轮对话 + Markdown + 深度思考 |
| 名片 | Card.ets | 名片展示 + 编辑模式 |
| 个人中心 | Profile.ets | 个人信息 + 菜单入口 + 退出登录 |
| 编辑资料 | EditProfile.ets | 修改昵称/邮箱/手机 |
| 修改密码 | ChangePassword.ets | 修改密码 |
| 技能树 | SkillTree.ets | 按分类折叠 + 等级指示 |
| 学习记录 | StudyRecords.ets | 列表 + 新增 + 加载更多 |
| 简历列表 | ResumeList.ets | 评估记录列表 |
| 简历编辑 | ResumeEditor.ets | 输入 + AI评估 |
| 评估结果 | ResumeResult.ets | 评分卡 + 评估详情 |

---

## 七、测试要点

### 7.1 功能测试覆盖

| 模块 | 测试重点 | 涉及页面 |
|------|---------|---------|
| 用户注册 | 必填校验 / 重复检测 / 两步流程 | Register（两端）|
| 用户登录 | 成功/失败/记住密码/Token有效期 | Login（两端）|
| AI对话 | 消息收发 / 多轮连续 / Markdown / 深度思考 | Chat |
| 技能树 | 树形结构 / CRUD / 分类筛选 / 等级展示 | Skill管理 / SkillTree |
| 学习记录 | 新增/列表/类型选择/加载更多 | StudyRecords |
| 简历评估 | AI评估流程 / 评分展示 / 建议 | ResumeEditor → ResumeResult |
| 仪表盘 | 统计数据 / 图表渲染 | Dashboard |
| 订单管理 | 状态筛选 / 搜索 / 删除 | Order管理 |
| AI配置 | CRUD / 统计展示 | AI管理 |

### 7.2 异常场景测试

- 无 Token 访问需鉴权接口 → 401
- Token 过期 → 刷新/重新登录
- 参数缺失/格式错误 → 400
- 重复注册 → 错误提示
- 操作不存在资源 → 404
- 并发请求 → 按钮禁用/幂等
- 网络异常 → 前端 Mock 数据兜底
- Dify 服务不可用 → 友好处错提示

### 7.3 兼容性测试

| 端 | 环境 | 版本 |
|----|------|------|
| 管理后台 | Chrome / Edge / Firefox | 最新稳定版 |
| 移动端 | HarmonyOS 模拟器 / 真机 | API 9+ |
| 移动端 | 屏幕适配 | 手机 / 折叠屏 |

### 7.4 数据流向验证

| 验证项 | 说明 |
|--------|------|
| 登录 → Token → 后续请求携带 | 验证 Authorization 请求头 |
| 注册 → 登录 → 获取信息 | 验证数据一致性 |
| 新增数据 → 列表查询 | 验证 CRUD 完整链路 |
| 移动端 → 后端 → 数据库 | 验证端到端数据流 |
| 管理后台 Mock → 真实 API | 验证 Mock 兜底机制 |

---

## 八、相关文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| **接口测试指南** | [API_TEST_GUIDE.md](API_TEST_GUIDE.md) | 所有 API 接口完整说明 |
| 项目根指南 | [AGENTS.md](AGENTS.md) | 项目总览与联调约定 |
| 后端开发指南 | [backend/AGENTS.md](backend/AGENTS.md) | 后端编码规范 |
| 管理后台指南 | [admin/AGENTS.md](admin/AGENTS.md) | 前端编码规范 |
| 移动端指南 | [app/AGENTS.md](app/AGENTS.md) | HarmonyOS 开发规范 |
| 聊天使用指南 | [app/CHAT_USAGE.md](app/CHAT_USAGE.md) | AI对话功能说明 |
| 聊天测试指南 | [app/CHAT_TEST.md](app/CHAT_TEST.md) | 聊天功能测试步骤 |
| Dify配置指南 | [app/DIFY_CONFIG.md](app/DIFY_CONFIG.md) | Dify API配置 |
| Swagger在线文档 | http://localhost:8080/swagger-ui.html | 在线API调试 |

---

## 九、常见问题

### Q1: 后端启动报数据库连接失败？
检查 MySQL 服务是否启动，确认 `application.yml` 中的连接参数（地址、端口、用户名、密码）是否正确。

### Q2: 登录后接口返回 401？
Token 已过期或无效，调用登录接口重新获取 Token。

### Q3: 管理后台页面显示空白？
确认后端服务已启动，或检查是否开启了 Mock 模式。

### Q4: 移动端连不上后端？
- 模拟器使用 `http://10.0.2.2:8080`
- 真机使用电脑的局域网 IP 替换 `10.0.2.2`

### Q5: AI 聊天没有回复？
- 检查 Dify 服务是否运行
- 检查 `DifyApi.ets` 中的 API Key 配置
- 检查 BASE_URL 的端口号是否正确

### Q6: 简历评估失败？
- 检查 `ResumeDifyApi.ets` 中的 API Key
- 确认简历内容不少于 20 个字符
- 查看控制台日志中的错误信息

---

> 文档版本：v2.0 | 最后更新：2026-06-24

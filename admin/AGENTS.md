# AI 伴学平台 - 前端管理后台

## 一、技术栈
- 核心框架：Vue 3 + JavaScript（**禁止使用TypeScript**）
- 构建工具：Vite
- UI组件库：Element Plus
- 路由：Vue Router 4（history模式）
- 状态管理：Pinia
- HTTP客户端：Axios（已封装在utils/request.js）
- 图表：ECharts

## 二、目录结构
admin/src/├── views/ # 页面组件，按模块分子目录
│ ├── login/ # 登录页
│ ├── dashboard/ # 首页仪表盘
│ ├── user/ # 用户管理
│ ├── skill/ # 技能树管理
│ ├── record/ # 学习记录
│ └── ai/ # AI 功能管理
├── components/ # 公共复用组件
│ └── layout/ # 全局布局组件
├── api/ # API 请求封装，按模块分文件
├── router/ # 路由配置
├── stores/ # Pinia 状态管理
├── utils/ # 工具函数（含 Axios 封装）
└── assets/ # 静态资源

## 三、编码规范
1. 统一使用 `<script setup>` Composition API，不使用Options API
2. 全程使用JavaScript，禁止引入TypeScript
3. 所有API请求统一封装在 `api/` 目录，组件中禁止直接写axios请求
4. UI优先使用Element Plus组件，不自定义原生样式
5. 组件样式必须加 `scoped`，避免全局样式污染
6. 路由使用history模式，新增页面同步更新路由配置
7. 变量与文件命名使用小驼峰，组件名使用大驼峰

## 四、约束条件
- ❌ 禁止使用TypeScript
- ❌ 禁止在组件中硬编码API地址
- ❌ 禁止修改 `utils/request.js` 的拦截器核心逻辑
- ❌ 禁止随意调整目录结构，新增文件必须放入对应目录
- ❌ 禁止使用全局样式覆盖Element Plus默认样式（特殊情况需注释说明）

## 五、参考文件
- 登录页参考：`views/login/index.vue`
- 布局组件参考：`components/layout/MainLayout.vue`
- Axios封装参考：`utils/request.js`
- 路由配置参考：`router/index.js`
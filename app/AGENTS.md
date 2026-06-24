# AGENTS.md – 灵思·AI学伴 HarmonyOS 开发指南

> 本文档用于指导 AI 助手（如 Trae）为本项目生成符合规范的 ArkTS 代码。

## 项目概述
- **项目名称**：灵思·AI学伴（HarmonyOS NEXT 版）
- **开发语言**：ArkTS（TypeScript 超集）
- **UI 框架**：ArkUI（声明式）
- **应用模型**：Stage 模型
- **包名**：`com.example.aicompanion`
- **后端 API 基地址**：`http://10.0.2.2:8080`（模拟器），真机请用电脑实际 IP

## 目录结构（关键部分）
entry/src/main/ets/
├── pages/ # 页面
│ ├── Login.ets
│ ├── Register.ets
│ ├── Home.ets
│ ├── Card.ets # 名片练习页
│ └── Profile.ets # 个人中心
├── common/ # 工具类
│ ├── Constants.ets # 常量（BASE_URL, 存储键）
│ ├── TokenUtil.ets # Token/用户信息读写
│ └── HttpClient.ets # 封装网络请求
├── http/ # API 接口
│ └── AuthApi.ets # 认证相关接口
└── model/ # 数据模型
└── User.ets # LoginRequest, LoginResponse 等

## 技术规范
### 1. 组件定义
- 页面组件使用 `@Entry` + `@Component` + `struct`。
- 可复用组件仅用 `@Component`。
- 所有 `build()` 方法内只能包含一个根容器（通常为 `Column` 或 `Row`）。

### 2. 状态管理
- 组件内部状态用 `@State`。
- 父传子只读用 `@Prop`。
- 子改父用 `@Link`（双向绑定）。
- 嵌套对象（如数组内的对象）用 `@Observed` + `@ObjectLink`。

### 3. 网络请求
- 使用 `@kit.NetworkKit` 的 `http` 模块。
- 统一通过 `HttpClient.request<T>()` 发送请求，自动注入 Token、处理 401/500。
- API 接口统一写在 `http/` 目录下，继承 `HttpClient` 的快捷方法（`get`/`post`/`put`/`del`）。

### 4. 数据持久化
- 使用 `@kit.ArkData` 的 `preferences`，所有操作异步（`await`）。
- 存储键定义在 `Constants.ets` 中，避免硬编码。

### 5. 路由跳转
- 使用 `router.pushUrl`（可返回）或 `router.replaceUrl`（不可返回）。
- 跳转前确保目标页面已在 `main_pages.json` 中注册。
- 携带参数通过 `params` 字段。

### 6. 生命周期
- `aboutToAppear()`：页面显示前调用（类似 `onMounted`）。
- `aboutToDisappear()`：页面销毁前调用。

## 需要完成的功能清单（按优先级）
### 基础练习（已完成）
- [x] 项目创建与目录结构
- [ ] 名片页面（Card.ets）+ 编辑模式
- [ ] 登录页面（Login.ets）完整逻辑（调用 API、存 Token、跳转）
- [ ] TokenUtil 补充（saveUserInfo / getUsername）
- [ ] 记住密码功能
- [ ] 注册页面（Register.ets）与联调
- [ ] 个人中心（Profile.ets）与退出登录

### 编码约定
- 所有 `TextInput` 绑定 `onChange` 更新 `@State`。
- 所有按钮点击事件用 `onClick(() => { ... })`。
- 异步操作必须 `try/catch` 并更新 `loading` 状态。
- 样式通过链式调用设置（如 `.width('100%')`），单位默认 vp。
- 组件命名采用大驼峰（如 `SkillTag`），文件命名与组件一致。

## 常用代码片段（供 AI 生成参考）
### 页面模板
```ts
@Entry
@Component
struct MyPage {
  @State loading: boolean = false
  @State errorMsg: string = ''

  aboutToAppear() {
    // 初始化逻辑
  }

  build() {
    Column() {
      // UI 内容
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

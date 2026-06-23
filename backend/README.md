# AI 伴学平台 - 后端服务

## 项目简介
AI 伴学平台后端服务，基于 Spring Boot 3.2 + MyBatis-Plus 构建的单体应用。

## 技术栈
- Java 17
- Spring Boot 3.2.x
- MyBatis-Plus 3.5.5
- MySQL 8.0
- Spring Security + JWT
- Swagger / OpenAPI 3.0
- Lombok

## 快速开始

### 1. 环境要求
- JDK 17+
- Maven 3.6+
- MySQL 8.0+

### 2. 数据库初始化
执行 `src/main/resources/sql/init.sql` 文件创建数据库和表结构。

### 3. 修改配置
修改 `src/main/resources/application.yml` 中的数据库连接信息：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ai_companion
    username: your_username
    password: your_password
```

### 4. 编译运行
```bash
# 编译
mvn clean package

# 运行
mvn spring-boot:run
```

### 5. 访问 API 文档
启动后访问：http://localhost:8080/swagger-ui.html

## 项目结构
```
backend/src/main/java/com/aicompanion/
├── model/              # 数据模型层
│   ├── entity/        # 实体类
│   ├── dto/           # 数据传输对象
│   └── vo/            # 视图对象
├── mapper/            # 数据访问层
├── service/           # 业务逻辑层
│   └── impl/         # 业务实现类
├── controller/        # 控制器层
├── common/            # 公共模块
│   ├── response/     # 统一响应
│   ├── exception/    # 异常处理
│   └── util/         # 工具类
└── config/            # 配置类
```

## API 接口

### 认证接口
- POST `/api/auth/login` - 用户登录
- POST `/api/auth/logout` - 用户登出

### 用户接口
- POST `/api/users/register` - 注册用户
- GET `/api/users/{id}` - 获取用户信息
- PUT `/api/users/{id}` - 更新用户信息
- GET `/api/users/list` - 获取用户列表
- DELETE `/api/users/{id}` - 删除用户

## 开发规范
详见 [AGENTS.md](AGENTS.md)

## License
MIT

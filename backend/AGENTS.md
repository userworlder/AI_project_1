# AI 伴学平台 - 后端服务

## 一、技术栈
- 语言：Java 17
- 框架：Spring Boot 3.2.x（单体架构）
- ORM：MyBatis-Plus 3.5.5
- 数据库：MySQL 8.0
- 安全框架：Spring Security + JWT
- API文档：Swagger / OpenAPI 3.0
- 工具：Lombok

## 二、分层架构
backend/src/main/java/com/aicompanion/├── model/ # 数据模型层│ ├── entity/ # 实体类，对应数据库表，必须继承 BaseEntity│ ├── dto/ # 数据传输对象，接收前端参数，带 @Valid 校验│ ├── vo/ # 视图对象，返回前端数据，不含敏感字段│ └── query/ # 分页查询参数对象├── mapper/ # 数据访问层，继承 BaseMapper<T>├── service/ # 业务逻辑层│ ├── XxxService.java # 业务接口│ └── impl/ # 业务实现类├── controller/ # 控制器层，接收 HTTP 请求├── common/ # 公共模块│ ├── response/ # 统一响应 Result<T>、PageResult<T>│ ├── exception/ # 业务异常、全局异常处理器│ └── util/ # 工具类（JwtUtil、SecurityUtil 等）└── config/ # 配置类


## 三、编码规范
1. Controller只做请求接收、参数校验、响应返回，不编写业务逻辑
2. 业务逻辑全部写在Service层，接口在service/，实现在impl/
3. 所有接口统一返回 `Result<T>`，禁止直接返回Entity对象
4. 接收前端参数用DTO，返回前端数据用VO，禁止Entity跨层传递
5. 依赖注入使用 `@RequiredArgsConstructor` 构造器注入，禁止使用 `@Autowired`
6. 使用Lombok的 `@Data` 简化实体类代码
7. 所有Controller与接口必须添加Swagger注解：类加`@Tag`、方法加`@Operation`
8. 所有入参必须添加 `@Valid` 校验注解

## 四、约束条件
- ❌ 禁止在Controller中直接调用Mapper操作数据库
- ❌ 禁止使用`@Autowired`进行依赖注入
- ❌ 禁止将Entity对象直接返回给前端
- ❌ 禁止使用`System.out.println`打印日志，必须使用`@Slf4j`
- ❌ 禁止手写SQL，简单CRUD必须通过MyBatis-Plus实现
- ❌ 禁止修改BaseEntity的字段与结构
- ❌ 所有新增接口必须添加完整的Swagger注解，确保接口能在Swagger文档页面正常显示、可调试

## 五、新增模块标准步骤
1. 在 `model/entity/` 创建实体类，继承BaseEntity
2. 在 `model/dto/` 创建入参DTO，添加校验注解
3. 在 `model/vo/` 创建返回VO
4. 在 `mapper/` 创建Mapper接口，继承BaseMapper
5. 在 `service/` 创建Service接口
6. 在 `service/impl/` 创建Service实现类
7. 在 `controller/` 创建Controller，添加Swagger注解

## 六、参考文件
- Controller参考：`controller/AuthController.java`、`controller/UserController.java`
- Service实现参考：`service/impl/UserServiceImpl.java`
- 实体类参考：`entity/User.java`
- DTO参考：`dto/LoginDTO.java`、`dto/RegisterDTO.java`
- VO参考：`vo/UserVO.java`
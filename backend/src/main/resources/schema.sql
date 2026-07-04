-- AI伴学平台 数据库建表脚本
-- 数据库: ai_companion

-- ========== 用户表 ==========
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    `role` VARCHAR(20) DEFAULT 'student' COMMENT '角色：admin管理员 teacher教师 student学生',
    `status` INT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除：0未删 1已删',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ========== 学习记录表 ==========
CREATE TABLE IF NOT EXISTS `study_record` (
    `id` BIGINT AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `content` VARCHAR(500) NOT NULL COMMENT '学习内容',
    `duration` INT DEFAULT 0 COMMENT '学习时长(分钟)',
    `type` VARCHAR(50) DEFAULT NULL COMMENT '学习类型',
    `status` INT DEFAULT 1 COMMENT '状态',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习记录表';

-- ========== 技能表 ==========
CREATE TABLE IF NOT EXISTS `skill` (
    `id` BIGINT AUTO_INCREMENT COMMENT '技能ID',
    `name` VARCHAR(100) NOT NULL COMMENT '技能名称',
    `category` VARCHAR(50) NOT NULL COMMENT '分类',
    `level` INT DEFAULT 1 COMMENT '难度等级：1入门 2基础 3进阶 4高级 5专家',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '技能描述',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能表';

-- ========== 订单表 ==========
CREATE TABLE IF NOT EXISTS `orders` (
    `id` BIGINT AUTO_INCREMENT COMMENT '订单ID',
    `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `user_nickname` VARCHAR(50) DEFAULT NULL COMMENT '用户昵称',
    `amount` DECIMAL(10,2) NOT NULL COMMENT '订单金额',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '状态：pending待支付 paid已支付 completed已完成 cancelled已取消',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '订单描述',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ========== AI配置表 ==========
CREATE TABLE IF NOT EXISTS `ai_config` (
    `id` BIGINT AUTO_INCREMENT COMMENT '配置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '配置名称',
    `model` VARCHAR(100) DEFAULT NULL COMMENT '模型名称',
    `api_key` VARCHAR(500) DEFAULT NULL COMMENT 'API Key',
    `enabled` TINYINT DEFAULT 1 COMMENT '是否启用：0禁用 1启用',
    `params` TEXT DEFAULT NULL COMMENT '其他参数(JSON)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_name` (`name`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI配置表';

-- ========== 简历评估表 ==========
CREATE TABLE IF NOT EXISTS `resume` (
    `id` BIGINT AUTO_INCREMENT COMMENT '简历ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `title` VARCHAR(200) DEFAULT '未命名简历' COMMENT '简历标题',
    `content` TEXT COMMENT '简历文本内容',
    `evaluation` TEXT COMMENT 'AI评估结果(JSON)',
    `score` INT DEFAULT NULL COMMENT '总体评分',
    `strengths` TEXT COMMENT '优势总结',
    `suggestions` TEXT COMMENT '优化建议',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '状态：pending待评估 evaluating评估中 completed已完成 failed失败',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历评估表';

-- ========== AI 聊天历史表 ==========
CREATE TABLE IF NOT EXISTS `ai_chat_history` (
    `id` BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `session_id` VARCHAR(64) NOT NULL COMMENT '会话ID',
    `role` VARCHAR(20) NOT NULL COMMENT '消息角色：user用户 / assistantAI',
    `content` TEXT NOT NULL COMMENT '消息内容',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除：0未删 1已删',
    PRIMARY KEY (`id`),
    KEY `idx_session_id` (`session_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI聊天历史记录表';

-- ========== 技能树表 ==========
CREATE TABLE IF NOT EXISTS `skill_tree` (
    `id` BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(100) NOT NULL COMMENT '技能名称',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '技能描述',
    `category` VARCHAR(50) NOT NULL COMMENT '技能分类',
    `level` INT DEFAULT 1 COMMENT '难度等级(1-5)',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父节点ID，根节点为0',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能树表';

-- ========== 用户技能关联表 ==========
CREATE TABLE IF NOT EXISTS `user_skill` (
    `id` BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `skill_id` BIGINT NOT NULL COMMENT '技能ID',
    `score` INT DEFAULT 0 COMMENT '技能评分(0-100)',
    `proficiency` VARCHAR(20) DEFAULT 'beginner' COMMENT '熟练度：beginner入门 intermediate中等 advanced熟练 expert精通',
    `practice_count` INT DEFAULT 0 COMMENT '练习次数',
    `last_practiced` DATETIME DEFAULT NULL COMMENT '最后练习时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_skill_id` (`skill_id`),
    UNIQUE KEY `uk_user_skill` (`user_id`, `skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户技能关联表';

-- ========== 技能考核记录表 ==========
CREATE TABLE IF NOT EXISTS `skill_assessment` (
    `id` BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `session_id` VARCHAR(64) NOT NULL COMMENT '会话标识',
    `skill_name` VARCHAR(128) NOT NULL COMMENT '考核技能名称',
    `questions_json` TEXT COMMENT 'AI生成的题目JSON（含参考答案）',
    `answers_json` TEXT COMMENT '用户提交的答案JSON',
    `score` INT DEFAULT 0 COMMENT '总分(0-100)',
    `evaluation` TEXT COMMENT 'AI总体评价',
    `strengths` TEXT COMMENT 'AI识别的优点(JSON数组)',
    `improvements` TEXT COMMENT '改进建议(JSON数组)',
    `status` INT DEFAULT 0 COMMENT '状态：0-进行中 1-已完成',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能考核记录表';

-- ========== 课程表 ==========
CREATE TABLE IF NOT EXISTS `course` (
    `id` BIGINT AUTO_INCREMENT COMMENT '课程ID',
    `name` VARCHAR(100) NOT NULL COMMENT '课程名称',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '课程描述',
    `skill_id` BIGINT DEFAULT NULL COMMENT '关联技能ID',
    `teacher_id` BIGINT NOT NULL COMMENT '创建教师ID',
    `difficulty_level` INT DEFAULT 1 COMMENT '难度等级 1-5',
    `cover_image` VARCHAR(255) DEFAULT NULL COMMENT '封面图',
    `sort_order` INT DEFAULT 0 COMMENT '排序号',
    `status` INT DEFAULT 1 COMMENT '状态: 0草稿 1已发布',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`),
    KEY `idx_skill_id` (`skill_id`),
    KEY `idx_teacher_id` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- ========== 课程章节表 ==========
CREATE TABLE IF NOT EXISTS `course_section` (
    `id` BIGINT AUTO_INCREMENT COMMENT '章节ID',
    `course_id` BIGINT NOT NULL COMMENT '所属课程ID',
    `title` VARCHAR(200) NOT NULL COMMENT '章节标题',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '章节描述',
    `order_index` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_course_id` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程章节表';

-- ========== 题目表 ==========
CREATE TABLE IF NOT EXISTS `question` (
    `id` BIGINT AUTO_INCREMENT COMMENT '题目ID',
    `section_id` BIGINT NOT NULL COMMENT '所属章节ID',
    `content` TEXT NOT NULL COMMENT '题目内容',
    `type` VARCHAR(20) DEFAULT 'choice' COMMENT '题型: choice单选 true_false判断',
    `options` TEXT DEFAULT NULL COMMENT '选项(JSON数组)',
    `correct_answer` VARCHAR(500) NOT NULL COMMENT '正确答案',
    `analysis` TEXT DEFAULT NULL COMMENT '题目解析',
    `order_index` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_section_id` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

-- ========== 用户课程进度表 ==========
CREATE TABLE IF NOT EXISTS `user_course_progress` (
    `id` BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `course_id` BIGINT NOT NULL COMMENT '课程ID',
    `section_id` BIGINT NOT NULL COMMENT '章节ID',
    `score` INT DEFAULT 0 COMMENT '该章节得分',
    `total_questions` INT DEFAULT 0 COMMENT '总题数',
    `correct_count` INT DEFAULT 0 COMMENT '答对数',
    `answers_json` TEXT DEFAULT NULL COMMENT '用户答案(JSON)',
    `status` INT DEFAULT 1 COMMENT '状态: 0未开始 1进行中 2已完成',
    `completed_at` DATETIME DEFAULT NULL COMMENT '完成时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_section` (`user_id`, `section_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_course_id` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户课程进度表';

-- ========== 课程初始数据 ==========
INSERT INTO `course` (`name`, `description`, `skill_id`, `teacher_id`, `difficulty_level`, `sort_order`, `status`) VALUES
('JavaScript 核心语法与实战', '从零开始学习 JavaScript，涵盖变量、数据类型、函数、闭包等核心概念', 1, 2, 1, 1, 1),
('Vue3 组件化开发', '系统学习 Vue3 组合式 API、组件通信、路由和状态管理', 2, 2, 3, 2, 1),
('Python 编程入门', 'Python 基础语法、数据结构、面向对象编程和文件操作', 3, 2, 1, 3, 1),
('Spring Boot 企业级开发', 'Spring Boot 核心原理、RESTful API、数据访问和安全性配置', 4, 2, 4, 4, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- JavaScript 课程 - 章节
INSERT INTO `course_section` (`course_id`, `title`, `description`, `order_index`) VALUES
(1, '变量与数据类型', 'JavaScript 的基本数据类型和变量声明', 1),
(1, '函数与作用域', '函数定义方式、作用域链和闭包', 2),
(1, '数组与对象', '数组方法、对象操作和 JSON', 3);

-- Vue3 课程 - 章节
INSERT INTO `course_section` (`course_id`, `title`, `description`, `order_index`) VALUES
(2, '组合式 API 入门', 'ref、reactive、computed 和 watch 的使用', 1),
(2, '组件通信', 'props、emit、provide/inject 和插槽', 2);

-- Python 课程 - 章节
INSERT INTO `course_section` (`course_id`, `title`, `description`, `order_index`) VALUES
(3, '基础语法', 'Python 缩进规则、变量和基本输入输出', 1),
(3, '数据结构', '列表、元组、字典和集合的使用', 2),
(3, '函数与模块', '函数定义、参数传递和模块导入', 3);

-- Spring Boot 课程 - 章节
INSERT INTO `course_section` (`course_id`, `title`, `description`, `order_index`) VALUES
(4, '项目初始化', '使用 Spring Initializr 创建项目和基本配置', 1),
(4, 'RESTful API 开发', 'Controller、Service、Repository 分层开发', 2);

-- JavaScript 第1章 - 题目
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(1, '以下哪个关键字用于声明常量？', 'choice', '["var", "let", "const", "static"]', 'const', 'const 用于声明常量，一旦赋值不可修改', 1),
(1, 'typeof null 的返回值是什么？', 'choice', '["null", "undefined", "object", "boolean"]', 'object', '这是 JavaScript 的一个历史遗留 bug，typeof null 返回 "object"', 2),
(1, '以下哪个不是 JavaScript 的基本数据类型？', 'choice', '["string", "number", "boolean", "array"]', 'array', 'array 是引用类型（对象），不是基本数据类型', 3),
(1, 'JavaScript 中，undefined == null 的结果是？', 'choice', '["true", "false", "报错", "undefined"]', 'true', '在非严格相等(==)下，undefined 和 null 相互等值', 4),
(1, 'Number(\"123abc\") 的返回值是什么？', 'choice', '["123", "NaN", "报错", "undefined"]', 'NaN', 'Number() 无法完全转换包含非数字字符的字符串时返回 NaN', 5),
(1, 'JavaScript 是编译型语言。', 'true_false', NULL, 'false', 'JavaScript 是解释型语言，由 JS 引擎逐行解释执行', 6),
(1, 'let 声明的变量存在暂时性死区。', 'true_false', NULL, 'true', 'let 和 const 声明的变量在声明前不可访问，称为暂时性死区', 7),
(1, '使用 const 声明的对象，其属性值不能被修改。', 'true_false', NULL, 'false', 'const 保证的是变量引用的对象地址不变，但对象属性可以被修改', 8),
(1, '以下代码的输出是什么？ console.log(typeof typeof 42)', 'choice', '["number", "string", "undefined", "boolean"]', 'string', 'typeof 42 返回 "number"，typeof "number" 返回 "string"', 9),
(1, '0.1 + 0.2 === 0.3 的结果是什么？', 'choice', '["true", "false", "报错", "undefined"]', 'false', '浮点数精度问题，0.1 + 0.2 = 0.30000000000000004 ≠ 0.3', 10);

-- JavaScript 第2章 - 题目
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(2, '箭头函数和普通函数的主要区别是什么？', 'choice', '["语法更简洁", "没有自己的this", "不能有返回值", "不能传参"]', '没有自己的this', '箭头函数不绑定自己的 this，会捕获外层上下文的 this 值', 2),
(2, '以下代码的输出是什么？ for(var i=0; i<3; i++){ setTimeout(()=>console.log(i), 100) }', 'choice', '["0 1 2", "3 3 3", "0 0 0", "undefined"]', '3 3 3', 'var 声明的 i 是函数级作用域，循环结束后 i=3，三个定时器都输出 3', 3),
(2, '以下关于闭包的说法，正确的是？', 'choice', '["闭包会释放外部变量", "闭包可以访问外部函数的变量", "箭头函数不能形成闭包", "闭包只在浏览器中存在"]', '闭包可以访问外部函数的变量', '闭包是指内部函数可以访问外部函数作用域中的变量', 4),
(2, '函数的 call() 和 apply() 方法都可以指定 this。', 'true_false', NULL, 'true', 'call() 和 apply() 都可以显式指定函数执行时的 this 值', 5),
(2, '闭包会导致变量无法被垃圾回收，可能造成内存泄漏。', 'true_false', NULL, 'true', '闭包会保持对外部变量的引用，如果使用不当可能导致内存泄漏', 6);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(3, '以下哪个数组方法会改变原数组？', 'choice', '["map()", "filter()", "push()", "reduce()"]', 'push()', 'push() 会直接修改原数组，而 map/filter/reduce 返回新数组', 1),
(3, '以下哪个方法可以将类数组对象转为数组？', 'choice', '["Array.from()", "Array.of()", "Array.isArray()", "toString()"]', 'Array.from()', 'Array.from() 可以将类数组对象或可迭代对象转为真正的数组', 2),
(3, '展开运算符(...)可以用来复制数组。', 'true_false', NULL, 'true', '使用 [...arr] 可以浅拷贝一个数组', 3),
(3, 'JSON.stringify() 可以处理 function 类型的数据。', 'true_false', NULL, 'false', 'JSON.stringify() 会忽略函数类型的值', 4);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(4, 'Vue3 中 ref 和 reactive 的主要区别是什么？', 'choice', '["ref 用于对象，reactive 用于基本类型", "ref 处理基本类型和对象，reactive 只能处理对象", "两者没有区别", "ref 是 reactive 的语法糖"]', 'ref 处理基本类型和对象，reactive 只能处理对象', 'ref 可以包裹基本类型和对象，reactive 只接受对象类型', 1),
(4, 'computed 和 watch 的区别是什么？', 'choice', '["computed 是异步的", "computed 有缓存，watch 没有", "watch 不能监听多个值", "两者完全一样"]', 'computed 有缓存，watch 没有', 'computed 基于依赖缓存，只有依赖变化时才重新计算；watch 每次变化都执行', 2),
(4, '以下哪个不是 Vue3 生命周期钩子？', 'choice', '["onMounted", "onCreated", "onUnmounted", "onBeforeMount"]', 'onCreated', 'Vue 3 组合式 API 中使用 setup() 代替了 beforeCreate 和 created 钩子', 3),
(4, 'Vue3 的 setup() 函数中可以访问 this。', 'true_false', NULL, 'false', 'setup() 在组件创建前执行，此时组件实例尚未创建，无法访问 this', 4),
(4, 'ref 在模板中自动解包，无需写 .value。', 'true_false', NULL, 'true', '在模板中使用 ref 时，Vue 会自动解包，不需要写 .value', 5);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(5, 'Vue 组件通信中，子向父传递数据应该使用？', 'choice', '["props", "emit", "provide/inject", "slot"]', 'emit', '子组件通过 $emit 触发事件，父组件监听事件来接收数据', 1),
(5, '关于 Vue3 插槽(slot)的说法错误的是？', 'choice', '["具名插槽用 name 标识", "作用域插槽可以让父组件访问子组件的数据", "插槽只能用于传递文本", "插槽可以设置默认内容"]', '插槽只能用于传递文本', '插槽可以传递任何模板内容，包括组件和 HTML', 2),
(5, 'provide/inject 适合在什么场景使用？', 'choice', '["父子组件通信", "深层级组件传值", "兄弟组件通信", "跨页面传值"]', '深层级组件传值', 'provide/inject 主要用于深层嵌套的组件之间传值，避免逐层传递 props', 3);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(6, 'Python 代码块使用什么表示代码块的开始和结束？', 'choice', '["中括号{}", "缩进", "begin/end", "括号()"]', '缩进', 'Python 使用缩进来表示代码块的层次结构，这是 Python 的核心语法特点', 1),
(6, 'Python 中 print(10 // 3) 的输出是什么？', 'choice', '["3.33", "3", "3.0", "报错"]', '3', '// 是整数除法运算符，结果向下取整，10//3 = 3', 2),
(6, 'Python 是强类型语言。', 'true_false', NULL, 'true', 'Python 是强类型语言，不会进行隐式类型转换', 3),
(6, 'Python 中的变量不需要声明类型。', 'true_false', NULL, 'true', 'Python 是动态类型语言，变量类型由赋值自动推断', 4);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(7, '以下哪个数据是可变的(mutable)？', 'choice', '["元组(tuple)", "字符串(string)", "列表(list)", "整数(int)"]', '列表(list)', '列表 list 是可变的，可以增删改元素；元组、字符串、数字是不可变的', 1),
(7, '字典 dict 的键必须是什么类型？', 'choice', '["可变类型", "不可变类型", "任意类型", "字符串"]', '不可变类型', '字典的键必须是不可变类型（如字符串、数字、元组），列表等可变类型不能作为键', 2),
(7, '集合(set)中的元素是有序且不重复的。', 'true_false', NULL, 'false', '集合中的元素是无序的，但元素是不重复的', 3);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(8, '定义函数时，*args 表示什么？', 'choice', '["关键字参数", "可变位置参数", "默认参数", "仅限关键字参数"]', '可变位置参数', '*args 用于接收任意数量的位置参数，以元组形式传入函数内部', 1),
(8, '以下哪个语句用于导入模块？', 'choice', '["include", "import", "using", "require"]', 'import', 'Python 使用 import 关键字导入模块', 2);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(9, 'Spring Initializr 生成的入口类需要使用哪个注解？', 'choice', '["@SpringConfiguration", "@SpringBootApplication", "@SpringBootApp", "@EnableAutoConfiguration"]', '@SpringBootApplication', '@SpringBootApplication 是 Spring Boot 的核心注解，组合了 @Configuration、@EnableAutoConfiguration 和 @ComponentScan', 1),
(9, 'application.yml 文件的用途是什么？', 'choice', '["编写业务代码", "存放配置", "定义路由", "管理依赖"]', '存放配置', 'application.yml 是 Spring Boot 的配置文件，用于配置数据源、端口、日志等', 2),
(9, 'Spring Boot 内嵌的默认 Web 服务器是什么？', 'choice', '["Tomcat", "Jetty", "Undertow", "Netty"]', 'Tomcat', 'Spring Boot 默认内嵌 Tomcat 作为 Web 服务器', 3);

INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(10, '@RestController 的作用是什么？', 'choice', '["返回视图", "返回 JSON 数据", "返回 HTML", "返回文件"]', '返回 JSON 数据', '@RestController 是 @Controller 和 @ResponseBody 的组合，方法默认返回 JSON 数据', 1),
(10, '@Autowired 是什么注入方式？', 'choice', '["构造器注入", "Setter 注入", "字段注入", "接口注入"]', '字段注入', '@Autowired 默认是字段注入（Field Injection），直接在字段上标注即可', 2);
INSERT INTO `user` (`username`, `password`, `nickname`, `email`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '管理员', 'admin@aicompanion.com', 1),
('teacher1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '张老师', 'teacher1@aicompanion.com', 1),
('student1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '小明', 'student1@aicompanion.com', 1)
ON DUPLICATE KEY UPDATE `nickname` = VALUES(`nickname`);

INSERT INTO `skill` (`name`, `category`, `level`, `description`) VALUES
('JavaScript 基础', '前端开发', 1, '学习 JavaScript 基本语法、变量、数据类型和函数'),
('Vue3 框架', '前端开发', 3, '掌握 Vue3 组合式 API、响应式原理和组件开发'),
('Python 基础', '后端开发', 1, 'Python 基础语法、数据结构和面向对象编程'),
('Spring Boot', '后端开发', 4, 'Spring Boot 框架核心原理和企业级应用开发'),
('MySQL 数据库', '数据库', 2, 'MySQL 数据库基础、SQL 语句和性能优化'),
('Docker 容器', '运维部署', 3, 'Docker 容器化技术、Dockerfile 和容器编排')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `user_skill` (`user_id`, `skill_id`, `score`, `proficiency`, `practice_count`) VALUES
(3, 1, 85, 'advanced', 12),
(3, 2, 60, 'intermediate', 5),
(3, 3, 45, 'intermediate', 3),
(3, 4, 30, 'beginner', 2),
(3, 5, 70, 'intermediate', 8)
ON DUPLICATE KEY UPDATE `score` = VALUES(`score`);

INSERT INTO `study_record` (`user_id`, `content`, `duration`, `type`, `status`) VALUES
(3, '学习 JavaScript 基本语法', 60, '视频课程', 2),
(3, '练习 Vue3 组合式 API', 45, '动手练习', 1),
(3, '学习 MySQL 索引优化', 90, '视频课程', 2),
(3, 'Spring Boot RESTful API 练习', 120, '项目实战', 1),
(3, 'Python 基础数据结构复习', 30, '课后复习', 2);

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

-- ========== 初始数据 ==========
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

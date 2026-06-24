-- 修复 user 表缺少 role 字段的问题
USE ai_companion;

-- 添加 role 字段（如果已存在会报错，可忽略）
ALTER TABLE `user` 
ADD COLUMN `role` VARCHAR(20) DEFAULT 'student' COMMENT '角色：admin管理员 teacher教师 student学生' AFTER `avatar`;

-- 添加索引（如果已存在会报错，可忽略）
ALTER TABLE `user` 
ADD INDEX `idx_create_time` (`create_time`);

-- 更新现有管理员账号的角色
UPDATE `user` SET `role` = 'admin' WHERE `username` = 'admin';

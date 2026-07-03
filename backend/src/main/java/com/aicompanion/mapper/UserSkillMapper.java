package com.aicompanion.mapper;

import com.aicompanion.model.entity.UserSkill;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户技能关联 Mapper 接口
 * 继承 BaseMapper 获得基础 CRUD 能力
 */
@Mapper
public interface UserSkillMapper extends BaseMapper<UserSkill> {
}

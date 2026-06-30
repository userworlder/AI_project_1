package com.aicompanion.mapper;

import com.aicompanion.model.entity.SkillTree;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * 技能树 Mapper 接口
 * 继承 BaseMapper 获得基础 CRUD 能力
 */
@Mapper
public interface SkillTreeMapper extends BaseMapper<SkillTree> {
}

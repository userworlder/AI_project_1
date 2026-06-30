package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 技能树实体类
 * 对应数据库表 skill_tree，支持树形层级结构（通过 parentId 关联）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("skill_tree")
public class SkillTree extends BaseEntity {

    /**
     * 技能名称
     */
    private String name;

    /**
     * 技能描述
     */
    private String description;

    /**
     * 技能分类（如：前端、后端、AI、工具等）
     */
    private String category;

    /**
     * 技能难度等级（1-5，数字越大越难）
     */
    private Integer level;

    /**
     * 父节点 ID，根节点的 parentId 为 0
     */
    private Long parentId;
}

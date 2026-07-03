package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 技能信息 VO
 * 返回给 AI 的结构化数据，描述用户对单个技能的掌握情况
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkillInfo {
    /**
     * 技能名称
     */
    private String skillName;

    /**
     * 技能分类（如：前端开发、后端开发、数据库等）
     */
    private String category;

    /**
     * 技能评分（0-100）
     */
    private Integer score;

    /**
     * 熟练度：beginner入门 intermediate中等 advanced熟练 expert精通 或 not_started未学习
     */
    private String proficiency;

    /**
     * 技能描述
     */
    private String description;

    /**
     * 技能难度等级（1-5）
     */
    private Integer skillLevel;
}

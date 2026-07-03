package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 技能分析结果 VO
 * 返回给 AI 的结构化数据，描述用户整体的技能画像
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkillAnalysis {

    /**
     * 用户的所有技能列表
     */
    private List<SkillInfo> skills;

    /**
     * 技能总数量
     */
    private Integer totalSkills;

    /**
     * 平均分
     */
    private Double averageScore;

    /**
     * 最强分类
     */
    private String strongestCategory;

    /**
     * 最弱分类
     */
    private String weakestCategory;

    /**
     * 综合评估文字
     */
    private String overallAssessment;
}

package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 技能考核记录实体类
 * 对应数据库表 skill_assessment，记录 AI 技能评估的出题、答题和评分全过程
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("skill_assessment")
public class SkillAssessment extends BaseEntity {

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 会话标识，关联 start 和 submit
     */
    private String sessionId;

    /**
     * 考核的技能名称
     */
    private String skillName;

    /**
     * AI 生成的题目 JSON（含题目和参考答案）
     */
    private String questionsJson;

    /**
     * 用户提交的答案 JSON
     */
    private String answersJson;

    /**
     * 总分（0-100）
     */
    private Integer score;

    /**
     * AI 总体评价
     */
    private String evaluation;

    /**
     * AI 识别的优点（JSON 数组字符串）
     */
    private String strengths;

    /**
     * 改进建议（JSON 数组字符串）
     */
    private String improvements;

    /**
     * 状态：0=进行中 1=已完成
     */
    private Integer status;
}

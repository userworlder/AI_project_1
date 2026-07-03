package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 考核结果 VO
 * AI 评估后返回的评分和反馈
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssessmentResultVO {

    /**
     * 总分（0-100）
     */
    private int score;

    /**
     * AI 总体评价
     */
    private String evaluation;

    /**
     * 优点列表
     */
    private List<String> strengths;

    /**
     * 改进建议列表
     */
    private List<String> improvements;
}

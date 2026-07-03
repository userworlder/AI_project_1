package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 考核题目 VO
 * 返回给前端的题目（不包含参考答案）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssessmentQuestionVO {

    /**
     * 题目序号
     */
    private int index;

    /**
     * 题目内容
     */
    private String question;
}

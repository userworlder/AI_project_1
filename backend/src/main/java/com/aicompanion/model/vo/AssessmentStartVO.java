package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 开始考核响应 VO
 * 包含会话ID和题目列表
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssessmentStartVO {

    /**
     * 会话ID，用于后续提交答案
     */
    private String sessionId;

    /**
     * 考核题目列表
     */
    private List<AssessmentQuestionVO> questions;
}

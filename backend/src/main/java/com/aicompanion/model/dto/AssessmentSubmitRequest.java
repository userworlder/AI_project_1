package com.aicompanion.model.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

/**
 * 提交考核答案请求 DTO
 */
@Data
public class AssessmentSubmitRequest {

    /**
     * 会话ID，由 start 接口返回
     */
    @NotBlank(message = "会话ID不能为空")
    private String sessionId;

    /**
     * 用户对每道题的答案列表
     */
    @NotEmpty(message = "答案列表不能为空")
    @Valid
    private List<AnswerItem> answers;

    /**
     * 单道题的答案
     */
    @Data
    public static class AnswerItem {

        /**
         * 题目序号（从 0 开始）
         */
        private int questionIndex;

        /**
         * 用户答案文本
         */
        @NotBlank(message = "答案内容不能为空")
        private String answer;
    }
}

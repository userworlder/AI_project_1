package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class QuestionDTO {

    @NotNull(message = "章节ID不能为空")
    private Long sectionId;

    @NotBlank(message = "题目内容不能为空")
    private String content;

    @NotBlank(message = "题目类型不能为空")
    private String type;

    private String options;

    @NotBlank(message = "正确答案不能为空")
    private String correctAnswer;

    private String analysis;

    private Integer orderIndex;
}

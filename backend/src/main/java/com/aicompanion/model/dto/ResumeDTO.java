package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ResumeDTO {

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    private String title;

    @NotBlank(message = "简历内容不能为空")
    private String content;

    private String evaluation;

    private Integer score;

    private String strengths;

    private String suggestions;

    private String status;
}

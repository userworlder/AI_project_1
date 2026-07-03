package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 开始考核请求 DTO
 */
@Data
public class AssessmentStartRequest {

    /**
     * 技能名称，如 "Java"、"Spring Boot"、"MySQL" 等
     */
    @NotBlank(message = "技能名称不能为空")
    private String skillName;
}

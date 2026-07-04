package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CourseDTO {

    @NotBlank(message = "课程名称不能为空")
    private String name;

    private String description;

    private Long skillId;

    private Integer difficultyLevel = 1;

    private String coverImage;

    private Integer sortOrder;

    private Integer status;
}

package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SkillDTO {

    @NotBlank(message = "技能名称不能为空")
    private String name;

    @NotBlank(message = "分类不能为空")
    private String category;

    @NotNull(message = "难度等级不能为空")
    private Integer level;

    @NotBlank(message = "描述不能为空")
    private String description;
}

package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 技能树新增/修改 DTO
 */
@Data
public class SkillTreeDTO {

    @NotBlank(message = "技能名称不能为空")
    private String name;

    private String description;

    @NotBlank(message = "技能分类不能为空")
    private String category;

    @NotNull(message = "难度等级不能为空")
    private Integer level;

    /**
     * 父节点 ID（默认为 0，表示根节点）
     */
    private Long parentId = 0L;
}

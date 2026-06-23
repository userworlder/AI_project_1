package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StudyRecordDTO {

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotBlank(message = "学习内容不能为空")
    private String content;

    @NotNull(message = "学习时长不能为空")
    private Integer duration;

    @NotBlank(message = "学习类型不能为空")
    private String type;

    private Integer status;
}

package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SkillVO {

    private Long id;

    private String name;

    private String category;

    private Integer level;

    private String description;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

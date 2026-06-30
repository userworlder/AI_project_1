package com.aicompanion.model.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 技能树 VO，返回给前端
 */
@Data
public class SkillTreeVO {

    private Long id;

    private String name;

    private String description;

    private String category;

    private Integer level;

    private Long parentId;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

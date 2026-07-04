package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course")
public class Course extends BaseEntity {

    private String name;

    private String description;

    private Long skillId;

    private Long teacherId;

    private Integer difficultyLevel;

    private String coverImage;

    private Integer sortOrder;

    private Integer status;
}

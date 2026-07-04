package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_section")
public class CourseSection extends BaseEntity {

    private Long courseId;

    private String title;

    private String description;

    private Integer orderIndex;
}

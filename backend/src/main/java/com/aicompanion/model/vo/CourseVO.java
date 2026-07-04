package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CourseVO {

    private Long id;

    private String name;

    private String description;

    private Long skillId;

    private String skillName;

    private Long teacherId;

    private String teacherName;

    private Integer difficultyLevel;

    private String coverImage;

    private Integer sortOrder;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

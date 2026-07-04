package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CourseSectionVO {

    private Long id;

    private Long courseId;

    private String title;

    private String description;

    private Integer orderIndex;

    private Integer status;

    private Integer questionCount;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

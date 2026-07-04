package com.aicompanion.model.vo;

import lombok.Data;

@Data
public class CourseProgressVO {

    private Long totalSections;

    private Long completedSections;

    private Double progress;
}

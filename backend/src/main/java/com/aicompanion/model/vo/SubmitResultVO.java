package com.aicompanion.model.vo;

import lombok.Data;

@Data
public class SubmitResultVO {

    private Integer score;

    private Integer totalQuestions;

    private Integer correctCount;

    private Long sectionId;
}

package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QuestionVO {

    private Long id;

    private Long sectionId;

    private String content;

    private String type;

    private String options;

    private String correctAnswer;

    private String analysis;

    private Integer orderIndex;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

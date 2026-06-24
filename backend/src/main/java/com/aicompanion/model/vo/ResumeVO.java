package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ResumeVO {

    private Long id;

    private Long userId;

    private String title;

    private String content;

    private String evaluation;

    private Integer score;

    private String strengths;

    private String suggestions;

    private String status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

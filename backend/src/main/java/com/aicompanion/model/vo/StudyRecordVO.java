package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class StudyRecordVO {

    private Long id;

    private Long userId;

    private String content;

    private Integer duration;

    private String type;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

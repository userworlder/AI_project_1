package com.aicompanion.model.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AIConfigVO {

    private Long id;

    private String name;

    private String model;

    private String apiKey;

    private Boolean enabled;

    private String params;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}

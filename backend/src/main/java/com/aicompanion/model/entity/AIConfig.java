package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ai_config")
public class AIConfig extends BaseEntity {

    private String name;

    private String model;

    private String apiKey;

    private Boolean enabled;

    private String params;
}

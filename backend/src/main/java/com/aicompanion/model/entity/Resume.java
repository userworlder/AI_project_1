package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("resume")
public class Resume extends BaseEntity {

    private Long userId;

    private String title;

    private String content;

    private String evaluation;

    private Integer score;

    private String strengths;

    private String suggestions;

    private String status;
}

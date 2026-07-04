package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("question")
public class Question extends BaseEntity {

    private Long sectionId;

    private String content;

    private String type;

    private String options;

    private String correctAnswer;

    private String analysis;

    private Integer orderIndex;
}

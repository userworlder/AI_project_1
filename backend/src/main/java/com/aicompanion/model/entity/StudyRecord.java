package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("study_record")
public class StudyRecord extends BaseEntity {

    private Long userId;

    private String content;

    private Integer duration;

    private String type;

    private Integer status;
}

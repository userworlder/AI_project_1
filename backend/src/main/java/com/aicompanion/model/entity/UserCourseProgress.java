package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user_course_progress")
public class UserCourseProgress extends BaseEntity {

    private Long userId;

    private Long courseId;

    private Long sectionId;

    private Integer score;

    private Integer totalQuestions;

    private Integer correctCount;

    private String answersJson;

    private Integer status;

    private LocalDateTime completedAt;
}

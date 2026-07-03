package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 用户技能关联实体类
 * 对应数据库表 user_skill，记录用户对特定技能的掌握情况
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user_skill")
public class UserSkill extends BaseEntity {

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 技能ID
     */
    private Long skillId;

    /**
     * 技能评分（0-100）
     */
    private Integer score;

    /**
     * 熟练度：beginner入门 intermediate中等 advanced熟练 expert精通
     */
    private String proficiency;

    /**
     * 练习次数
     */
    private Integer practiceCount;

    /**
     * 最后练习时间
     */
    private LocalDateTime lastPracticed;
}

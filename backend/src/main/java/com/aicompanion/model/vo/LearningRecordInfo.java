package com.aicompanion.model.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * 学习记录分析结果 VO
 * 返回给 AI 的结构化数据，描述用户的学习行为和进度
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LearningRecordInfo {

    /**
     * 总学习时长（分钟）
     */
    private Integer totalDuration;

    /**
     * 总学习记录数
     */
    private Integer totalRecords;

    /**
     * 日均学习时长（分钟）
     */
    private Integer averageDurationPerDay;

    /**
     * 完成率（百分比 0-100）
     */
    private Integer completionRate;

    /**
     * 各类型学习时长分布（类型 -> 分钟数）
     */
    private Map<String, Integer> durationByType;

    /**
     * 最近的学习记录列表
     */
    private List<StudyRecordVO> recentRecords;
}

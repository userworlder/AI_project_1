package com.aicompanion.tool;

import com.aicompanion.mapper.StudyRecordMapper;
import com.aicompanion.model.entity.StudyRecord;
import com.aicompanion.model.vo.LearningRecordInfo;
import com.aicompanion.model.vo.StudyRecordVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习记录查询工具
 * <p>
 * AI 通过此工具查询用户最近一段时间的学习记录，包括总学习时长、学习次数、
 * 每日平均时长、完成率、各类型学习时长分布等。
 * 在 AI 评估用户学习情况或提供学习建议时参考用户的历史学习行为。
 * </p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LearningRecordTool {

    private final StudyRecordMapper studyRecordMapper;

    /**
     * 查询用户最近一段时间的学习记录
     *
     * @param userId 用户ID
     * @param days   查询的天数范围，例如30表示最近30天。默认30天
     * @return 学习记录分析结果（总时长、总记录数、日均时长、完成率、分类统计、最近记录）
     */
    @Tool(description = "查询用户最近一段时间的学习记录。返回总学习时长(分钟)、总记录数、日均学习时长、完成率(百分比)、各类型学习时长分布，以及最近10条记录详情。用于AI在学习评估时参考用户的历史学习行为。")
    public LearningRecordInfo getLearningRecords(
            @ToolParam(description = "用户ID") Long userId,
            @ToolParam(description = "查询的天数范围，例如30表示最近30天。默认30天") Integer days) {

        if (days == null || days <= 0) {
            days = 30;
        }

        log.info("LearningRecordTool 被调用: userId={}, days={}", userId, days);

        // 1. 查询该用户在指定天数内的学习记录
        LocalDateTime since = LocalDateTime.now().minusDays(days);

        LambdaQueryWrapper<StudyRecord> wrapper = Wrappers.lambdaQuery(StudyRecord.class)
                .eq(StudyRecord::getUserId, userId)
                .ge(StudyRecord::getCreateTime, since)
                .orderByDesc(StudyRecord::getCreateTime);

        List<StudyRecord> records = studyRecordMapper.selectList(wrapper);

        // 2. 转换最近 10 条为 VO
        List<StudyRecordVO> recentVOs = records.stream()
                .limit(10)
                .map(r -> {
                    StudyRecordVO vo = new StudyRecordVO();
                    BeanUtils.copyProperties(r, vo);
                    return vo;
                })
                .collect(Collectors.toList());

        // 3. 聚合统计
        LearningRecordInfo info = new LearningRecordInfo();
        info.setTotalRecords(records.size());
        info.setRecentRecords(recentVOs);

        if (records.isEmpty()) {
            info.setTotalDuration(0);
            info.setAverageDurationPerDay(0);
            info.setCompletionRate(0);
            info.setDurationByType(new HashMap<>());
            log.info("LearningRecordTool 返回: 无学习记录");
            return info;
        }

        // 总学习时长
        int totalDuration = records.stream()
                .filter(r -> r.getDuration() != null)
                .mapToInt(StudyRecord::getDuration)
                .sum();
        info.setTotalDuration(totalDuration);

        // 日均时长
        info.setAverageDurationPerDay(totalDuration / Math.max(days, 1));

        // 完成率：status >= 2 视为已完成
        long completed = records.stream()
                .filter(r -> r.getStatus() != null && r.getStatus() >= 2)
                .count();
        int completionRate = (int) Math.round((double) completed / records.size() * 100);
        info.setCompletionRate(completionRate);

        // 按类型分组统计时长
        Map<String, Integer> durationByType = records.stream()
                .filter(r -> r.getType() != null && r.getDuration() != null)
                .collect(Collectors.groupingBy(
                        StudyRecord::getType,
                        Collectors.summingInt(StudyRecord::getDuration)
                ));
        info.setDurationByType(durationByType);

        log.info("LearningRecordTool 返回: totalDuration={}, totalRecords={}, completionRate={}%",
                totalDuration, records.size(), completionRate);

        return info;
    }
}

package com.aicompanion.service.impl;

import com.aicompanion.mapper.UserMapper;
import com.aicompanion.mapper.AiChatHistoryMapper;
import com.aicompanion.mapper.StudyRecordMapper;
import com.aicompanion.model.vo.DashboardStatsVO;
import com.aicompanion.service.DashboardService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final UserMapper userMapper;
    private final StudyRecordMapper studyRecordMapper;
    private final AiChatHistoryMapper aiChatHistoryMapper;

    @Override
    public DashboardStatsVO getStats() {
        DashboardStatsVO stats = new DashboardStatsVO();

        // 统计用户总数
        stats.setTotalUsers(userMapper.selectCount(null));

        // 统计总学习时长（从 study_record 汇总 duration）
        long totalHours = 0;
        try {
            QueryWrapper<com.aicompanion.model.entity.StudyRecord> sumWrapper = new QueryWrapper<>();
            sumWrapper.select("COALESCE(SUM(duration), 0) as total_minutes");
            sumWrapper.eq("deleted", 0);
            var result = studyRecordMapper.selectMaps(sumWrapper);
            if (!result.isEmpty()) {
                Object val = result.get(0).get("total_minutes");
                if (val != null) {
                    totalHours = Long.parseLong(val.toString()) / 60;
                }
            }
        } catch (Exception e) {
            log.warn("计算学习时长异常", e);
        }
        stats.setTotalLearningHours(totalHours);

        // 统计AI交互次数（ai_chat_history 中用户消息数）
        LambdaQueryWrapper<com.aicompanion.model.entity.AiChatHistory> chatWrapper = new LambdaQueryWrapper<>();
        chatWrapper.eq(com.aicompanion.model.entity.AiChatHistory::getRole, "user");
        chatWrapper.eq(com.aicompanion.model.entity.AiChatHistory::getDeleted, 0);
        long aiInteractions = aiChatHistoryMapper.selectCount(chatWrapper);
        stats.setAiInteractions(aiInteractions > 0 ? aiInteractions : 0);

        // 统计活跃用户数（近7天有学习记录的用户）
        long activeUsers = 0;
        try {
            QueryWrapper<com.aicompanion.model.entity.StudyRecord> activeQw = new QueryWrapper<>();
            activeQw.select("COUNT(DISTINCT user_id) as cnt");
            activeQw.ge("create_time", LocalDateTime.now().minusDays(7));
            activeQw.eq("deleted", 0);
            var result = studyRecordMapper.selectMaps(activeQw);
            if (!result.isEmpty()) {
                Object val = result.get(0).get("cnt");
                if (val != null) {
                    activeUsers = Long.parseLong(val.toString());
                }
            }
        } catch (Exception e) {
            log.warn("计算活跃用户异常", e);
        }
        stats.setActiveUsers(activeUsers > 0 ? activeUsers : stats.getTotalUsers());

        log.info("仪表盘统计: 用户={}, 学习时长={}h, AI交互={}, 活跃用户={}",
                stats.getTotalUsers(), totalHours, aiInteractions, activeUsers);

        return stats;
    }
}

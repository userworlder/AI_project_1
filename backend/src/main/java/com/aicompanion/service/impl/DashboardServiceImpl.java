package com.aicompanion.service.impl;

import com.aicompanion.mapper.UserMapper;
import com.aicompanion.model.vo.DashboardStatsVO;
import com.aicompanion.service.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final UserMapper userMapper;

    @Override
    public DashboardStatsVO getStats() {
        DashboardStatsVO stats = new DashboardStatsVO();

        // 统计用户总数
        stats.setTotalUsers(userMapper.selectCount(null));

        // 模拟学习时长和AI交互数据
        stats.setTotalLearningHours(1280L);
        stats.setAiInteractions(3560L);
        stats.setActiveUsers(stats.getTotalUsers() > 0 ? stats.getTotalUsers() / 3 * 2 : 0);

        return stats;
    }
}

package com.aicompanion.model.vo;

import lombok.Data;

@Data
public class DashboardStatsVO {

    private Long totalUsers;

    private Long totalLearningHours;

    private Long aiInteractions;

    private Long activeUsers;
}

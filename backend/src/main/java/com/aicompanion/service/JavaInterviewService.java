package com.aicompanion.service;

/**
 * Java 基础面试官服务接口
 */
public interface JavaInterviewService {

    /**
     * 发送面试消息
     *
     * @param sessionId 面试会话 ID（同一会话保持上下文连贯）
     * @param message   候选人回答内容（第一轮可为空，由面试官出第一题）
     * @return 面试官反馈（出题 / 评估 + 追问）
     */
    String interview(String sessionId, String message);
}

package com.aicompanion.service;

import reactor.core.publisher.Flux;

/**
 * AI 聊天服务接口
 */
public interface ChatService {

    /**
     * 发送同步聊天消息
     *
     * @param sessionId 会话 ID
     * @param message   用户消息
     * @return AI 回复内容
     */
    String chat(String sessionId, String message);

    /**
     * 发送同步聊天消息（支持自定义系统提示词）
     *
     * @param sessionId    会话 ID
     * @param message      用户消息
     * @param systemPrompt 自定义系统提示词，为 null 时使用默认
     * @return AI 回复内容
     */
    String chat(String sessionId, String message, String systemPrompt);

    /**
     * 发送 SSE 流式聊天消息
     */
    Flux<String> chatStream(String sessionId, String message);

    /**
     * 发送 SSE 流式聊天消息（支持自定义系统提示词）
     */
    Flux<String> chatStream(String sessionId, String message, String systemPrompt);
}

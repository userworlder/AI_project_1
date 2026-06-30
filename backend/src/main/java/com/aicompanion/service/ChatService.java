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
     * 发送 SSE 流式聊天消息
     * 返回 Flux 流，每段文本作为一个 data: 事件下发
     *
     * @param sessionId 会话 ID
     * @param message   用户消息
     * @return SSE 事件流（text/event-stream）
     */
    Flux<String> chatStream(String sessionId, String message);
}

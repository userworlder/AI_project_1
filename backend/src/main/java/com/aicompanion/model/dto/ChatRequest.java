package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 聊天请求 DTO
 */
@Data
public class ChatRequest {

    /**
     * 会话 ID（用于区分不同对话）
     */
    @NotBlank(message = "会话ID不能为空")
    private String sessionId;

    /**
     * 用户发送的消息内容
     */
    @NotBlank(message = "消息不能为空")
    private String message;
}

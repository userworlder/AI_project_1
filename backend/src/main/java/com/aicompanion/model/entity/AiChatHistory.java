package com.aicompanion.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * AI 聊天历史记录实体类
 * 对应数据库表 ai_chat_history，记录每次对话的用户消息和 AI 回复
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ai_chat_history")
public class AiChatHistory extends BaseEntity {

    /**
     * 会话 ID，用于关联同一轮对话的用户消息与 AI 回复
     */
    private String sessionId;

    /**
     * 消息角色：user（用户） / assistant（AI）
     */
    private String role;

    /**
     * 消息内容
     */
    private String content;
}

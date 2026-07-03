package com.aicompanion.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 基于 Redis 的对话记忆实现
 *
 * 使用 Redis List 存储消息，每条消息以 {"role":"user","content":"..."} JSON 格式保存。
 * 每个会话一个 key（chat:memory:<conversationId>），自动 24 小时过期。
 *
 * 知识点：
 * 1. ChatMemory 是 Spring AI 的对话记忆接口，MessageChatMemoryAdvisor 自动读写它
 * 2. Message 是接口，不能直接序列化，需转为 role+content 格式
 * 3. 读取时根据 role 重建 UserMessage / AssistantMessage / SystemMessage
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RedisChatMemory implements ChatMemory {

    private static final String KEY_PREFIX = "chat:memory:";
    private static final long TTL_SECONDS = 86400;   // 24 小时
    private static final int MAX_MESSAGES = 50;       // 每个会话最多 50 条

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    @Override
    public void add(String conversationId, List<Message> messages) {
        String key = KEY_PREFIX + conversationId;

        for (Message message : messages) {
            String json = serialize(message);
            if (json != null) {
                redisTemplate.opsForList().rightPush(key, json);
            }
        }

        // 只保留最近 MAX_MESSAGES 条，防止无限增长
        redisTemplate.opsForList().trim(key, -MAX_MESSAGES, -1);

        // 每次写入刷新过期时间
        redisTemplate.expire(key, TTL_SECONDS, TimeUnit.SECONDS);

        log.debug("RedisChatMemory.add: conversationId={}, added {} messages", conversationId, messages.size());
    }

    @Override
    public List<Message> get(String conversationId, int lastN) {
        String key = KEY_PREFIX + conversationId;
        List<String> jsonList = redisTemplate.opsForList().range(key, -lastN, -1);

        if (jsonList == null || jsonList.isEmpty()) {
            return List.of();
        }

        return jsonList.stream()
                .map(this::deserialize)
                .filter(m -> m != null)
                .collect(Collectors.toList());
    }

    @Override
    public void clear(String conversationId) {
        String key = KEY_PREFIX + conversationId;
        redisTemplate.delete(key);
        log.debug("RedisChatMemory.clear: conversationId={}", conversationId);
    }

    // ===== 序列化 / 反序列化 =====

    /**
     * 将 Message 序列化为 {"role":"user","content":"..."} JSON 字符串
     */
    private String serialize(Message message) {
        try {
            String role = switch (message.getMessageType()) {
                case USER -> "user";
                case ASSISTANT -> "assistant";
                case SYSTEM -> "system";
                default -> {
                    log.debug("跳过非用户/助手消息类型: {}", message.getMessageType());
                    yield null;
                }
            };
            if (role == null) return null;

            ObjectNode node = objectMapper.createObjectNode();
            node.put("role", role);
            node.put("content", message.getText());
            return objectMapper.writeValueAsString(node);
        } catch (Exception e) {
            log.error("序列化消息失败", e);
            return null;
        }
    }

    /**
     * 将 JSON 字符串反序列化为 Message 对象
     */
    private Message deserialize(String json) {
        try {
            Map<String, String> map = objectMapper.readValue(json, Map.class);
            String role = map.get("role");
            String content = map.get("content");
            if (content == null) content = "";

            return switch (role) {
                case "user" -> new UserMessage(content);
                case "assistant" -> new AssistantMessage(content);
                case "system" -> new SystemMessage(content);
                default -> {
                    log.warn("未知消息角色: {}", role);
                    yield null;
                }
            };
        } catch (Exception e) {
            log.error("反序列化消息失败: {}", json, e);
            return null;
        }
    }
}

package com.aicompanion.service.impl;

import com.aicompanion.common.util.AuthUser;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.AiChatHistoryMapper;
import com.aicompanion.model.entity.AiChatHistory;
import com.aicompanion.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;

import java.util.concurrent.atomic.AtomicReference;

/**
 * AI 聊天服务实现
 * 对接 DeepSeek（OpenAI 兼容接口），支持带上下文的同步多轮对话
 *
 * 知识点：
 * 1. 使用 AiConfig 中预构建的 ChatClient Bean（已注册 Tools + MessageChatMemoryAdvisor）
 * 2. MessageChatMemoryAdvisor 自动从 Redis ChatMemory 中读取/写入历史消息
 * 3. 同时保留 MySQL 持久化，作为永久聊天记录存储
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatClient chatClient;
    private final AiChatHistoryMapper aiChatHistoryMapper;

    /** 每次携带的历史消息条数 */
    private static final int HISTORY_SIZE = 10;

    /**
     * 系统提示词 —— AI 伴学助手人设
     */
    private static final String SYSTEM_PROMPT = """
            你是一名「灵思·AI学伴」智能学习助手。

            你的核心定位：
            - 面向在校大学生，帮助解决计算机、编程、数学等理工科学习问题
            - 提供耐心、清晰、深入浅出的解答，像一位学长/学姐一样循循善诱

            回答风格要求：
            - 用中文回答，语言简洁易懂
            - 涉及代码时，给出完整可运行的示例
            - 复杂概念先给直观比喻，再深入原理
            - 鼓励学生独立思考，必要时追问引导

            请记住：你的目标是帮助学生真正理解知识，而不是直接给答案。
            """;

    @Override
    public String chat(String sessionId, String message) {
        return chat(sessionId, message, null);
    }

    @Override
    public String chat(String sessionId, String message, String systemPrompt) {
        log.info("AI聊天请求 sessionId={}, message={}", sessionId, message);

        // 1. 保存用户消息到数据库（MySQL 永久记录）
        saveHistory(sessionId, "user", message);

        // 2. 构建增强系统提示词（注入用户上下文，使工具能正确获取 userId）
        String enhancedPrompt = buildEnhancedSystemPrompt(systemPrompt);

        // 3. 调用 AI（MessageChatMemoryAdvisor 自动从 Redis 读取历史上下文）
        //    .system() 设置系统提示词
        //    .user() 设置当前用户消息
        //    .advisors() 指定会话 ID 和历史消息数量
        String reply = chatClient.prompt()
                .system(enhancedPrompt)
                .user(message)
                .advisors(a -> a
                        .param(MessageChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY, sessionId)
                        .param(MessageChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY, HISTORY_SIZE))
                .call()
                .content();

        log.info("AI聊天回复 sessionId={}, reply={}", sessionId, reply);

        // 4. 保存 AI 回复到数据库
        saveHistory(sessionId, "assistant", reply);

        return reply;
    }

    @Override
    public Flux<String> chatStream(String sessionId, String message) {
        return chatStream(sessionId, message, null);
    }

    @Override
    public Flux<String> chatStream(String sessionId, String message, String systemPrompt) {
        log.info("AI流式聊天请求 sessionId={}, message={}", sessionId, message);

        // 1. 保存用户消息到数据库
        saveHistory(sessionId, "user", message);

        // 2. 构建增强系统提示词
        String enhancedPrompt = buildEnhancedSystemPrompt(systemPrompt);

        // 3. 流式调用 AI（MessageChatMemoryAdvisor 自动处理 Redis 上下文）
        Flux<String> stream = chatClient.prompt()
                .system(enhancedPrompt)
                .user(message)
                .advisors(a -> a
                        .param(MessageChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY, sessionId)
                        .param(MessageChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY, HISTORY_SIZE))
                .stream()
                .content();

        // 4. 收集所有片段，流结束时保存完整回复到 DB
        AtomicReference<StringBuilder> fullReply = new AtomicReference<>(new StringBuilder());

        return stream
                .doOnNext(chunk -> fullReply.get().append(chunk))
                .doOnComplete(() -> {
                    String reply = fullReply.get().toString();
                    log.info("AI流式回复完成 sessionId={}, 长度={}", sessionId, reply.length());
                    saveHistory(sessionId, "assistant", reply);
                })
                .doOnError(e -> log.error("AI流式回复异常 sessionId={}", sessionId, e));
    }

    /**
     * 构建包含用户上下文的增强系统提示词
     * <p>
     * 从 SecurityContext 获取当前登录用户的信息（用户ID、用户名），
     * 追加到系统提示词尾部，使 AI 在调用需要 userId 参数的工具时能正确传参。
     *
     * @param customSystemPrompt 自定义系统提示词，为 null 时使用默认
     * @return 包含用户上下文的增强系统提示词
     */
    private String buildEnhancedSystemPrompt(String customSystemPrompt) {
        String basePrompt = (customSystemPrompt != null && !customSystemPrompt.isBlank())
                ? customSystemPrompt : SYSTEM_PROMPT;

        // 获取当前登录用户信息（来自 JWT 上下文）
        AuthUser currentUser = SecurityUtils.getCurrentUser();
        if (currentUser == null) {
            log.debug("未获取到当前用户信息，使用原始系统提示词");
            return basePrompt;
        }

        // 在系统提示词末尾追加用户上下文，使 AI 在 Function Calling 时能正确传递 userId
        return basePrompt + "\n\n" +
                "===== 当前用户上下文（工具调用时请使用此用户ID）=====\n" +
                "当前用户ID: " + currentUser.getUserId() + "\n" +
                "当前用户: " + currentUser.getUsername() + "\n" +
                "当需要查询技能、分析用户画像或查询学习记录时，请使用上述用户ID调用对应工具。\n" +
                "===== 用户上下文结束 =====";
    }

    /**
     * 保存聊天记录到数据库
     */
    private void saveHistory(String sessionId, String role, String content) {
        AiChatHistory history = new AiChatHistory();
        history.setSessionId(sessionId);
        history.setRole(role);
        history.setContent(content);
        aiChatHistoryMapper.insert(history);
    }
}

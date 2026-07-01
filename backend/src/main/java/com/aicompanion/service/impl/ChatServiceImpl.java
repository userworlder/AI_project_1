package com.aicompanion.service.impl;

import com.aicompanion.mapper.AiChatHistoryMapper;
import com.aicompanion.model.entity.AiChatHistory;
import com.aicompanion.service.ChatService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

/**
 * AI 聊天服务实现
 * 对接 DeepSeek（OpenAI 兼容接口），支持带上下文的同步多轮对话
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatClient.Builder chatClientBuilder;
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

        // 1. 查询该会话最近 HISTORY_SIZE 条历史记录
        List<AiChatHistory> historyList = queryRecentHistory(sessionId);

        // 2. 保存用户消息到数据库
        saveHistory(sessionId, "user", message);

        // 3. 构建完整消息列表
        List<Message> messageList = buildMessageList(historyList, message, systemPrompt);
        log.debug("组装消息列表共 {} 条，其中系统提示词 1 条，历史 {} 条，当前消息 1 条",
                messageList.size(), historyList.size());

        // 4. 调用 AI 获取回复（同步，带上下文）
        ChatClient chatClient = chatClientBuilder.build();
        String reply = chatClient.prompt()
                .messages(messageList)
                .call()
                .content();

        log.info("AI聊天回复 sessionId={}, reply={}", sessionId, reply);

        // 5. 保存 AI 回复到数据库
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

        // 1. 查询历史 + 保存用户消息
        List<AiChatHistory> historyList = queryRecentHistory(sessionId);
        saveHistory(sessionId, "user", message);

        // 2. 构建消息列表
        List<Message> messageList = buildMessageList(historyList, message, systemPrompt);

        // 3. 流式调用 AI
        ChatClient chatClient = chatClientBuilder.build();
        Flux<String> stream = chatClient.prompt()
                .messages(messageList)
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
     * 按 sessionId 查询最近 HISTORY_SIZE 条历史消息（按时间正序排列）
     */
    private List<AiChatHistory> queryRecentHistory(String sessionId) {
        LambdaQueryWrapper<AiChatHistory> wrapper = Wrappers.lambdaQuery(AiChatHistory.class)
                .eq(AiChatHistory::getSessionId, sessionId)
                .orderByDesc(AiChatHistory::getCreateTime)
                .last("LIMIT " + HISTORY_SIZE);

        List<AiChatHistory> records = aiChatHistoryMapper.selectList(wrapper);

        // 按时间正序返回（最早的在前），以便构建对话上下文
        records.sort((a, b) -> {
            if (a.getCreateTime() == null || b.getCreateTime() == null) return 0;
            return a.getCreateTime().compareTo(b.getCreateTime());
        });

        return records;
    }

    /**
     * 构建发送给大模型的完整消息列表
     * <p>
     * 消息顺序为：SystemMessage → 历史 UserMessage/AssistantMessage → 当前 UserMessage
     *
     * @param systemPrompt 自定义系统提示词，为 null 时使用默认
     */
    private List<Message> buildMessageList(List<AiChatHistory> historyList, String currentMessage, String systemPrompt) {
        List<Message> messages = new ArrayList<>();

        // 第一条：系统提示词（自定义优先，否则使用默认）
        String prompt = (systemPrompt != null && !systemPrompt.isBlank()) ? systemPrompt : SYSTEM_PROMPT;
        messages.add(new SystemMessage(prompt));

        // 中间：历史对话记录（按角色转为对应的 Message 类型）
        for (AiChatHistory record : historyList) {
            switch (record.getRole()) {
                case "user":
                    messages.add(new UserMessage(record.getContent()));
                    break;
                case "assistant":
                    messages.add(new AssistantMessage(record.getContent()));
                    break;
                default:
                    log.warn("未知消息角色: {}", record.getRole());
            }
        }

        // 最后一条：当前用户消息
        messages.add(new UserMessage(currentMessage));

        return messages;
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

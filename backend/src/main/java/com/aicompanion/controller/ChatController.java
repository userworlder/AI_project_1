package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.ChatRequest;
import com.aicompanion.service.ChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

/**
 * AI 聊天控制器
 * 提供与 AI 学伴对话的 RESTful 接口（同步 + SSE 流式）
 */
@Tag(name = "AI 聊天", description = "AI 学伴对话接口")
@RestController
@RequestMapping("/api/ai/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @Operation(summary = "发送聊天消息（同步）", description = "向 AI 发送消息并同步获取完整回复，自动记录对话历史")
    @PostMapping("/message")
    public Result<String> chat(@Valid @RequestBody ChatRequest request) {
        String reply = chatService.chat(request.getSessionId(), request.getMessage());
        return Result.success(reply);
    }

    @Operation(summary = "发送聊天消息（SSE 流式）", description = "向 AI 发送消息并以 SSE 流式返回回复片段，实现打字机效果")
    @PostMapping(value = "/message/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> chatStream(@Valid @RequestBody ChatRequest request) {
        return chatService.chatStream(request.getSessionId(), request.getMessage());
    }
}

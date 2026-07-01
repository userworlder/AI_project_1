package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.ChatRequest;
import com.aicompanion.service.ChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Slf4j

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
        String reply = chatService.chat(request.getSessionId(), request.getMessage(), request.getSystemPrompt());
        return Result.success(reply);
    }

    @Operation(summary = "发送聊天消息（SSE 流式）", description = "向 AI 发送消息并以 SSE 流式返回回复片段，实现打字机效果")
    @PostMapping(value = "/message/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chatStream(@Valid @RequestBody ChatRequest request) {
        // 设置超时时间为 5 分钟
        SseEmitter emitter = new SseEmitter(300_000L);

        // 获取 AI 流式响应
        Flux<String> flux = chatService.chatStream(request.getSessionId(), request.getMessage(), request.getSystemPrompt());

        flux.subscribe(
            chunk -> {
                try {
                    // 用 JSON 包裹每个数据块：{"content":"chunk"}
                    // 这样即使 chunk 中含有换行符，JSON 序列化也会将其转义为 \n
                    // 保证 SSE 数据始终为单行，前端解析时不会丢失换行信息
                    Map<String, String> data = new HashMap<>();
                    data.put("content", chunk);
                    emitter.send(SseEmitter.event()
                            .name("message")
                            .data(data));
                } catch (IOException e) {
                    emitter.completeWithError(e);
                }
            },
            error -> {
                log.error("SSE 流式异常 sessionId={}", request.getSessionId(), error);
                emitter.completeWithError(error);
            },
            () -> {
                // 发送结束标记
                try {
                    emitter.send(SseEmitter.event()
                            .name("message")
                            .data("[DONE]"));
                } catch (IOException e) {
                    // 忽略
                }
                emitter.complete();
            }
        );

        // 超时/断开时取消 Flux 订阅
        emitter.onTimeout(() -> {
            log.warn("SSE 超时 sessionId={}", request.getSessionId());
            emitter.complete();
        });
        emitter.onError(e -> {
            log.error("SSE 错误 sessionId={}", request.getSessionId(), e);
            emitter.completeWithError(e);
        });
        emitter.onCompletion(() -> {
            log.info("SSE 完成 sessionId={}", request.getSessionId());
        });

        return emitter;
    }
}

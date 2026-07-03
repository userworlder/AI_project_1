package com.aicompanion.config;

import com.aicompanion.tool.LearningRecordTool;
import com.aicompanion.tool.SkillLookupTool;
import com.aicompanion.tool.UserSkillAnalysisTool;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * AI 配置类
 *
 * 知识点：
 * 1. 统一配置 ChatClient Bean，注入 ChatMemory 和 Tools
 * 2. MessageChatMemoryAdvisor 是 Spring AI 的记忆拦截器，自动读写 ChatMemory
 * 3. defaultTools() 注册的工具对所有对话生效
 */
@Configuration
@RequiredArgsConstructor
public class AiConfig {

    /**
     * 注册 ChatClient Bean
     * <p>
     * ChatClient.Builder 由 spring-ai-openai-spring-boot-starter 自动配置（含 yml 中的模型、地址等）
     * 通过 defaultTools() 注册上午创建的三个工具
     * 通过 defaultAdvisors() 注册 MessageChatMemoryAdvisor 实现对话记忆
     */
    @Bean
    public ChatClient chatClient(ChatClient.Builder builder,
                                 ChatMemory chatMemory,
                                 SkillLookupTool skillLookupTool,
                                 UserSkillAnalysisTool userSkillAnalysisTool,
                                 LearningRecordTool learningRecordTool) {
        return builder
                .defaultTools(skillLookupTool, userSkillAnalysisTool, learningRecordTool)
                .defaultAdvisors(new MessageChatMemoryAdvisor(chatMemory))
                .build();
    }
}

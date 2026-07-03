package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.util.JsonUtil;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.SkillAssessmentMapper;
import com.aicompanion.model.dto.AssessmentStartRequest;
import com.aicompanion.model.dto.AssessmentSubmitRequest;
import com.aicompanion.model.entity.SkillAssessment;
import com.aicompanion.model.vo.AssessmentQuestionVO;
import com.aicompanion.model.vo.AssessmentResultVO;
import com.aicompanion.model.vo.AssessmentStartVO;
import com.aicompanion.service.AssessmentService;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * AI 技能评估服务实现
 *
 * 知识点：
 * 1. 使用 ChatClient.Builder（而非 AiConfig 的 ChatClient Bean），避免加载工具和记忆
 * 2. AI 结构化输出：通过 SystemPrompt 约束 AI 返回固定格式 JSON
 * 3. JsonUtil 工具类处理 AI 回复中的 JSON 提取（支持 Markdown 代码块等）
 * 4. 出题时保存参考答案到数据库，判题时发给 AI 用于对比评分
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AssessmentServiceImpl implements AssessmentService {

    private final ChatClient.Builder chatClientBuilder;
    private final SkillAssessmentMapper skillAssessmentMapper;
    private final ObjectMapper objectMapper;

    /**
     * 出题系统提示词
     * 要求 AI 生成 3 道中等偏上难度的面试题，返回 JSON 数组
     */
    private static final String QUESTION_SYSTEM_PROMPT = """
            你是一名专业的技能评估专家。请针对用户指定的技能名称，生成3道中等偏上难度的面试题。

            要求：
            - 每道题必须包含：question（问题描述）、referenceAnswer（参考答案，要详细准确）
            - 以JSON数组格式返回，不要返回除此之外的任何内容
            - 题目要能真实考察用户对该技能的掌握深度，兼顾概念理解和实际应用

            返回格式示例（仅格式参考，不要照搬内容）：
            [
              {"question": "问题描述", "referenceAnswer": "详细参考答案"},
              {"question": "问题描述", "referenceAnswer": "详细参考答案"},
              {"question": "问题描述", "referenceAnswer": "详细参考答案"}
            ]
            """;

    /**
     * 评分系统提示词
     * 要求 AI 根据题目、参考答案和用户回答进行评分
     */
    private static final String ASSESSMENT_SYSTEM_PROMPT = """
            你是一名专业的技能评估专家。请根据以下题目、参考答案和用户回答，对用户的整体表现进行评估。

            评估标准：
            - 0-20分：初学者（不了解基本概念）
            - 21-40分：入门（知道概念但不会用）
            - 41-60分：中级（能基本使用）
            - 61-80分：熟练（能独立应用）
            - 81-100分：专家（深入理解原理）

            要求：
            - 评价要客观公正，既要指出优点也要指出不足
            - 以JSON格式返回，不要返回除此之外的任何内容

            返回格式：
            {
              "score": 总体分数(0-100),
              "evaluation": "总体评价文字，100-200字",
              "strengths": ["优点1", "优点2"],
              "improvements": ["改进建议1", "改进建议2"]
            }
            """;

    @Override
    @Transactional
    public AssessmentStartVO startAssessment(AssessmentStartRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw BusinessException.unauthorized("用户未登录");
        }

        String skillName = request.getSkillName();
        String sessionId = UUID.randomUUID().toString().replace("-", "");

        log.info("开始技能考核: userId={}, skillName={}, sessionId={}", userId, skillName, sessionId);

        // 1. 调用 AI 生成题目
        ChatClient chatClient = chatClientBuilder.build();
        String aiResponse = chatClient.prompt()
                .system(QUESTION_SYSTEM_PROMPT + "\n\n当前考核技能: " + skillName)
                .user("请为技能「" + skillName + "」生成3道面试题。")
                .call()
                .content();

        log.debug("AI生成题目响应: {}", aiResponse);

        // 2. 解析 AI 返回的 JSON 数组
        List<Map<String, Object>> questionMaps;
        try {
            questionMaps = JsonUtil.extractMapList(aiResponse);
        } catch (Exception e) {
            log.error("解析AI出题结果失败: {}", aiResponse, e);
            throw BusinessException.badRequest("AI 生成的题目格式异常，请重试");
        }

        if (questionMaps.isEmpty()) {
            throw BusinessException.badRequest("AI 未生成有效题目，请重试");
        }

        // 3. 构建返回给前端的题目列表（仅包含题目，不含参考答案）
        List<AssessmentQuestionVO> questions = new ArrayList<>();
        for (int i = 0; i < questionMaps.size(); i++) {
            String question = (String) questionMaps.get(i).get("question");
            questions.add(new AssessmentQuestionVO(i, question != null ? question : ""));
        }

        // 4. 保存考核记录到数据库（含参考答案，评分阶段需要）
        SkillAssessment assessment = new SkillAssessment();
        assessment.setUserId(userId);
        assessment.setSessionId(sessionId);
        assessment.setSkillName(skillName);
        assessment.setStatus(0); // 0=进行中
        try {
            assessment.setQuestionsJson(objectMapper.writeValueAsString(questionMaps));
        } catch (Exception e) {
            log.error("题目 JSON 序列化失败", e);
            throw BusinessException.badRequest("数据序列化异常");
        }
        skillAssessmentMapper.insert(assessment);

        log.info("考核创建成功: sessionId={}, 题目数={}", sessionId, questions.size());

        return new AssessmentStartVO(sessionId, questions);
    }

    @Override
    @Transactional
    public AssessmentResultVO submitAssessment(AssessmentSubmitRequest request) {
        String sessionId = request.getSessionId();

        log.info("提交考核答案: sessionId={}, 答案数={}", sessionId, request.getAnswers().size());

        // 1. 查询考核记录
        SkillAssessment assessment = skillAssessmentMapper.selectOne(
                Wrappers.lambdaQuery(SkillAssessment.class)
                        .eq(SkillAssessment::getSessionId, sessionId));

        if (assessment == null) {
            throw BusinessException.notFound("考核会话不存在");
        }
        if (assessment.getStatus() == 1) {
            throw BusinessException.badRequest("该考核已提交过评分，请勿重复提交");
        }

        // 2. 保存用户答案到数据库
        try {
            assessment.setAnswersJson(objectMapper.writeValueAsString(request.getAnswers()));
        } catch (Exception e) {
            log.error("答案 JSON 序列化失败", e);
            throw BusinessException.badRequest("数据序列化异常");
        }

        // 3. 构建评分 Prompt（题目 + 参考答案 + 用户答案）
        String questionsText = assessment.getQuestionsJson();

        String answersText = request.getAnswers().stream()
                .map(a -> "【第" + (a.getQuestionIndex() + 1) + "题】用户回答: " + a.getAnswer())
                .collect(Collectors.joining("\n\n"));

        String scoringPrompt = String.format(
                "===== 考核题目（含参考答案）=====\n%s\n\n===== 用户回答 =====\n%s",
                questionsText, answersText);

        // 4. 调用 AI 评分
        ChatClient chatClient = chatClientBuilder.build();
        String aiResponse = chatClient.prompt()
                .system(ASSESSMENT_SYSTEM_PROMPT + "\n\n考核技能: " + assessment.getSkillName())
                .user(scoringPrompt)
                .call()
                .content();

        log.debug("AI评分响应: {}", aiResponse);

        // 5. 解析 AI 评分结果
        Map<String, Object> resultMap;
        try {
            resultMap = JsonUtil.extractMap(aiResponse);
        } catch (Exception e) {
            log.error("解析AI评分结果失败, 原始响应: {}", aiResponse, e);
            throw BusinessException.badRequest("AI 评分返回格式异常，请重试");
        }

        // 6. 更新考核记录
        Integer score = resultMap.get("score") instanceof Number
                ? ((Number) resultMap.get("score")).intValue()
                : 0;
        assessment.setScore(score);
        assessment.setEvaluation((String) resultMap.get("evaluation"));

        try {
            assessment.setStrengths(objectMapper.writeValueAsString(resultMap.get("strengths")));
            assessment.setImprovements(objectMapper.writeValueAsString(resultMap.get("improvements")));
        } catch (Exception e) {
            log.warn("优点/改进建议序列化失败", e);
        }
        assessment.setStatus(1); // 1=已完成
        skillAssessmentMapper.updateById(assessment);

        log.info("考核完成: sessionId={}, score={}", sessionId, score);

        // 7. 组装返回结果
        AssessmentResultVO result = new AssessmentResultVO();
        result.setScore(score);
        result.setEvaluation(assessment.getEvaluation());

        @SuppressWarnings("unchecked")
        List<String> strengths = resultMap.get("strengths") instanceof List
                ? (List<String>) resultMap.get("strengths")
                : List.of();
        @SuppressWarnings("unchecked")
        List<String> improvements = resultMap.get("improvements") instanceof List
                ? (List<String>) resultMap.get("improvements")
                : List.of();

        result.setStrengths(strengths);
        result.setImprovements(improvements);

        return result;
    }
}

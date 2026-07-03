package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.AssessmentStartRequest;
import com.aicompanion.model.dto.AssessmentSubmitRequest;
import com.aicompanion.model.vo.AssessmentResultVO;
import com.aicompanion.model.vo.AssessmentStartVO;
import com.aicompanion.service.AssessmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * AI 技能考核控制器
 *
 * 提供技能评估的出题和判分接口：
 * - POST /api/assessment/start：AI 根据技能名生成面试题
 * - POST /api/assessment/submit：AI 评估用户答案并评分
 */
@Slf4j
@Tag(name = "技能考核", description = "AI 技能评估考核接口")
@RestController
@RequestMapping("/api/assessment")
@RequiredArgsConstructor
public class AssessmentController {

    private final AssessmentService assessmentService;

    @Operation(summary = "开始技能考核",
            description = "传入技能名称，AI 自动生成3道面试题并返回（不包含参考答案）")
    @PostMapping("/start")
    public Result<AssessmentStartVO> startAssessment(@Valid @RequestBody AssessmentStartRequest request) {
        log.info("请求开始技能考核: skillName={}", request.getSkillName());

        AssessmentStartVO result = assessmentService.startAssessment(request);

        return Result.success(result);
    }

    @Operation(summary = "提交考核答案",
            description = "提交用户对题目的回答，AI 评分并返回评估结果（分数、评价、优点、改进建议）")
    @PostMapping("/submit")
    public Result<AssessmentResultVO> submitAssessment(@Valid @RequestBody AssessmentSubmitRequest request) {
        log.info("请求提交考核答案: sessionId={}, 答案数={}",
                request.getSessionId(), request.getAnswers().size());

        AssessmentResultVO result = assessmentService.submitAssessment(request);

        return Result.success(result);
    }
}

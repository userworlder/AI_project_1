package com.aicompanion.service;

import com.aicompanion.model.dto.AssessmentStartRequest;
import com.aicompanion.model.dto.AssessmentSubmitRequest;
import com.aicompanion.model.vo.AssessmentQuestionVO;
import com.aicompanion.model.vo.AssessmentResultVO;
import com.aicompanion.model.vo.AssessmentStartVO;

import java.util.List;

/**
 * AI 技能评估服务接口
 *
 * 知识点：
 * 1. AI 出题：根据技能名生成面试题，返回结构化 JSON（无工具调用）
 * 2. AI 判题：评估用户答案质量，返回评分和改进建议
 */
public interface AssessmentService {

    /**
     * 开始技能考核
     * <p>
     * AI 根据技能名称生成 3 道面试题（含参考答案），
     * 保存到数据库后返回题目列表（不含参考答案）给前端。
     *
     * @param request 开始考核请求（技能名称）
     * @return 考核会话（含 sessionId 和题目列表）
     */
    AssessmentStartVO startAssessment(AssessmentStartRequest request);

    /**
     * 提交考核答案
     * <p>
     * AI 根据题目（含参考答案）和用户答案进行评分，
     * 返回评分、评价、优点和改进建议。
     *
     * @param request 提交考核请求（会话ID + 答案列表）
     * @return 评估结果
     */
    AssessmentResultVO submitAssessment(AssessmentSubmitRequest request);
}

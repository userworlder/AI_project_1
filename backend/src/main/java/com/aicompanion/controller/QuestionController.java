package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.dto.QuestionDTO;
import com.aicompanion.model.dto.SubmitAnswerDTO;
import com.aicompanion.model.vo.QuestionVO;
import com.aicompanion.model.vo.SubmitResultVO;
import com.aicompanion.service.QuestionService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.extern.slf4j.Slf4j;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@Tag(name = "题目管理", description = "题目相关接口")
@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    @Operation(summary = "新增题目（教师/管理员）")
    @PostMapping("/sections/{sectionId}/questions")
    public Result<QuestionVO> createQuestion(@PathVariable Long sectionId, @Valid @RequestBody QuestionDTO dto) {
        SecurityUtils.checkAdminOrTeacher();
        dto.setSectionId(sectionId);
        QuestionVO questionVO = questionService.createQuestion(dto);
        return Result.success("新增成功", questionVO);
    }

    @Operation(summary = "更新题目（教师/管理员）")
    @PutMapping("/questions/{id}")
    public Result<QuestionVO> updateQuestion(@PathVariable Long id, @Valid @RequestBody QuestionDTO dto) {
        SecurityUtils.checkAdminOrTeacher();
        QuestionVO questionVO = questionService.updateQuestion(id, dto);
        return Result.success("更新成功", questionVO);
    }

    @Operation(summary = "删除题目（教师/管理员）")
    @DeleteMapping("/questions/{id}")
    public Result<Void> deleteQuestion(@PathVariable Long id) {
        SecurityUtils.checkAdminOrTeacher();
        questionService.deleteQuestion(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取章节题目列表（不含答案）")
    @GetMapping("/sections/{sectionId}/questions")
    public Result<List<QuestionVO>> getQuestionsBySectionId(@PathVariable Long sectionId) {
        log.info("查询章节题目: sectionId={}", sectionId);
        List<QuestionVO> list = questionService.getQuestionsBySectionId(sectionId, false);
        log.info("查询章节题目结果: sectionId={}, 题目数={}", sectionId, list.size());
        return Result.success(list);
    }

    @Operation(summary = "获取章节题目详情（含答案，教师/管理员）")
    @GetMapping("/sections/{sectionId}/questions/details")
    public Result<List<QuestionVO>> getQuestionsWithAnswers(@PathVariable Long sectionId) {
        SecurityUtils.checkAdminOrTeacher();
        List<QuestionVO> list = questionService.getQuestionsBySectionId(sectionId, true);
        return Result.success(list);
    }

    @Operation(summary = "提交答案")
    @PostMapping("/submit-answers")
    public Result<SubmitResultVO> submitAnswers(@Valid @RequestBody SubmitAnswerDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        SubmitResultVO result = questionService.submitAnswers(userId, dto);
        return Result.success("提交成功", result);
    }
}

package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.vo.CourseProgressVO;
import com.aicompanion.service.CourseProgressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "课程进度", description = "课程进度相关接口")
@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
public class CourseProgressController {

    private final CourseProgressService courseProgressService;

    @Operation(summary = "获取课程学习进度")
    @GetMapping("/progress/{courseId}")
    public Result<CourseProgressVO> getCourseProgress(@PathVariable Long courseId) {
        Long userId = SecurityUtils.getCurrentUserId();
        CourseProgressVO progressVO = courseProgressService.getCourseProgress(userId, courseId);
        return Result.success(progressVO);
    }
}

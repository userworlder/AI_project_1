package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.dto.CourseSectionDTO;
import com.aicompanion.model.vo.CourseSectionVO;
import com.aicompanion.service.CourseSectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "课程章节管理", description = "课程章节相关接口")
@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
public class CourseSectionController {

    private final CourseSectionService courseSectionService;

    @Operation(summary = "新增章节（教师/管理员）")
    @PostMapping("/{courseId}/sections")
    public Result<CourseSectionVO> createSection(@PathVariable Long courseId, @Valid @RequestBody CourseSectionDTO dto) {
        SecurityUtils.checkAdminOrTeacher();
        dto.setCourseId(courseId);
        CourseSectionVO sectionVO = courseSectionService.createSection(dto);
        return Result.success("新增成功", sectionVO);
    }

    @Operation(summary = "更新章节（教师/管理员）")
    @PutMapping("/sections/{id}")
    public Result<CourseSectionVO> updateSection(@PathVariable Long id, @Valid @RequestBody CourseSectionDTO dto) {
        SecurityUtils.checkAdminOrTeacher();
        CourseSectionVO sectionVO = courseSectionService.updateSection(id, dto);
        return Result.success("更新成功", sectionVO);
    }

    @Operation(summary = "删除章节（教师/管理员）")
    @DeleteMapping("/sections/{id}")
    public Result<Void> deleteSection(@PathVariable Long id) {
        SecurityUtils.checkAdminOrTeacher();
        courseSectionService.deleteSection(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取课程章节列表（含学习进度）")
    @GetMapping("/{courseId}/sections")
    public Result<List<CourseSectionVO>> getSectionsByCourseId(@PathVariable Long courseId) {
        Long userId = SecurityUtils.getCurrentUserId();
        List<CourseSectionVO> list = courseSectionService.getSectionsByCourseId(courseId, userId);
        return Result.success(list);
    }
}

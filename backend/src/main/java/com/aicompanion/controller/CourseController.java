package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.dto.CourseDTO;
import com.aicompanion.model.vo.CourseVO;
import com.aicompanion.service.CourseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@Tag(name = "课程管理", description = "课程相关接口")
@RestController
@RequestMapping("/api/courses")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;

    @Operation(summary = "新增课程（教师/管理员）")
    @PostMapping
    public Result<CourseVO> createCourse(@Valid @RequestBody CourseDTO courseDTO) {
        SecurityUtils.checkAdminOrTeacher();
        CourseVO courseVO = courseService.createCourse(courseDTO);
        return Result.success("新增成功", courseVO);
    }

    @Operation(summary = "更新课程（教师/管理员）")
    @PutMapping("/{id}")
    public Result<CourseVO> updateCourse(@PathVariable Long id, @Valid @RequestBody CourseDTO courseDTO) {
        SecurityUtils.checkAdminOrTeacher();
        CourseVO courseVO = courseService.updateCourse(id, courseDTO);
        return Result.success("更新成功", courseVO);
    }

    @Operation(summary = "删除课程（教师/管理员）")
    @DeleteMapping("/{id}")
    public Result<Void> deleteCourse(@PathVariable Long id) {
        SecurityUtils.checkAdminOrTeacher();
        courseService.deleteCourse(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取课程详情")
    @GetMapping("/{id}")
    public Result<CourseVO> getCourseById(@PathVariable Long id) {
        try {
            CourseVO courseVO = courseService.getCourseById(id);
            return Result.success(courseVO);
        } catch (Exception e) {
            log.error("获取课程详情失败 id={}: {}", id, e.getMessage(), e);
            return Result.error("获取课程详情失败: " + e.getMessage());
        }
    }

    @Operation(summary = "分页查询课程列表")
    @GetMapping
    public Result<PageResult<CourseVO>> pageCourses(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long skillId) {
        try {
            PageResult<CourseVO> pageResult = courseService.pageCourses(current, size, keyword, skillId);
            return Result.success(pageResult);
        } catch (Exception e) {
            log.error("查询课程列表失败: {}", e.getMessage(), e);
            return Result.error("查询课程列表失败: " + e.getMessage());
        }
    }
}

package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.ResumeDTO;
import com.aicompanion.model.vo.ResumeVO;
import com.aicompanion.service.ResumeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "简历评估管理", description = "简历评估相关接口")
@RestController
@RequestMapping("/api/resumes")
@RequiredArgsConstructor
public class ResumeController {

    private final ResumeService resumeService;

    @Operation(summary = "创建简历评估记录")
    @PostMapping
    public Result<ResumeVO> createResume(@Valid @RequestBody ResumeDTO resumeDTO) {
        ResumeVO resumeVO = resumeService.createResume(resumeDTO);
        return Result.success("创建成功", resumeVO);
    }

    @Operation(summary = "更新简历评估记录")
    @PutMapping("/{id}")
    public Result<ResumeVO> updateResume(@PathVariable Long id,
                                          @Valid @RequestBody ResumeDTO resumeDTO) {
        ResumeVO resumeVO = resumeService.updateResume(id, resumeDTO);
        return Result.success("更新成功", resumeVO);
    }

    @Operation(summary = "删除简历评估记录")
    @DeleteMapping("/{id}")
    public Result<Void> deleteResume(@PathVariable Long id) {
        resumeService.deleteResume(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取简历评估详情")
    @GetMapping("/{id}")
    public Result<ResumeVO> getResumeById(@PathVariable Long id) {
        ResumeVO resumeVO = resumeService.getResumeById(id);
        return Result.success(resumeVO);
    }

    @Operation(summary = "获取用户的所有简历评估")
    @GetMapping("/user/{userId}")
    public Result<List<ResumeVO>> getResumesByUserId(@PathVariable Long userId) {
        List<ResumeVO> list = resumeService.getResumesByUserId(userId);
        return Result.success(list);
    }

    @Operation(summary = "分页查询简历评估")
    @GetMapping("/list")
    public Result<PageResult<ResumeVO>> getResumes(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long userId) {
        PageResult<ResumeVO> pageResult = resumeService.getResumes(current, size, userId);
        return Result.success(pageResult);
    }
}

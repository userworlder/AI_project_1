package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.StudyRecordDTO;
import com.aicompanion.model.vo.StudyRecordVO;
import com.aicompanion.service.StudyRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "学习记录管理", description = "学习记录相关接口")
@RestController
@RequestMapping("/api/study-records")
@RequiredArgsConstructor
public class StudyRecordController {

    private final StudyRecordService studyRecordService;

    @Operation(summary = "新增学习记录")
    @PostMapping
    public Result<StudyRecordVO> createStudyRecord(@Valid @RequestBody StudyRecordDTO studyRecordDTO) {
        StudyRecordVO studyRecordVO = studyRecordService.createStudyRecord(studyRecordDTO);
        return Result.success("新增成功", studyRecordVO);
    }

    @Operation(summary = "更新学习记录")
    @PutMapping("/{id}")
    public Result<StudyRecordVO> updateStudyRecord(@PathVariable Long id, 
                                                    @Valid @RequestBody StudyRecordDTO studyRecordDTO) {
        StudyRecordVO studyRecordVO = studyRecordService.updateStudyRecord(id, studyRecordDTO);
        return Result.success("更新成功", studyRecordVO);
    }

    @Operation(summary = "删除学习记录")
    @DeleteMapping("/{id}")
    public Result<Void> deleteStudyRecord(@PathVariable Long id) {
        studyRecordService.deleteStudyRecord(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取学习记录详情")
    @GetMapping("/{id}")
    public Result<StudyRecordVO> getStudyRecordById(@PathVariable Long id) {
        StudyRecordVO studyRecordVO = studyRecordService.getStudyRecordById(id);
        return Result.success(studyRecordVO);
    }

    @Operation(summary = "分页查询学习记录")
    @GetMapping("/list")
    public Result<PageResult<StudyRecordVO>> getStudyRecords(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long userId) {
        PageResult<StudyRecordVO> pageResult = studyRecordService.getStudyRecords(current, size, userId);
        return Result.success(pageResult);
    }
}

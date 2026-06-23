package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.SkillDTO;
import com.aicompanion.model.vo.SkillVO;
import com.aicompanion.service.SkillService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "技能管理", description = "技能树相关接口")
@RestController
@RequestMapping("/api/skills")
@RequiredArgsConstructor
public class SkillController {

    private final SkillService skillService;

    @Operation(summary = "新增技能")
    @PostMapping
    public Result<SkillVO> createSkill(@Valid @RequestBody SkillDTO skillDTO) {
        SkillVO skillVO = skillService.createSkill(skillDTO);
        return Result.success("新增成功", skillVO);
    }

    @Operation(summary = "更新技能")
    @PutMapping("/{id}")
    public Result<SkillVO> updateSkill(@PathVariable Long id, @Valid @RequestBody SkillDTO skillDTO) {
        SkillVO skillVO = skillService.updateSkill(id, skillDTO);
        return Result.success("更新成功", skillVO);
    }

    @Operation(summary = "删除技能")
    @DeleteMapping("/{id}")
    public Result<Void> deleteSkill(@PathVariable Long id) {
        skillService.deleteSkill(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取技能详情")
    @GetMapping("/{id}")
    public Result<SkillVO> getSkillById(@PathVariable Long id) {
        SkillVO skillVO = skillService.getSkillById(id);
        return Result.success(skillVO);
    }

    @Operation(summary = "分页查询技能列表")
    @GetMapping
    public Result<PageResult<SkillVO>> getSkills(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        PageResult<SkillVO> pageResult = skillService.getSkills(current, size, keyword);
        return Result.success(pageResult);
    }

    @Operation(summary = "获取技能树（全量）")
    @GetMapping("/tree")
    public Result<List<SkillVO>> getSkillTree(@RequestParam(required = false) String category) {
        List<SkillVO> list;
        if (category != null && !category.trim().isEmpty()) {
            list = skillService.getSkillsByCategory(category);
        } else {
            list = skillService.getAllSkills();
        }
        return Result.success(list);
    }
}

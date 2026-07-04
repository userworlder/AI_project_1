package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.dto.SkillTreeDTO;
import com.aicompanion.model.vo.SkillTreeVO;
import com.aicompanion.service.SkillTreeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 技能树管理控制器
 * 提供技能树的增、删、查、分页及子节点查询接口
 */
@Tag(name = "技能树管理", description = "技能树（SkillTree）相关接口")
@RestController
@RequestMapping("/api/skill-trees")
@RequiredArgsConstructor
public class SkillTreeController {

    private final SkillTreeService skillTreeService;

    @Operation(summary = "新增技能节点（教师/管理员）")
    @PostMapping
    public Result<SkillTreeVO> createSkill(@Valid @RequestBody SkillTreeDTO skillTreeDTO) {
        SecurityUtils.checkAdminOrTeacher();
        SkillTreeVO skillTreeVO = skillTreeService.createSkill(skillTreeDTO);
        return Result.success("新增成功", skillTreeVO);
    }

    @Operation(summary = "逻辑删除技能节点（教师/管理员）")
    @DeleteMapping("/{id}")
    public Result<Void> deleteById(@PathVariable Long id) {
        SecurityUtils.checkAdminOrTeacher();
        skillTreeService.deleteById(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "根据 ID 查询技能节点")
    @GetMapping("/{id}")
    public Result<SkillTreeVO> getById(@PathVariable Long id) {
        SkillTreeVO skillTreeVO = skillTreeService.getById(id);
        return Result.success(skillTreeVO);
    }

    @Operation(summary = "分页查询技能列表（支持按分类筛选）")
    @GetMapping
    public Result<PageResult<SkillTreeVO>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String category) {
        PageResult<SkillTreeVO> pageResult = skillTreeService.page(current, size, category);
        return Result.success(pageResult);
    }

    @Operation(summary = "根据父 ID 查询子技能列表")
    @GetMapping("/children/{parentId}")
    public Result<List<SkillTreeVO>> getByParentId(@PathVariable Long parentId) {
        List<SkillTreeVO> list = skillTreeService.getByParentId(parentId);
        return Result.success(list);
    }
}

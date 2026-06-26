package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.AIConfigDTO;
import com.aicompanion.model.vo.AIConfigVO;
import com.aicompanion.service.AIConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "AI配置管理", description = "AI模型配置相关接口（仅管理员）")
@RestController
@RequestMapping("/api/ai/configs")
@RequiredArgsConstructor
public class AIConfigController {

    private final AIConfigService aiConfigService;

    @Operation(summary = "新增AI配置")
    @PostMapping
    public Result<AIConfigVO> createAIConfig(@RequestBody AIConfigDTO aiConfigDTO) {
        AIConfigVO aiConfigVO = aiConfigService.createAIConfig(aiConfigDTO);
        return Result.success("新增成功", aiConfigVO);
    }

    @Operation(summary = "更新AI配置")
    @PutMapping("/{id}")
    public Result<AIConfigVO> updateAIConfig(@PathVariable Long id, @RequestBody AIConfigDTO aiConfigDTO) {
        AIConfigVO aiConfigVO = aiConfigService.updateAIConfig(id, aiConfigDTO);
        return Result.success("更新成功", aiConfigVO);
    }

    @Operation(summary = "删除AI配置")
    @DeleteMapping("/{id}")
    public Result<Void> deleteAIConfig(@PathVariable Long id) {
        aiConfigService.deleteAIConfig(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取AI配置详情")
    @GetMapping("/{id}")
    public Result<AIConfigVO> getAIConfigById(@PathVariable Long id) {
        AIConfigVO aiConfigVO = aiConfigService.getAIConfigById(id);
        return Result.success(aiConfigVO);
    }

    @Operation(summary = "分页查询AI配置列表")
    @GetMapping
    public Result<PageResult<AIConfigVO>> getAIConfigs(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        PageResult<AIConfigVO> pageResult = aiConfigService.getAIConfigs(current, size, keyword);
        return Result.success(pageResult);
    }

    @Operation(summary = "获取AI统计信息")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getAiStats() {
        Map<String, Object> stats = aiConfigService.getAiStats();
        return Result.success(stats);
    }

    @Operation(summary = "获取AI统计信息（兼容路径）")
    @GetMapping("/../stats")
    public Result<Map<String, Object>> getAiStatsAlt() {
        return getAiStats();
    }
}

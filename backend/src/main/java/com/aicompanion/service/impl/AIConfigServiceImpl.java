package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.mapper.AIConfigMapper;
import com.aicompanion.model.dto.AIConfigDTO;
import com.aicompanion.model.entity.AIConfig;
import com.aicompanion.model.vo.AIConfigVO;
import com.aicompanion.service.AIConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AIConfigServiceImpl implements AIConfigService {

    private final AIConfigMapper aiConfigMapper;

    @Override
    public AIConfigVO createAIConfig(AIConfigDTO aiConfigDTO) {
        AIConfig aiConfig = new AIConfig();
        BeanUtils.copyProperties(aiConfigDTO, aiConfig);
        if (aiConfig.getEnabled() == null) {
            aiConfig.setEnabled(true);
        }
        aiConfigMapper.insert(aiConfig);
        return convertToVO(aiConfig);
    }

    @Override
    public AIConfigVO updateAIConfig(Long id, AIConfigDTO aiConfigDTO) {
        AIConfig aiConfig = aiConfigMapper.selectById(id);
        if (aiConfig == null) {
            throw new BusinessException("AI配置不存在");
        }
        BeanUtils.copyProperties(aiConfigDTO, aiConfig);
        aiConfigMapper.updateById(aiConfig);
        return convertToVO(aiConfig);
    }

    @Override
    public void deleteAIConfig(Long id) {
        AIConfig aiConfig = aiConfigMapper.selectById(id);
        if (aiConfig == null) {
            throw new BusinessException("AI配置不存在");
        }
        aiConfigMapper.deleteById(id);
    }

    @Override
    public AIConfigVO getAIConfigById(Long id) {
        AIConfig aiConfig = aiConfigMapper.selectById(id);
        if (aiConfig == null) {
            throw new BusinessException("AI配置不存在");
        }
        return convertToVO(aiConfig);
    }

    @Override
    public PageResult<AIConfigVO> getAIConfigs(Integer current, Integer size, String keyword) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<AIConfig> page = new Page<>(current, size);
        LambdaQueryWrapper<AIConfig> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(AIConfig::getName, keyword);
        }

        wrapper.orderByDesc(AIConfig::getCreateTime);
        Page<AIConfig> configPage = aiConfigMapper.selectPage(page, wrapper);

        List<AIConfigVO> voList = configPage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                configPage.getTotal(),
                configPage.getCurrent(),
                configPage.getSize(),
                voList
        );
    }

    @Override
    public Map<String, Object> getAiStats() {
        Map<String, Object> stats = new HashMap<>();
        long totalConfigs = aiConfigMapper.selectCount(null);
        long enabledCount = aiConfigMapper.selectCount(
                new LambdaQueryWrapper<AIConfig>().eq(AIConfig::getEnabled, true));

        stats.put("totalRequests", totalConfigs * 100);  // 模拟数据
        stats.put("successRate", 98.5);
        stats.put("avgResponseTime", 320);
        stats.put("todayRequests", totalConfigs * 10);
        return stats;
    }

    private AIConfigVO convertToVO(AIConfig aiConfig) {
        AIConfigVO vo = new AIConfigVO();
        BeanUtils.copyProperties(aiConfig, vo);
        return vo;
    }
}

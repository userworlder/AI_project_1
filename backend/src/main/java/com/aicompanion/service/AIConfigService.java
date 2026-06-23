package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.AIConfigDTO;
import com.aicompanion.model.vo.AIConfigVO;
import com.aicompanion.model.vo.DashboardStatsVO;

import java.util.Map;

public interface AIConfigService {

    AIConfigVO createAIConfig(AIConfigDTO aiConfigDTO);

    AIConfigVO updateAIConfig(Long id, AIConfigDTO aiConfigDTO);

    void deleteAIConfig(Long id);

    AIConfigVO getAIConfigById(Long id);

    PageResult<AIConfigVO> getAIConfigs(Integer current, Integer size, String keyword);

    Map<String, Object> getAiStats();
}

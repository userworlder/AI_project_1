package com.aicompanion.mapper;

import com.aicompanion.model.entity.AiChatHistory;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * AI 聊天历史 Mapper
 */
@Mapper
public interface AiChatHistoryMapper extends BaseMapper<AiChatHistory> {
}

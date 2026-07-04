package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.ResumeDTO;
import com.aicompanion.model.vo.ResumeVO;

import java.util.List;

public interface ResumeService {

    ResumeVO createResume(ResumeDTO resumeDTO);

    ResumeVO updateResume(Long id, ResumeDTO resumeDTO);

    void deleteResume(Long id);

    ResumeVO getResumeById(Long id);

    List<ResumeVO> getResumesByUserId(Long userId);

    PageResult<ResumeVO> getResumes(Integer current, Integer size, Long userId);

    /**
     * AI 评估简历：调用 AI 分析简历内容，保存评估结果并返回
     */
    ResumeVO evaluateResume(ResumeDTO resumeDTO);
}

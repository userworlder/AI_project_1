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
}

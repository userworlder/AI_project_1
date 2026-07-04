package com.aicompanion.service;

import com.aicompanion.model.dto.CourseSectionDTO;
import com.aicompanion.model.vo.CourseSectionVO;

import java.util.List;

public interface CourseSectionService {

    CourseSectionVO createSection(CourseSectionDTO courseSectionDTO);

    CourseSectionVO updateSection(Long id, CourseSectionDTO courseSectionDTO);

    void deleteSection(Long id);

    List<CourseSectionVO> getSectionsByCourseId(Long courseId, Long userId);
}

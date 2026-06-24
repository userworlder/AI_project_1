package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.StudyRecordDTO;
import com.aicompanion.model.vo.StudyRecordVO;

public interface StudyRecordService {

    StudyRecordVO createStudyRecord(StudyRecordDTO studyRecordDTO);

    StudyRecordVO updateStudyRecord(Long id, StudyRecordDTO studyRecordDTO);

    void deleteStudyRecord(Long id);

    StudyRecordVO getStudyRecordById(Long id);

    PageResult<StudyRecordVO> getStudyRecords(Integer current, Integer size, Long userId);
}

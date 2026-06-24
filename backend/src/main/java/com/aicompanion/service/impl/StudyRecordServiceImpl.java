package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.mapper.StudyRecordMapper;
import com.aicompanion.model.dto.StudyRecordDTO;
import com.aicompanion.model.entity.StudyRecord;
import com.aicompanion.model.vo.StudyRecordVO;
import com.aicompanion.service.StudyRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class StudyRecordServiceImpl implements StudyRecordService {

    private final StudyRecordMapper studyRecordMapper;

    @Override
    public StudyRecordVO createStudyRecord(StudyRecordDTO studyRecordDTO) {
        StudyRecord studyRecord = new StudyRecord();
        BeanUtils.copyProperties(studyRecordDTO, studyRecord);
        
        // 如果状态为空，默认为1（进行中）
        if (studyRecord.getStatus() == null) {
            studyRecord.setStatus(1);
        }
        
        studyRecordMapper.insert(studyRecord);
        
        return convertToVO(studyRecord);
    }

    @Override
    public StudyRecordVO updateStudyRecord(Long id, StudyRecordDTO studyRecordDTO) {
        StudyRecord studyRecord = studyRecordMapper.selectById(id);
        if (studyRecord == null) {
            throw new BusinessException("学习记录不存在");
        }

        BeanUtils.copyProperties(studyRecordDTO, studyRecord);
        studyRecordMapper.updateById(studyRecord);

        return convertToVO(studyRecord);
    }

    @Override
    public void deleteStudyRecord(Long id) {
        StudyRecord studyRecord = studyRecordMapper.selectById(id);
        if (studyRecord == null) {
            throw new BusinessException("学习记录不存在");
        }
        studyRecordMapper.deleteById(id);
    }

    @Override
    public StudyRecordVO getStudyRecordById(Long id) {
        StudyRecord studyRecord = studyRecordMapper.selectById(id);
        if (studyRecord == null) {
            throw new BusinessException("学习记录不存在");
        }
        return convertToVO(studyRecord);
    }

    @Override
    public PageResult<StudyRecordVO> getStudyRecords(Integer current, Integer size, Long userId) {
        if (current == null || current < 1) {
            current = 1;
        }
        if (size == null || size < 1) {
            size = 10;
        }

        Page<StudyRecord> page = new Page<>(current, size);
        LambdaQueryWrapper<StudyRecord> wrapper = new LambdaQueryWrapper<>();

        if (userId != null) {
            wrapper.eq(StudyRecord::getUserId, userId);
        }

        wrapper.orderByDesc(StudyRecord::getCreateTime);
        
        Page<StudyRecord> studyRecordPage = studyRecordMapper.selectPage(page, wrapper);
        
        List<StudyRecordVO> voList = studyRecordPage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                studyRecordPage.getTotal(),
                studyRecordPage.getCurrent(),
                studyRecordPage.getSize(),
                voList
        );
    }

    private StudyRecordVO convertToVO(StudyRecord studyRecord) {
        StudyRecordVO vo = new StudyRecordVO();
        BeanUtils.copyProperties(studyRecord, vo);
        return vo;
    }
}

package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.ResumeMapper;
import com.aicompanion.model.dto.ResumeDTO;
import com.aicompanion.model.entity.Resume;
import com.aicompanion.model.vo.ResumeVO;
import com.aicompanion.service.ResumeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ResumeServiceImpl implements ResumeService {

    private final ResumeMapper resumeMapper;

    @Override
    public ResumeVO createResume(ResumeDTO resumeDTO) {
        // 学生只能为自己创建简历评估
        if (!SecurityUtils.isAdminOrTeacher()) {
            resumeDTO.setUserId(SecurityUtils.getCurrentUserId());
        }

        Resume resume = new Resume();
        BeanUtils.copyProperties(resumeDTO, resume);
        if (resume.getStatus() == null) {
            resume.setStatus("completed");
        }
        if (resume.getTitle() == null || resume.getTitle().trim().isEmpty()) {
            resume.setTitle("未命名简历");
        }
        resumeMapper.insert(resume);
        log.info("创建简历评估记录: userId={}, title={}", resume.getUserId(), resume.getTitle());
        return convertToVO(resume);
    }

    @Override
    public ResumeVO updateResume(Long id, ResumeDTO resumeDTO) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属
        SecurityUtils.checkAccess(resume.getUserId());
        // 学生修改时不能篡改 userId
        if (SecurityUtils.isStudent()) {
            resumeDTO.setUserId(resume.getUserId());
        }

        BeanUtils.copyProperties(resumeDTO, resume);
        resumeMapper.updateById(resume);
        return convertToVO(resume);
    }

    @Override
    public void deleteResume(Long id) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属
        SecurityUtils.checkAccess(resume.getUserId());
        resumeMapper.deleteById(id);
    }

    @Override
    public ResumeVO getResumeById(Long id) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属：学生只能查看自己的简历
        SecurityUtils.checkAccess(resume.getUserId());
        return convertToVO(resume);
    }

    @Override
    public List<ResumeVO> getResumesByUserId(Long userId) {
        // 学生只能查看自己的简历列表
        if (SecurityUtils.isStudent()) {
            userId = SecurityUtils.getCurrentUserId();
        }

        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Resume::getUserId, userId);
        wrapper.orderByDesc(Resume::getCreateTime);
        return resumeMapper.selectList(wrapper).stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
    }

    @Override
    public PageResult<ResumeVO> getResumes(Integer current, Integer size, Long userId) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<Resume> page = new Page<>(current, size);
        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<>();

        // 学生只能查询自己的简历评估
        if (SecurityUtils.isStudent()) {
            userId = SecurityUtils.getCurrentUserId();
        }

        if (userId != null) {
            wrapper.eq(Resume::getUserId, userId);
        }

        wrapper.orderByDesc(Resume::getCreateTime);
        Page<Resume> resumePage = resumeMapper.selectPage(page, wrapper);

        List<ResumeVO> voList = resumePage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                resumePage.getTotal(),
                resumePage.getCurrent(),
                resumePage.getSize(),
                voList
        );
    }

    private ResumeVO convertToVO(Resume resume) {
        ResumeVO vo = new ResumeVO();
        BeanUtils.copyProperties(resume, vo);
        return vo;
    }
}

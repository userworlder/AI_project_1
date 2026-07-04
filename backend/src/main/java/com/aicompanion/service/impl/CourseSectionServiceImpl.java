package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.mapper.CourseSectionMapper;
import com.aicompanion.mapper.QuestionMapper;
import com.aicompanion.mapper.UserCourseProgressMapper;
import com.aicompanion.model.dto.CourseSectionDTO;
import com.aicompanion.model.entity.CourseSection;
import com.aicompanion.model.entity.UserCourseProgress;
import com.aicompanion.model.vo.CourseSectionVO;
import com.aicompanion.service.CourseSectionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CourseSectionServiceImpl implements CourseSectionService {

    private final CourseSectionMapper courseSectionMapper;
    private final UserCourseProgressMapper userCourseProgressMapper;
    private final QuestionMapper questionMapper;

    @Override
    public CourseSectionVO createSection(CourseSectionDTO courseSectionDTO) {
        CourseSection courseSection = new CourseSection();
        BeanUtils.copyProperties(courseSectionDTO, courseSection);
        courseSectionMapper.insert(courseSection);
        return convertToVO(courseSection);
    }

    @Override
    public CourseSectionVO updateSection(Long id, CourseSectionDTO courseSectionDTO) {
        CourseSection courseSection = courseSectionMapper.selectById(id);
        if (courseSection == null) {
            throw new BusinessException("课程章节不存在");
        }
        BeanUtils.copyProperties(courseSectionDTO, courseSection);
        courseSectionMapper.updateById(courseSection);
        return convertToVO(courseSection);
    }

    @Override
    public void deleteSection(Long id) {
        CourseSection courseSection = courseSectionMapper.selectById(id);
        if (courseSection == null) {
            throw new BusinessException("课程章节不存在");
        }
        courseSectionMapper.deleteById(id);
    }

    @Override
    public List<CourseSectionVO> getSectionsByCourseId(Long courseId, Long userId) {
        LambdaQueryWrapper<CourseSection> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CourseSection::getCourseId, courseId);
        wrapper.orderByAsc(CourseSection::getOrderIndex);

        List<CourseSection> sections = courseSectionMapper.selectList(wrapper);

        // 查询每个章节的题目数量
        List<Long> sectionIds = sections.stream().map(CourseSection::getId).collect(Collectors.toList());
        Map<Long, Integer> questionCountMap = Map.of(); // 空兜底
        if (!sectionIds.isEmpty()) {
            LambdaQueryWrapper<com.aicompanion.model.entity.Question> qWrapper = new LambdaQueryWrapper<>();
            qWrapper.in(com.aicompanion.model.entity.Question::getSectionId, sectionIds);
            List<com.aicompanion.model.entity.Question> allQuestions = questionMapper.selectList(qWrapper);
            questionCountMap = allQuestions.stream()
                    .collect(Collectors.groupingBy(
                            com.aicompanion.model.entity.Question::getSectionId,
                            Collectors.summingInt(q -> 1)
                    ));
        }

        // 查询用户进度状态
        Map<Long, Integer> progressMap = Map.of();
        if (userId != null && !sectionIds.isEmpty()) {
            LambdaQueryWrapper<UserCourseProgress> progressWrapper = new LambdaQueryWrapper<>();
            progressWrapper.eq(UserCourseProgress::getUserId, userId);
            progressWrapper.eq(UserCourseProgress::getCourseId, courseId);
            progressWrapper.in(UserCourseProgress::getSectionId, sectionIds);

            List<UserCourseProgress> progressList = userCourseProgressMapper.selectList(progressWrapper);
            progressMap = progressList.stream()
                    .collect(Collectors.toMap(
                            UserCourseProgress::getSectionId,
                            p -> p.getStatus() != null ? p.getStatus() : 0,
                            (a, b) -> b // 如果有重复，取最后一个
                    ));
        }

        final Map<Long, Integer> fProgressMap = progressMap;
        final Map<Long, Integer> fQuestionCountMap = questionCountMap;

        return sections.stream().map(section -> {
            CourseSectionVO vo = convertToVO(section);
            vo.setStatus(fProgressMap.getOrDefault(section.getId(), 0));
            vo.setQuestionCount(fQuestionCountMap.getOrDefault(section.getId(), 0));
            return vo;
        }).collect(Collectors.toList());
    }

    private CourseSectionVO convertToVO(CourseSection courseSection) {
        CourseSectionVO vo = new CourseSectionVO();
        BeanUtils.copyProperties(courseSection, vo);
        return vo;
    }
}

package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.aicompanion.mapper.CourseSectionMapper;
import com.aicompanion.mapper.UserCourseProgressMapper;
import com.aicompanion.model.entity.CourseSection;
import com.aicompanion.model.entity.UserCourseProgress;
import com.aicompanion.model.vo.CourseProgressVO;
import com.aicompanion.service.CourseProgressService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CourseProgressServiceImpl implements CourseProgressService {

    private final UserCourseProgressMapper userCourseProgressMapper;
    private final CourseSectionMapper courseSectionMapper;

    @Override
    public CourseProgressVO getCourseProgress(Long userId, Long courseId) {
        // Count total sections for the course
        LambdaQueryWrapper<CourseSection> sectionWrapper = new LambdaQueryWrapper<>();
        sectionWrapper.eq(CourseSection::getCourseId, courseId);
        Long totalSections = courseSectionMapper.selectCount(sectionWrapper);

        // Count completed sections for the user
        LambdaQueryWrapper<UserCourseProgress> progressWrapper = new LambdaQueryWrapper<>();
        progressWrapper.eq(UserCourseProgress::getUserId, userId);
        progressWrapper.eq(UserCourseProgress::getCourseId, courseId);
        progressWrapper.eq(UserCourseProgress::getStatus, 2); // completed
        Long completedSections = userCourseProgressMapper.selectCount(progressWrapper);

        // Calculate progress percentage
        double progress = totalSections > 0 ? (double) completedSections / totalSections * 100 : 0.0;

        CourseProgressVO vo = new CourseProgressVO();
        vo.setTotalSections(totalSections);
        vo.setCompletedSections(completedSections);
        vo.setProgress(progress);

        return vo;
    }
}

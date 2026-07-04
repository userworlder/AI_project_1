package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.CourseMapper;
import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.mapper.UserMapper;
import com.aicompanion.model.dto.CourseDTO;
import com.aicompanion.model.entity.Course;
import com.aicompanion.model.entity.Skill;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.CourseVO;
import com.aicompanion.service.CourseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseMapper courseMapper;
    private final UserMapper userMapper;
    private final SkillMapper skillMapper;

    @Override
    public CourseVO createCourse(CourseDTO courseDTO) {
        Course course = new Course();
        BeanUtils.copyProperties(courseDTO, course);
        course.setTeacherId(SecurityUtils.getCurrentUserId());
        courseMapper.insert(course);
        return convertToVO(course);
    }

    @Override
    public CourseVO updateCourse(Long id, CourseDTO courseDTO) {
        Course course = courseMapper.selectById(id);
        if (course == null) {
            throw new BusinessException("课程不存在");
        }
        SecurityUtils.checkAccess(course.getTeacherId());
        BeanUtils.copyProperties(courseDTO, course);
        courseMapper.updateById(course);
        return convertToVO(course);
    }

    @Override
    public void deleteCourse(Long id) {
        Course course = courseMapper.selectById(id);
        if (course == null) {
            throw new BusinessException("课程不存在");
        }
        SecurityUtils.checkAccess(course.getTeacherId());
        courseMapper.deleteById(id);
    }

    @Override
    public CourseVO getCourseById(Long id) {
        Course course = courseMapper.selectById(id);
        if (course == null) {
            throw new BusinessException("课程不存在");
        }
        return convertToVO(course);
    }

    @Override
    public PageResult<CourseVO> pageCourses(Integer current, Integer size, String keyword, Long skillId) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<Course> page = new Page<>(current, size);
        LambdaQueryWrapper<Course> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(Course::getName, keyword);
        }
        if (skillId != null) {
            wrapper.eq(Course::getSkillId, skillId);
        }

        wrapper.orderByDesc(Course::getCreateTime);
        Page<Course> coursePage = courseMapper.selectPage(page, wrapper);

        List<CourseVO> voList = coursePage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                coursePage.getTotal(),
                coursePage.getCurrent(),
                coursePage.getSize(),
                voList
        );
    }

    private CourseVO convertToVO(Course course) {
        CourseVO vo = new CourseVO();
        BeanUtils.copyProperties(course, vo);
        // 填充教师名称
        if (course.getTeacherId() != null) {
            User teacher = userMapper.selectById(course.getTeacherId());
            if (teacher != null) {
                vo.setTeacherName(teacher.getNickname() != null ? teacher.getNickname() : teacher.getUsername());
            }
        }
        // 填充技能名称
        if (course.getSkillId() != null) {
            Skill skill = skillMapper.selectById(course.getSkillId());
            if (skill != null) {
                vo.setSkillName(skill.getName());
            }
        }
        return vo;
    }
}

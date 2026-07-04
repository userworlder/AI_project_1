package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.CourseDTO;
import com.aicompanion.model.vo.CourseVO;

public interface CourseService {

    CourseVO createCourse(CourseDTO courseDTO);

    CourseVO updateCourse(Long id, CourseDTO courseDTO);

    void deleteCourse(Long id);

    CourseVO getCourseById(Long id);

    PageResult<CourseVO> pageCourses(Integer current, Integer size, String keyword, Long skillId);
}

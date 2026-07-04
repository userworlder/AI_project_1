package com.aicompanion.service;

import com.aicompanion.model.vo.CourseProgressVO;

public interface CourseProgressService {

    CourseProgressVO getCourseProgress(Long userId, Long courseId);
}

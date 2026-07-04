import request from '@/utils/request'

export const getCourseList = (params) => {
  return request({
    url: '/courses',
    method: 'get',
    params
  })
}

export const getCourseById = (id) => {
  return request({
    url: `/courses/${id}`,
    method: 'get'
  })
}

export const createCourse = (data) => {
  return request({
    url: '/courses',
    method: 'post',
    data
  })
}

export const updateCourse = (id, data) => {
  return request({
    url: `/courses/${id}`,
    method: 'put',
    data
  })
}

export const deleteCourse = (id) => {
  return request({
    url: `/courses/${id}`,
    method: 'delete'
  })
}

export const getCourseSections = (courseId) => {
  return request({
    url: `/courses/${courseId}/sections`,
    method: 'get'
  })
}

export const createSection = (courseId, data) => {
  return request({
    url: `/courses/${courseId}/sections`,
    method: 'post',
    data
  })
}

export const updateSection = (id, data) => {
  return request({
    url: `/sections/${id}`,
    method: 'put',
    data
  })
}

export const deleteSection = (id) => {
  return request({
    url: `/sections/${id}`,
    method: 'delete'
  })
}

export const getSectionQuestions = (sectionId) => {
  return request({
    url: `/sections/${sectionId}/questions`,
    method: 'get'
  })
}

export const getSectionQuestionsDetail = (sectionId) => {
  return request({
    url: `/sections/${sectionId}/questions/detail`,
    method: 'get'
  })
}

export const createQuestion = (sectionId, data) => {
  return request({
    url: `/sections/${sectionId}/questions`,
    method: 'post',
    data
  })
}

export const updateQuestion = (id, data) => {
  return request({
    url: `/questions/${id}`,
    method: 'put',
    data
  })
}

export const deleteQuestion = (id) => {
  return request({
    url: `/questions/${id}`,
    method: 'delete'
  })
}

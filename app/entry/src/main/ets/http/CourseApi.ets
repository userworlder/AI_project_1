import { HttpClient } from '../common/HttpClient'
import type { CourseItem, CourseSectionItem, QuestionItem, SubmitAnswerRequest, SubmitResult, CourseProgress, PageResult } from '../model/Course'

/**
 * 课程学习相关 API
 */
export class CourseApi {
  /**
   * 获取课程列表
   * @param context 上下文
   * @param skillId 可选的技能 ID 过滤
   */
  static async getCourses(context: Context, skillId?: number): Promise<PageResult<CourseItem>> {
    let url = '/api/courses'
    if (skillId !== undefined) {
      url += `?skillId=${skillId}`
    }
    return HttpClient.get<PageResult<CourseItem>>(context, url)
  }

  /**
   * 根据 ID 获取课程详情
   * @param context 上下文
   * @param id 课程 ID
   */
  static async getCourseById(context: Context, id: number): Promise<CourseItem> {
    return HttpClient.get<CourseItem>(context, `/api/courses/${id}`)
  }

  /**
   * 获取课程章节列表
   * @param context 上下文
   * @param courseId 课程 ID
   */
  static async getSections(context: Context, courseId: number): Promise<CourseSectionItem[]> {
    return HttpClient.get<CourseSectionItem[]>(context, `/api/courses/${courseId}/sections`)
  }

  /**
   * 获取章节题目列表
   * @param context 上下文
   * @param sectionId 章节 ID
   */
  static async getQuestions(context: Context, sectionId: number): Promise<QuestionItem[]> {
    return HttpClient.get<QuestionItem[]>(context, `/api/courses/sections/${sectionId}/questions`)
  }

  /**
   * 提交答题答案
   * @param context 上下文
   * @param data 提交数据
   */
  static async submitAnswers(context: Context, data: SubmitAnswerRequest): Promise<SubmitResult> {
    return HttpClient.post<SubmitResult>(context, '/api/courses/submit-answers', data)
  }

  /**
   * 获取课程学习进度
   * @param context 上下文
   * @param courseId 课程 ID
   */
  static async getProgress(context: Context, courseId: number): Promise<CourseProgress> {
    return HttpClient.get<CourseProgress>(context, `/api/courses/progress/${courseId}`)
  }
}

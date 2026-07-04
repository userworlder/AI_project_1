/**
 * 课程、章节、题目相关数据模型
 */

export interface CourseItem {
  id: number
  name: string
  description: string
  skillId: number
  teacherId: number
  teacherName: string
  skillName: string
  difficultyLevel: number
  coverImage: string
  sortOrder: number
  status: number
  createTime: string
  updateTime: string
}

export interface CourseSectionItem {
  id: number
  courseId: number
  title: string
  description: string
  orderIndex: number
  progressStatus: number // 0-not started, 1-in progress, 2-completed
  questionCount: number
  createTime: string
}

export interface QuestionItem {
  id: number
  sectionId: number
  content: string
  type: string // 'choice' or 'true_false'
  options: string // JSON array string
  analysis: string
  orderIndex: number
}

export interface SubmitAnswerRequest {
  sectionId: number
  answers: AnswerItem[]
}

export interface AnswerItem {
  questionId: number
  answer: string
}

export interface SubmitResult {
  score: number
  totalQuestions: number
  correctCount: number
  sectionId: number
}

export interface CourseProgress {
  courseId: number
  totalSections: number
  completedSections: number
  score: number
}

export interface PageResult<T> {
  total: number
  current: number
  size: number
  records: T[]
}

/**
 * 简历评估数据模型
 */
export interface ResumeItem {
  id: number
  userId: number
  title: string
  content: string
  evaluation: string
  score: number
  strengths: string
  suggestions: string
  status: string
  createTime: string
  updateTime: string
}

export interface CreateResumeRequest {
  userId: number
  title: string
  content: string
  evaluation?: string
  score?: number
  strengths?: string
  suggestions?: string
  status?: string
}

/**
 * Dify 简历评估请求
 */
export interface ResumeDifyRequest {
  query: string
  response_mode: string
  user: string
  inputs: Record<string, string>
}

/**
 * Dify 简历评估响应
 */
export interface ResumeDifyResponse {
  answer: string
  message_id: string
  created_at: number
}

/**
 * Dify 评估结果解析结构（返回的 answer 中的 JSON 格式）
 */
export interface ResumeDifyResult {
  score: number
  summary: string
  strengths: string[]
  weaknesses: string[]
  suggestions: string[]
  improvedVersion: string
}

import { HttpClient } from '../common/HttpClient'
import type { ResumeItem, CreateResumeRequest } from '../model/Resume'

/**
 * 简历评估后端 API
 */
export class ResumeApi {
  /**
   * 创建简历评估记录
   */
  static async create(context: Context, data: CreateResumeRequest): Promise<ResumeItem> {
    return HttpClient.post<ResumeItem>(context, '/api/resumes', data)
  }

  /**
   * AI评估简历：发送到后端，由后端调用AI进行评估
   */
  static async evaluate(context: Context, data: CreateResumeRequest): Promise<ResumeItem> {
    return HttpClient.post<ResumeItem>(context, '/api/resumes/evaluate', data)
  }

  /**
   * 获取用户的所有简历评估列表
   */
  static async getByUser(context: Context, userId: number): Promise<ResumeItem[]> {
    return HttpClient.get<ResumeItem[]>(context, `/api/resumes/user/${userId}`)
  }

  /**
   * 获取简历评估详情
   */
  static async getById(context: Context, id: number): Promise<ResumeItem> {
    return HttpClient.get<ResumeItem>(context, `/api/resumes/${id}`)
  }

  /**
   * 删除简历评估记录
   */
  static async delete(context: Context, id: number): Promise<void> {
    await HttpClient.del<void>(context, `/api/resumes/${id}`)
  }
}

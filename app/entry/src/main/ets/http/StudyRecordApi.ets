import { HttpClient } from '../common/HttpClient'
import type { PageResult } from '../model/PageResult'
import type { StudyRecordItem, CreateStudyRecordRequest } from '../model/User'

/**
 * 学习记录相关 API
 */
export class StudyRecordApi {
  /**
   * 分页查询学习记录
   * @param context 上下文
   * @param current 当前页码
   * @param size 每页条数
   * @param userId 可选的用户 ID 过滤
   */
  static async getStudyRecords(
    context: Context,
    current: number,
    size: number,
    userId?: number
  ): Promise<PageResult<StudyRecordItem>> {
    let url = `/api/study-records/list?current=${current}&size=${size}`
    if (userId !== undefined) {
      url += `&userId=${userId}`
    }
    return HttpClient.get<PageResult<StudyRecordItem>>(context, url)
  }

  /**
   * 创建学习记录
   * @param context 上下文
   * @param data 学习记录数据
   */
  static async createStudyRecord(context: Context, data: CreateStudyRecordRequest): Promise<StudyRecordItem> {
    return HttpClient.post<StudyRecordItem>(context, '/api/study-records', data)
  }
}

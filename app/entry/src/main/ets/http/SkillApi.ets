import { HttpClient } from '../common/HttpClient'
import type { SkillItem } from '../model/Skill'

/**
 * 技能树相关 API
 */
export class SkillApi {
  /**
   * 获取技能树列表
   * @param context 上下文
   * @param category 可选的分类过滤
   */
  static async getSkillTree(context: Context, category?: string): Promise<SkillItem[]> {
    let url = '/api/skills/tree'
    if (category !== undefined && category.length > 0) {
      url += `?category=${encodeURIComponent(category)}`
    }
    return HttpClient.get<SkillItem[]>(context, url)
  }
}

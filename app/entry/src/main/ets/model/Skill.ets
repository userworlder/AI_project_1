/**
 * 技能数据模型
 */
export interface SkillItem {
  id: number
  name: string
  category: string
  level: number
  description: string
  createTime?: string
  updateTime?: string
}

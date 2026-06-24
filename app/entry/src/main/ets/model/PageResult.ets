/**
 * 通用分页结果模型
 */
export interface PageResult<T> {
  total: number
  current: number
  size: number
  records: T[]
}

/**
 * 日期格式化工具类
 */
export class DateUtil {
  /**
   * 将时间戳格式化为 "HH:mm" 格式
   * @param timestamp 时间戳（毫秒）
   * @returns 格式化后的时间字符串，如 "14:30"
   */
  static format(timestamp: number): string {
    const date = new Date(timestamp)
    const hours = date.getHours()
    const minutes = date.getMinutes()
    
    // 补零处理
    const hoursStr = hours < 10 ? `0${hours}` : `${hours}`
    const minutesStr = minutes < 10 ? `0${minutes}` : `${minutes}`
    
    return `${hoursStr}:${minutesStr}`
  }

  /**
   * 将时间戳格式化为更友好的显示格式
   * - 今天：显示 "HH:mm"
   * - 昨天：显示 "昨天 HH:mm"
   * - 其他：显示 "MM-dd HH:mm"
   * @param timestamp 时间戳（毫秒）
   * @returns 格式化后的时间字符串
   */
  static formatFriendly(timestamp: number): string {
    const now = new Date()
    const date = new Date(timestamp)
    
    // 获取今天的零点时间戳
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    // 获取昨天的零点时间戳
    const yesterdayStart = todayStart - 24 * 60 * 60 * 1000
    
    const hoursStr = date.getHours() < 10 ? `0${date.getHours()}` : `${date.getHours()}`
    const minutesStr = date.getMinutes() < 10 ? `0${date.getMinutes()}` : `${date.getMinutes()}`
    const timeStr = `${hoursStr}:${minutesStr}`
    
    if (timestamp >= todayStart) {
      // 今天
      return timeStr
    } else if (timestamp >= yesterdayStart) {
      // 昨天
      return `昨天 ${timeStr}`
    } else {
      // 其他日期
      const month = date.getMonth() + 1
      const day = date.getDate()
      const monthStr = month < 10 ? `0${month}` : `${month}`
      const dayStr = day < 10 ? `0${day}` : `${day}`
      return `${monthStr}-${dayStr} ${timeStr}`
    }
  }
}

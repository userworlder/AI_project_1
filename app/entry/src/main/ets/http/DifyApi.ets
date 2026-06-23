import http from '@ohos.net.http'
import { DifyResponse, DifyRequest } from '../model/ChatMessage'

/**
 * Dify API 接口类
 */
export class DifyApi {
  // Dify API 基地址（模拟器使用 10.0.2.2，真机请替换为电脑实际 IP）
  // 注意：请根据你的 Dify 服务实际端口修改，常见端口：80, 5001, 8080, 9000
  private static readonly BASE_URL: string = 'http://10.0.2.2:9000/v1'
  // Dify API Key（请替换为你的实际 API Key）
  private static readonly API_KEY: string = 'app-Q7NsNC2GoEa8PX8ecVr0FJe7'

  /**
   * 发送聊天消息到 Dify
   * @param query 用户问题
   * @param conversationId 会话 ID（首次为空字符串）
   * @returns Dify 响应数据
   */
  static async sendChatMessage(query: string, conversationId: string): Promise<DifyResponse> {
    const request = http.createHttp()
    const url = `${DifyApi.BASE_URL}/chat-messages`

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${DifyApi.API_KEY}`
    }

    const requestBody: DifyRequest = {
      query: query,
      conversation_id: conversationId,
      response_mode: 'blocking',
      user: 'student-001',
      inputs: {} // 必需字段：输入变量字典，如果没有变量则传空对象
    }

    console.info(`[DifyApi] 请求开始: POST ${url}`)
    console.info(`[DifyApi] 请求体: ${JSON.stringify(requestBody)}`)

    try {
      const response = await request.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(requestBody),
        connectTimeout: 30000,
        readTimeout: 30000
      })

      console.info(`[DifyApi] 响应状态码: ${response.responseCode}`)
      console.info(`[DifyApi] 响应体: ${response.result.toString()}`)

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as DifyResponse
        console.info(`[DifyApi] 请求成功: answer=${result.answer}`)
        return result
      } else if (response.responseCode === 400) {
        const errorMsg = response.result.toString()
        console.error(`[DifyApi] 请求参数错误 (400): ${errorMsg}`)
        console.error(`[DifyApi] 请求 URL: ${url}`)
        console.error(`[DifyApi] 请求体: ${JSON.stringify(requestBody)}`)
        throw new Error(`请求参数错误 (400): ${errorMsg}`)
      } else if (response.responseCode === 401) {
        console.error(`[DifyApi] API Key 无效或已过期`)
        throw new Error('API Key 无效，请检查配置')
      } else if (response.responseCode === 404) {
        console.error(`[DifyApi] API 地址不存在: ${url}`)
        throw new Error('API 地址错误（404），请检查 BASE_URL 和端口号是否正确')
      } else {
        throw new Error(`请求失败，状态码：${response.responseCode}`)
      }
    } catch (error) {
      console.error(`[DifyApi] 请求异常: ${(error as Error).message}`)
      throw new Error((error as Error).message || 'Dify API 请求异常')
    } finally {
      request.destroy()
    }
  }
}

import http from '@ohos.net.http'
import type { ResumeDifyRequest, ResumeDifyResponse } from '../model/Resume'

/**
 * 简历评估 Dify API（直接调用 Dify 服务）
 * 与 DifyApi.ets 模式一致，但使用独立的简历评估 App
 */
export class ResumeDifyApi {
  // 简历评估专用的 Dify App
  private static DIFY_URL: string = 'http://10.0.2.2:9000/v1/chat-messages'
  private static API_KEY: string = 'app-PK0cusL0dzrCKJBybntJVATl'

  /**
   * 发送简历进行 AI 评估
   * @param resumeContent 简历文本
   * @returns 评估结果文本（JSON 格式）
   */
  static async evaluate(resumeContent: string): Promise<string> {
    const request = http.createHttp()
    try {
      const body: ResumeDifyRequest = {
        query: resumeContent,
        response_mode: 'blocking',
        user: 'app-user',
        inputs: {}
      }

      console.info('[ResumeDifyApi] 请求开始:', ResumeDifyApi.DIFY_URL)
      console.info('[ResumeDifyApi] 请求体:', JSON.stringify(body))

      const response = await request.request(ResumeDifyApi.DIFY_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${ResumeDifyApi.API_KEY}`
        },
        extraData: JSON.stringify(body),
        connectTimeout: 30000,
        readTimeout: 60000
      })

      console.info('[ResumeDifyApi] 响应状态码:', response.responseCode)
      console.info('[ResumeDifyApi] 响应内容:', response.result.toString())

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ResumeDifyResponse
        return result.answer
      } else if (response.responseCode === 401) {
        throw new Error('API Key 无效')
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}, 响应: ${response.result.toString()}`)
      }
    } catch (error) {
      console.error('[ResumeDifyApi] 评估请求异常:', (error as Error).message)
      throw new Error((error as Error).message || '简历评估请求失败')
    } finally {
      request.destroy()
    }
  }
}

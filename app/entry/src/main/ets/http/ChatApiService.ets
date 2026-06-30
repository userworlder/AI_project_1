import http from '@ohos.net.http'
import { util } from '@kit.ArkTS'
import { TokenUtil } from '../common/TokenUtil'
import { Constants } from '../common/Constants'

/**
 * SSE 流式聊天回调接口
 */
export interface ChatStreamCallbacks {
  /** 每收到一段文本的回调 */
  onData: (text: string) => void
  /** 流式传输完成的回调 */
  onComplete: () => void
  /** 出错回调 */
  onError: (error: Error) => void
}

/**
 * SSE 协议缓冲区解析结果
 */
interface SseParseResult {
  events: string[]
  remainder: string
}

/**
 * SSE 流式聊天 API 服务
 *
 * 使用 @kit.NetworkKit 的 http 模块实现 SSE 协议解析，
 * 支持 TCP 分包缓冲、Authorization 鉴权、请求取消。
 */
export class ChatApiService {
  private httpRequest: http.HttpRequest | null = null
  private context: Context

  constructor(context: Context) {
    this.context = context
  }

  /**
   * 发送 SSE 流式聊天请求
   *
   * @param sessionId 会话 ID（UUID）
   * @param message   用户消息
   * @param callbacks 流式回调（onData / onComplete / onError）
   */
  async sendStreamMessage(
    sessionId: string,
    message: string,
    callbacks: ChatStreamCallbacks
  ): Promise<void> {
    // 销毁残留请求
    this.destroy()

    const request = http.createHttp()
    this.httpRequest = request

    const url = `${Constants.BASE_URL}/api/ai/chat/message/stream`
    const token = await TokenUtil.getToken(this.context)

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream'
    }
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    // SSE 分包缓冲区
    let buffer = ''

    // 注册数据接收事件 —— 处理 TCP 粘包/拆包
    request.on('dataReceive', (data: ArrayBuffer) => {
      const chunk: string = this.arrayBufferToString(data)
      buffer += chunk
      // 按 SSE 协议分割数据块：每个事件以 \n\n 结束
      const parsed: SseParseResult = this.parseSseBuffer(buffer)
      buffer = parsed.remainder
      for (const text of parsed.events) {
        callbacks.onData(text)
      }
    })

    // 注册传输完成事件
    request.on('dataEnd', () => {
      // 处理缓冲区剩余内容（非空说明最后一段不完整，可能是 [DONE] 信号）
      if (buffer.trim().length > 0) {
        const remaining: SseParseResult = this.parseSseBuffer(buffer)
        for (const text of remaining.events) {
          callbacks.onData(text)
        }
      }
      callbacks.onComplete()
      this.destroy()
    })

    const body = JSON.stringify({
      sessionId: sessionId,
      message: message
    })

    console.info(`[ChatApiService] SSE 请求开始: POST ${url}`)

    try {
      await request.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: body,
        connectTimeout: 30000,
        readTimeout: 0 // 流式传输不设超时
      })
    } catch (err) {
      // request 抛出的异常只处理非主动取消的情况
      const error = err as BusinessError
      if (error.code !== 0) {
        // code 0 表示主动调用 destroy 取消
        callbacks.onError(new Error(error.message || 'SSE 请求异常'))
        this.destroy()
      }
    }
  }

  /**
   * 取消当前请求
   */
  cancel(): void {
    this.destroy()
  }

  /**
   * 销毁 HTTP 请求实例
   */
  private destroy(): void {
    if (this.httpRequest) {
      try {
        this.httpRequest.off('dataReceive')
        this.httpRequest.off('dataEnd')
        this.httpRequest.destroy()
      } catch (_) {
        // 忽略销毁时的异常
      }
      this.httpRequest = null
    }
  }

  /**
   * SSE 协议缓冲区解析
   *
   * 将原始数据按 SSE 协议分割提取 data: 前缀的内容块。
   * SSE 数据格式：
   *   data: {content}\n\n
   *   data: [DONE]\n\n
   *
   * TCP 分包可能导致一个事件被拆成两次 dataReceive，
   * 所以需要 buffer 机制，将不完整的尾部留给下一次解析。
   *
   * @param raw 缓冲区文本
   * @returns 解析出的事件文本列表 + 剩余未完成数据
   */
  private parseSseBuffer(raw: string): SseParseResult {
    const events: string[] = []

    // 按双换行分割 SSE 事件
    const parts = raw.split('\n\n')

    // 最后一段可能不完整，留给下次
    const remainder = parts.pop() || ''

    for (const part of parts) {
      const trimmed: string = part.trim()
      if (!trimmed || trimmed === '') {
        continue
      }

      // 提取 data: 前缀后的内容（支持多行 data:）
      const lines: string[] = trimmed.split('\n')
      for (const line of lines) {
        if (line.startsWith('data:')) {
          const data: string = line.slice(5).trim()

          // 过滤终止信号
          if (data === '[DONE]') {
            continue
          }

          // 尝试解析 JSON 格式的 data: {"content":"xxx"}
          if (data.startsWith('{')) {
            try {
              const parsed: Record<string, Object> = JSON.parse(data)
              if (parsed.content) {
                events.push(parsed.content as string)
              } else {
                events.push(data)
              }
            } catch (_) {
              events.push(data)
            }
          } else {
            events.push(data)
          }
        }
      }
    }

    const result: SseParseResult = { events: events, remainder: remainder }
    return result
  }

  /**
   * ArrayBuffer → UTF-8 字符串
   */
  private arrayBufferToString(buffer: ArrayBuffer): string {
    const decoder = util.TextDecoder.create('utf-8')
    return decoder.decodeToString(new Uint8Array(buffer))
  }
}

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
   * 核心逻辑：
   * 1. 发起 HTTP POST 请求（阻塞模式，等待完整响应）
   * 2. 按 SSE 协议解析响应：事件之间用 \n\n 分隔，每个 data: 行为一个数据片段
   * 3. 正确还原多行 data:（Spring SseEmitter 会将含 \n 的数据拆成多个 data: 行）
   * 4. 一次性返回完整内容给 ViewModel
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

    const body = JSON.stringify({
      sessionId: sessionId,
      message: message
    })

    console.info(`[ChatApiService] SSE 请求开始: POST ${url}`)
    console.info(`[ChatApiService] 请求体: ${body}`)

    try {
      const response = await request.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: body,
        connectTimeout: 30000,
        readTimeout: 60000
      })

      console.info(`[ChatApiService] 响应状态码: ${response.responseCode}`)
      console.info(`[ChatApiService] 响应数据类型: ${typeof response.result}`)

      if (response.responseCode === 200) {
        // ============ 步骤1: 将响应体转为字符串 ============
        const resultStr: string = this.responseToString(response.result)
        console.info(`[ChatApiService] 响应原始内容(前300字符): ${resultStr.substring(0, 300)}`)

        // ============ 步骤2: 按 SSE 协议解析事件 ============
        // SSE 协议: 多个事件之间用 \n\n 分隔, 每个事件由 event:/data: 行组成
        const fullContent: string = this.parseSseEvents(resultStr)

        console.info(`[ChatApiService] 提取内容长度: ${fullContent.length}`)
        console.info(`[ChatApiService] 提取内容(前200字符): ${fullContent.substring(0, 200)}`)

        // ============ 步骤3: 返回内容 ============
        callbacks.onData(fullContent)
        console.info('[ChatApiService] 调用 onComplete')
        callbacks.onComplete()
      } else {
        console.error(`[ChatApiService] 请求失败，状态码: ${response.responseCode}`)
        callbacks.onError(new Error(`请求失败，状态码：${response.responseCode}`))
      }
    } catch (err) {
      const error = err as BusinessError
      console.error(`[ChatApiService] 请求异常: code=${error.code}, message=${error.message}`)
      callbacks.onError(new Error(error.message || 'SSE 请求异常'))
    } finally {
      this.destroy()
    }
  }

  /**
   * 将响应结果转为字符串（兼容 string 和 ArrayBuffer）
   */
  private responseToString(result: Object): string {
    if (typeof result === 'string') {
      return result
    }
    if (result instanceof ArrayBuffer) {
      return this.arrayBufferToString(result)
    }
    // 兜底
    return String(result)
  }

  /**
   * 正确解析 SSE 事件，保留多行 data: 中的换行符
   *
   * SSE 原始数据格式示例（来自 Spring SseEmitter）：
   *   event:message
   *   data:第一行内容
   *   data:第二行内容
   *   data:
   *   data:空行后的内容
   *
   *   event:message
   *   data:[DONE]
   *
   * 解析规则：
   * - 按 \n\n 分割每条 SSE 事件
   * - 每条事件内，收集所有 data: 行的数据
   * - 同一事件内的多行 data: 用 \n 拼接（还原原始换行）
   * - 不同事件的内容直接拼接（不额外加换行）
   */
  private parseSseEvents(raw: string): string {
    if (!raw) return ''

    // 按 \n\n 分割成独立事件
    const eventBlocks: string[] = raw.split('\n\n')
    let fullContent: string = ''

    for (const eventBlock of eventBlocks) {
      if (!eventBlock || !eventBlock.trim()) {
        continue
      }

      const lines: string[] = eventBlock.trimEnd().split('\n')
      const dataLines: string[] = []
      let hasData: boolean = false

      for (const line of lines) {
        if (line.startsWith('data:')) {
          const value: string = line.slice(5) // 保留原始内容（含空值）
          const trimmedValue: string = value.trim()

          // 过滤 [DONE] 终止信号
          if (trimmedValue === '[DONE]') {
            return fullContent // [DONE] 后面的内容忽略
          }

          // 尝试解析 JSON 格式（后端可能发 {"content":"..."}）
          if (trimmedValue.startsWith('{')) {
            try {
              const parsed: Record<string, Object> = JSON.parse(trimmedValue)
              if (parsed && parsed.content) {
                dataLines.push(parsed.content as string)
                hasData = true
                continue
              }
            } catch (_) {
              // JSON 解析失败，按纯文本处理
            }
          }

          // 纯文本：保留原始值（空值也保留，表示空行）
          dataLines.push(value)
          hasData = true
        }
        // event: 行直接忽略，不做任何处理
      }

      // 同一事件内的多行 data: 用 \n 拼接
      if (hasData && dataLines.length > 0) {
        fullContent += dataLines.join('\n')
      }
    }

    return fullContent
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
   * 支持两种数据格式：
   * 1. 标准 SSE: data:内容\n\n
   * 2. 纯文本片段（Spring SSE 分包可能导致 data: 和内容被拆到两次 dataReceive）
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
        if (line.startsWith('event:')) {
          // SSE 事件名称行，跳过
          continue
        }
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
        } else {
          // 非 data: 开头的行 → 直接作为内容片段处理（应对分包错位）
          const text: string = line.trim()
          if (text && text !== '[DONE]') {
            events.push(text)
          }
        }
      }
    }

    // 如果前面按 \n\n 分割没提取到事件，尝试直接从 remainder 里提取内容
    // 适用于 data: 和内容跨包的情况
    if (events.length === 0 && remainder.length > 0) {
      // 从 remainder 中查找 data: 或纯文本
      for (const line of remainder.split('\n')) {
        if (line.startsWith('event:')) {
          continue
        }
        if (line.startsWith('data:')) {
          const data = line.slice(5).trim()
          if (data && data !== '[DONE]') {
            events.push(data)
          }
        } else {
          const text = line.trim()
          if (text && text !== '[DONE]') {
            events.push(text)
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

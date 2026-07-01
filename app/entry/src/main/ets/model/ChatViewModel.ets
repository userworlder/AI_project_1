import { ChatMessage } from '../model/ChatMessage'
import { ChatApiService } from '../http/ChatApiService'
import { util } from '@kit.ArkTS'

/**
 * 聊天 ViewModel 层（业务逻辑）
 * 支持 SSE 流式接收、UUID 会话管理
 */
@Observed
export class ChatViewModel {
  // 消息列表
  messages: ChatMessage[] = []
  // 发送/流式接收状态（true 时禁用发送按钮、显示"思考中..."占位）
  sending: boolean = false
  // 会话 ID（页面级唯一，用于多轮对话上下文）
  sessionId: string = ''
  // SSE 流式服务实例（由页面传入 context 后初始化）
  private chatApi: ChatApiService | null = null

  /**
   * 绑定页面上下文（在 aboutToAppear 中调用）
   */
  init(context: Context): void {
    this.chatApi = new ChatApiService(context)
    this.sessionId = util.generateRandomUUID()
    console.info(`[ChatViewModel] 初始化完成，sessionId=${this.sessionId}`)
  }

  /**
   * 发送消息（阻塞模式，等待完整响应后一次性显示）
   *
   * 由于 HarmonyOS HTTP 模块不支持真正的 SSE 流式接收，
   * 改为等待后端返回完整响应后，一次性设置消息内容。
   * 超时由 HTTP 请求的 readTimeout (60s) 保障，
   * ViewModel 层只需一个兜底超时防止请求卡死。
   *
   * @param content 用户输入的消息内容
   */
  async sendMessage(content: string): Promise<void> {
    if (!content || content.trim().length === 0 || this.sending || !this.chatApi) {
      return
    }

    // 1. 切为发送中状态
    this.sending = true

    // 2. 添加用户消息
    const userMsg = new ChatMessage('user', content, Date.now())
    this.messages.push(userMsg)

    // 3. 添加 AI 占位消息 "思考中..."
    const aiMsgIndex = this.messages.length
    const placeholder = new ChatMessage('assistant', '思考中...', Date.now())
    this.messages.push(placeholder)

    // 4. 兜底超时（90 秒，覆盖 HTTP readTimeout 60s + 余量）
    let isCompleted = false
    const safetyTimeoutId: number = setTimeout(() => {
      if (!isCompleted) {
        console.warn('[ChatViewModel] 兜底超时（90秒），强制结束')
        isCompleted = true
        this.messages[aiMsgIndex].content = '抱歉，AI 响应超时，请稍后重试。'
        this.messages = [...this.messages]
        this.sending = false
        if (this.chatApi) {
          this.chatApi.cancel()
        }
      }
    }, 90000)

    // 5. 发起请求等待完整响应
    await this.chatApi.sendStreamMessage(this.sessionId, content, {
      onData: (text: string) => {
        console.info(`[ChatViewModel] 收到完整响应，长度=${text.length}`)
        console.info(`[ChatViewModel] 内容预览(前200字符): ${text.substring(0, 200)}`)

        // 保存完整内容
        this.messages[aiMsgIndex].content = text
        this.messages = [...this.messages]
      },

      onComplete: () => {
        if (isCompleted) return
        isCompleted = true
        clearTimeout(safetyTimeoutId)

        const finalContent = this.messages[aiMsgIndex].content
        if (!finalContent || finalContent.trim() === '' || finalContent === '思考中...') {
          this.messages[aiMsgIndex].content = '抱歉，我暂时无法回答这个问题。'
          this.messages = [...this.messages]
        } else {
          console.info(`[ChatViewModel] 响应完成，内容长度=${finalContent.length}`)
          // 检查内容中是否包含换行符和 Markdown 标记
          const hasNewlines = finalContent.includes('\n')
          const hasMarkdown = /(\*{1,2}|`|#|\[|>|-)/.test(finalContent)
          console.info(`[ChatViewModel] 内容包含换行: ${hasNewlines}, 包含Markdown: ${hasMarkdown}`)
        }
        this.sending = false
      },

      onError: (error: Error) => {
        if (isCompleted) return
        isCompleted = true
        clearTimeout(safetyTimeoutId)
        console.error(`[ChatViewModel] 流式错误: ${error.message}`)
        this.messages[aiMsgIndex].content = `抱歉，出错了：${error.message}`
        this.messages = [...this.messages]
        this.sending = false
      }
    })
  }

  /**
   * 取消当前的流式请求
   */
  cancelStream(): void {
    if (this.chatApi) {
      this.chatApi.cancel()
    }
    this.sending = false
  }

  /**
   * 清空消息列表并生成新会话 ID
   */
  clearMessages(): void {
    this.messages = []
    this.sessionId = util.generateRandomUUID()
    console.info(`[ChatViewModel] 已清空，新 sessionId=${this.sessionId}`)
  }
}

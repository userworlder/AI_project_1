import { ChatMessage } from '../model/ChatMessage'
import { ChatApiService } from '../http/ChatApiService'
import { util } from '@kit.ArkTS'

/**
 * 聊天 ViewModel 层（业务逻辑）
 * 支持 SSE 流式接收、打字机效果、UUID 会话管理
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
   * 发送消息（SSE 流式）
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

    // 4. 组装完整回复文本（用于最终存入消息对象）
    let fullReply = ''

    // 5. 发起 SSE 流式请求
    await this.chatApi.sendStreamMessage(this.sessionId, content, {
      onData: (text: string) => {
        // 逐段追加回复内容 → 打字机效果
        fullReply += text
        this.messages[aiMsgIndex].content = fullReply
        // 触发 UI 刷新（@Observed 自动检测引用变化，
        // 但字符串替换内容时需手动触发）
        this.messages = [...this.messages]
      },

      onComplete: () => {
        // 如果最终内容为空或仍为占位符，给出默认提示
        if (!fullReply || fullReply.trim() === '') {
          this.messages[aiMsgIndex].content = '抱歉，我暂时无法回答这个问题。'
          this.messages = [...this.messages]
        }
        this.sending = false
        console.info(`[ChatViewModel] 流式接收完成，总长度=${fullReply.length}`)
      },

      onError: (error: Error) => {
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

import { ChatMessage } from '../model/ChatMessage'
import { DifyApi } from '../http/DifyApi'

/**
 * 聊天 ViewModel 层（业务逻辑）
 * 使用 @Observed 装饰器实现响应式数据
 */
@Observed
export class ChatViewModel {
  // 消息列表
  messages: ChatMessage[] = []
  // 发送状态
  sending: boolean = false
  // 会话 ID（用于多轮对话，练习一）
  conversationId: string = ''

  /**
   * 发送消息
   * @param content 用户输入的消息内容
   */
  async sendMessage(content: string): Promise<void> {
    if (!content || content.trim().length === 0) {
      return
    }

    // 设置发送状态
    this.sending = true

    try {
      // 1. 添加用户消息到列表
      const userMessage = new ChatMessage('user', content, Date.now())
      this.messages.push(userMessage)

      // 2. 调用 Dify API
      const response = await DifyApi.sendChatMessage(content, this.conversationId)

      // 3. 保存 conversation_id（练习一：支持多轮对话）
      if (response.conversation_id) {
        this.conversationId = response.conversation_id
      }

      // 4. 添加 AI 回复到列表
      // TODO: 取消下面注释以测试 Markdown 渲染（开发时可用）
      // const testResponse = '这是一个**加粗文本**的示例\n\n这是`行内代码`的示例\n\n普通文本和**加粗**以及`代码`混合使用'
      // const aiMessage = new ChatMessage('assistant', testResponse, Date.now())
      
      // 使用真实 API 返回的内容
      const aiMessage = new ChatMessage('assistant', response.answer, Date.now())
      this.messages.push(aiMessage)
    } catch (error) {
      // 5. 错误处理：添加错误提示消息
      const errorMessage = new ChatMessage('assistant', `抱歉，出错了：${(error as Error).message}`, Date.now())
      this.messages.push(errorMessage)
      console.error(`[ChatViewModel] 发送消息失败: ${(error as Error).message}`)
    } finally {
      // 6. 重置发送状态
      this.sending = false
    }
  }

  /**
   * 清空消息列表
   * 同时重置 conversationId（练习一）
   */
  clearMessages(): void {
    this.messages = []
    this.conversationId = ''
  }
}

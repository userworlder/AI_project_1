/**
 * 聊天消息数据模型
 */
export class ChatMessage {
  role: string = 'user' // 'user' 或 'assistant'
  content: string = ''
  reasoningContent: string = '' // 深度思考过程（来自 Dify reasoning_content）
  reasoningVisible: boolean = false // 思考过程显隐状态（默认隐藏）
  timestamp: number = 0

  constructor(role: string, content: string, timestamp: number, reasoningContent?: string) {
    this.role = role
    this.content = content
    this.timestamp = timestamp
    if (reasoningContent) {
      this.reasoningContent = reasoningContent
    }
  }
}

/**
 * 聊天请求数据模型
 */
export class ChatRequest {
  message: string = ''
  conversationId: string = ''

  constructor(message: string, conversationId: string) {
    this.message = message
    this.conversationId = conversationId
  }
}

/**
 * Dify API 响应数据模型
 */
export class DifyResponse {
  answer: string = ''
  conversation_id: string = ''
  message_id: string = ''
  created_at: number = 0
  reasoning_content?: string // 深度思考过程（可能不存在）

  constructor(answer: string, conversation_id: string, message_id: string, created_at: number) {
    this.answer = answer
    this.conversation_id = conversation_id
    this.message_id = message_id
    this.created_at = created_at
  }
}

/**
 * Dify API 请求体数据模型
 */
export interface DifyRequest {
  query: string
  conversation_id: string
  response_mode: string
  user: string
  inputs: Record<string, string> // 必需字段：输入变量字典（字符串键值对）
  input_type?: string // 可选字段
}

import router from '@ohos.router'
import { ChatViewModel } from '../model/ChatViewModel'
import { ChatMessage } from '../model/ChatMessage'
import { DateUtil } from '../common/DateUtil'
import { MarkdownRenderer } from '../components/MarkdownRenderer'

/**
 * AI 流式聊天页面
 *
 * 功能特性：
 * - SSE 流式接收 AI 回复，打字机效果逐字展示
 * - 用户消息右对齐蓝色气泡，AI 消息左对齐灰色气泡
 * - 发送后显示 "思考中..." 占位，流式传输过程中禁用发送按钮
 * - UUID 会话 ID，单页面内保持一致以支持多轮对话上下文
 */
@Entry
@Component
struct Chat {
  // 页面上下文（传递给 ViewModel 以获取 Token）
  private context: Context = getContext(this)

  // ViewModel 实例（使用 @State 实现响应式绑定）
  @State viewModel: ChatViewModel = new ChatViewModel()

  // 输入框内容
  @State inputText: string = ''

  // 列表滚动控制器
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    console.info('[Chat] 页面加载')
    // 初始化 ViewModel（绑定 context、生成 UUID sessionId）
    this.viewModel.init(this.context)
  }

  aboutToDisappear() {
    // 离开页面时取消进行中的流式请求
    this.viewModel.cancelStream()
  }

  build() {
    Column() {
      // ========== 顶部标题栏 ==========
      this.buildHeader()

      // ========== 消息列表区域 ==========
      this.buildMessageList()

      // ========== 底部输入栏 ==========
      this.buildInputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ──────────── 顶部标题栏 ────────────

  @Builder
  buildHeader() {
    Row() {
      // 左侧返回按钮
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back()
        })

      // 中间标题
      Text('AI智能对话')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧清空按钮（流式传输中禁用）
      Text('清空')
        .fontSize(14)
        .fontColor(this.viewModel.sending ? '#CCCCCC' : '#409EFF')
        .enabled(!this.viewModel.sending)
        .onClick(() => {
          this.viewModel.clearMessages()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetY: 2
    })
  }

  // ──────────── 消息列表区域 ────────────

  @Builder
  buildMessageList() {
    if (this.viewModel.messages.length === 0) {
      this.buildEmptyState()
    } else {
      this.buildMessageListView()
    }
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('💬')
        .fontSize(64)
        .margin({ bottom: 16 })

      Text('你好！有什么问题可以问我~')
        .fontSize(16)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMessageListView() {
    List({ scroller: this.scroller }) {
      ForEach(this.viewModel.messages, (message: ChatMessage, index: number) => {
        ListItem() {
          this.buildMessageItem(message, index)
        }
      }, (message: ChatMessage, index: number) => `${index}-${message.timestamp}`)
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .scrollBar(BarState.Off)
  }

  @Builder
  buildMessageItem(message: ChatMessage, index: number) {
    Row() {
      if (message.role === 'user') {
        // 用户消息：右对齐蓝色
        this.buildUserMessageBubble(message)
      } else {
        // AI 消息：左对齐灰色
        this.buildAiMessageBubble(message, index)
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .justifyContent(message.role === 'user' ? FlexAlign.End : FlexAlign.Start)
  }

  // ──────────── 用户消息气泡（右对齐蓝色） ────────────

  @Builder
  buildUserMessageBubble(message: ChatMessage) {
    Column({ space: 4 }) {
      Text(message.content)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .lineHeight(22)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })

      Text(DateUtil.formatFriendly(message.timestamp))
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.7)')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.End)
    .backgroundColor('#409EFF')
    .borderRadius(12)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .constraintSize({ maxWidth: '70%' })
  }

  // ──────────── AI 消息气泡（左对齐灰色 + 思考中动画） ────────────

  @Builder
  buildAiMessageBubble(message: ChatMessage, index: number) {
    Column({ space: 4 }) {
      if (this.viewModel.sending && index === this.viewModel.messages.length - 1
          && message.content === '思考中...') {
        // 正在流式接收中 → 显示加载动画 + "思考中..."
        this.buildThinkingPlaceholder(message)
      } else {
        // 正常消息内容（使用 Markdown 渲染）
        MarkdownRenderer({ content: message.content })
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })

        // 时间戳
        Text(DateUtil.formatFriendly(message.timestamp))
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F4F4F5')
    .borderRadius(12)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .constraintSize({ maxWidth: '70%' })
  }

  /**
   * 思考中占位 —— 等待第一个 token 到达时显示
   */
  @Builder
  buildThinkingPlaceholder(message: ChatMessage) {
    Row({ space: 8 }) {
      // 三个跳动小圆点动画
      LoadingProgress()
        .width(20)
        .height(20)
        .color('#409EFF')

      Text('思考中...')
        .fontSize(14)
        .fontColor('#666666')
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
  }

  // ──────────── 底部输入栏 ────────────

  @Builder
  buildInputBar() {
    Row() {
      // 输入框
      TextInput({ text: this.inputText, placeholder: '输入你的问题...' })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .enabled(!this.viewModel.sending)
        .onChange((value: string) => {
          this.inputText = value
        })
        .onSubmit(() => {
          this.handleSend()
        })

      // 发送按钮（流式传输中禁用）
      Button('发送')
        .type(ButtonType.Normal)
        .backgroundColor(this.canSend() ? '#409EFF' : '#CCCCCC')
        .fontColor('#FFFFFF')
        .fontSize(14)
        .borderRadius(20)
        .width(70)
        .height(40)
        .margin({ left: 8 })
        .enabled(this.canSend())
        .onClick(() => {
          this.handleSend()
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetY: -2
    })
  }

  /**
   * 判断是否允许发送
   * - 流式传输中禁止
   * - 输入内容为空禁止
   */
  canSend(): boolean {
    return !this.viewModel.sending && this.inputText.trim().length > 0
  }

  /**
   * 处理发送消息
   */
  async handleSend(): Promise<void> {
    const content = this.inputText.trim()
    if (!content || this.viewModel.sending) {
      return
    }

    // 清空输入框
    this.inputText = ''

    // 调用 ViewModel 发送（SSE 流式）
    await this.viewModel.sendMessage(content)

    // 流式完成后滚动到底部
    setTimeout(() => {
      this.scroller.scrollToIndex(this.viewModel.messages.length - 1, true)
    }, 150)
  }
}

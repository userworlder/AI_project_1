import router from '@ohos.router'
import { ChatViewModel } from '../model/ChatViewModel'
import { ChatMessage } from '../model/ChatMessage'
import { DateUtil } from '../common/DateUtil'
import { MarkdownRenderer } from '../components/MarkdownRenderer'

/**
 * AI 智能对话页面
 */
@Entry
@Component
struct Chat {
  // 创建 ViewModel 实例
  @State viewModel: ChatViewModel = new ChatViewModel()
  // 输入框内容
  @State inputText: string = ''
  // List 组件的控制器（用于滚动）
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    console.info('[Chat] 页面加载')
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

  /**
   * 构建顶部标题栏
   */
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

      // 右侧清空按钮
      Text('清空')
        .fontSize(14)
        .fontColor('#409EFF')
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

  /**
   * 构建消息列表区域
   */
  @Builder
  buildMessageList() {
    if (this.viewModel.messages.length === 0) {
      // 空状态
      this.buildEmptyState()
    } else {
      // 消息列表
      this.buildMessageListView()
    }
  }

  /**
   * 构建空状态
   */
  @Builder
  buildEmptyState() {
    Column() {
      // 图标
      Text('💬')
        .fontSize(64)
        .margin({ bottom: 16 })

      // 提示文字
      Text('你好！有什么问题可以问我~')
        .fontSize(16)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建消息列表视图
   */
  @Builder
  buildMessageListView() {
    List({ scroller: this.scroller }) {
      ForEach(this.viewModel.messages, (message: ChatMessage, index: number) => {
        ListItem() {
          this.buildMessageItem(message)
        }
      }, (message: ChatMessage, index: number) => `${index}-${message.timestamp}`)
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .scrollBar(BarState.Off)
  }

  /**
   * 构建单条消息项
   */
  @Builder
  buildMessageItem(message: ChatMessage) {
    Row() {
      if (message.role === 'user') {
        // 用户消息：右对齐
        this.buildUserMessageBubble(message)
      } else {
        // AI 消息：左对齐
        this.buildAiMessageBubble(message)
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  /**
   * 构建用户消息气泡
   */
  @Builder
  buildUserMessageBubble(message: ChatMessage) {
    Column() {
      // 消息内容
      Text(message.content)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .lineHeight(22)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })

      // 时间
      Text(DateUtil.formatFriendly(message.timestamp))
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.End)
    .backgroundColor('#409EFF')
    .borderRadius(12)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .constraintSize({ maxWidth: '70%' })
  }

  /**
   * 构建 AI 消息气泡（使用 MarkdownRenderer，练习二）
   */
  @Builder
  buildAiMessageBubble(message: ChatMessage) {
    Column() {
      // 消息内容（使用 Markdown 渲染器）
      MarkdownRenderer({ content: message.content })
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })

      // 时间
      Text(DateUtil.formatFriendly(message.timestamp))
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F4F4F5')
    .borderRadius(12)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .constraintSize({ maxWidth: '70%' })
  }

  /**
   * 构建底部输入栏
   */
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
        .onChange((value: string) => {
          this.inputText = value
        })
        .onSubmit(() => {
          this.handleSend()
        })

      // 发送按钮
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
   * 判断是否可以发送
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

    // 调用 ViewModel 发送消息
    await this.viewModel.sendMessage(content)

    // 发送完成后滚动到底部
    setTimeout(() => {
      this.scroller.scrollToIndex(this.viewModel.messages.length - 1, true)
    }, 100)
  }
}

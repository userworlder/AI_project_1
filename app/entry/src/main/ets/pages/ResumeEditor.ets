import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import { ResumeApi } from '../http/ResumeApi'
import type { UserInfo } from '../model/User'

@Entry
@Component
struct ResumeEditor {
  @State resumeContent: string = ''
  @State resumeTitle: string = ''
  @State evaluating: boolean = false
  @State errorMsg: string = ''

  async handleEvaluate() {
    if (!this.resumeContent.trim()) {
      this.errorMsg = '请填写简历内容'
      return
    }
    if (this.resumeContent.trim().length < 20) {
      this.errorMsg = '简历内容太短，请填写完整的简历'
      return
    }

    this.evaluating = true
    this.errorMsg = ''

    try {
      const userInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
      if (!userInfo) {
        this.errorMsg = '请先登录'
        return
      }

      // 直接调用后端 AI 评估接口（后端调用 DeepSeek 分析简历）
      const saved = await ResumeApi.evaluate(getContext(this), {
        userId: userInfo.id,
        title: this.resumeTitle.trim() || '未命名简历',
        content: this.resumeContent.trim(),
        status: 'completed'
      })

      // 跳转到结果页
      router.replaceUrl({
        url: 'pages/ResumeResult',
        params: { resumeId: saved.id }
      })
    } catch (error) {
      this.errorMsg = (error as Error).message || '评估失败，请重试'
    } finally {
      this.evaluating = false
    }
  }

  // 保留 parseArray 方法以备扩展
  parseArray(arr: string[]): string {
    if (!arr || arr.length === 0) return ''
    let result = ''
    for (let i = 0; i < arr.length; i++) {
      result += (i + 1) + '. ' + arr[i] + '\n'
    }
    return result.trim()
  }

  build() {
    Column() {
      // 顶部
      Column() {
        Row({ space: 16 }) {
          Text('‹')
            .fontSize(28)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
            .onClick(() => { router.back() })

          Column({ space: 4 }) {
            Text('简历评估')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
            Text('输入简历内容，AI 智能分析')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: 16, bottom: 24 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
      })

      // 表单
      Scroll() {
        Column({ space: 16 }) {
          // 标题
          Column({ space: 8 }) {
            Text('简历标题')
              .fontSize(14)
              .fontColor('#666')
              .width('100%')
            TextInput({ text: this.resumeTitle, placeholder: '例如：Java 后端开发简历' })
              .width('100%')
              .height(44)
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding({ left: 16 })
              .fontSize(16)
              .onChange((value: string) => { this.resumeTitle = value })
          }
          .width('100%')

          // 内容
          Column({ space: 8 }) {
            Text('简历内容')
              .fontSize(14)
              .fontColor('#666')
              .width('100%')

            TextArea({ text: this.resumeContent, placeholder: '请粘贴或输入你的简历内容...\n\n包括：个人信息、教育背景、工作经历、项目经验、技能特长等' })
              .width('100%')
              .height(300)
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(16)
              .fontSize(15)
              .onChange((value: string) => { this.resumeContent = value })
          }
          .width('100%')

          // 提示
          Column({ space: 4 }) {
            Text('💡 评估内容越详细，分析结果越准确')
              .fontSize(13)
              .fontColor('#999')
            Text('建议包含：个人信息、教育背景、工作经历、项目经验、技能')
              .fontSize(13)
              .fontColor('#999')
          }
          .width('100%')
          .padding({ left: 4 })

          // 错误
          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontSize(14)
              .fontColor('#EF4444')
              .width('100%')
              .textAlign(TextAlign.Center)
          }

          // 评估按钮
          Button(this.evaluating ? 'AI 评估中...' : '开始 AI 评估')
            .width('100%')
            .height(50)
            .backgroundColor('#6366F1')
            .fontColor('#fff')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .shadow({ radius: 12, color: 'rgba(99,102,241,0.4)', offsetY: 4 })
            .enabled(!this.evaluating)
            .onClick(() => { this.handleEvaluate() })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 40 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}

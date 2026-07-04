import router from '@ohos.router'
import { CourseApi } from '../http/CourseApi'
import type { QuestionItem, AnswerItem, SubmitAnswerRequest } from '../model/Course'

@Entry
@Component
struct QuizPage {
  @State questions: QuestionItem[] = []
  @State currentIndex: number = 0
  @State answers: Record<number, string> = {}
  @State loading: boolean = true
  @State submitting: boolean = false
  @State errorMsg: string = ''
  @State sectionTitle: string = '答题'
  private sectionId: number = 0

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    const sectionId = params['sectionId'] as number
    const sectionTitle = params['sectionTitle'] as string
    if (sectionTitle) {
      this.sectionTitle = sectionTitle
    }
    if (sectionId) {
      this.sectionId = sectionId
      this.loadQuestions(sectionId)
    } else {
      this.errorMsg = '缺少章节信息'
      this.loading = false
    }
  }

  async loadQuestions(sectionId: number) {
    this.loading = true
    try {
      const questions = await CourseApi.getQuestions(getContext(this), sectionId)
      this.questions = questions || []
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载题目失败'
      console.error('加载题目失败:', error)
    } finally {
      this.loading = false
    }
  }

  get currentQuestion(): QuestionItem | null {
    if (this.currentIndex >= 0 && this.currentIndex < this.questions.length) {
      return this.questions[this.currentIndex]
    }
    return null
  }

  get answeredCount(): number {
    let count = 0
    const keys = Object.keys(this.answers)
    for (const key of keys) {
      if (this.answers[key]) {
        count++
      }
    }
    return count
  }

  get allAnswered(): boolean {
    return this.answeredCount === this.questions.length && this.questions.length > 0
  }

  selectAnswer(questionId: number, answer: string) {
    const newAnswers: Record<number, string> = {}
    const keys = Object.keys(this.answers)
    for (const key of keys) {
      newAnswers[key] = this.answers[key]
    }
    newAnswers[questionId] = answer
    this.answers = newAnswers
  }

  goToQuestion(index: number) {
    if (index >= 0 && index < this.questions.length) {
      this.currentIndex = index
    }
  }

  parseOptions(optionsStr: string): string[] {
    try {
      return JSON.parse(optionsStr) as string[]
    } catch (e) {
      return []
    }
  }

  async handleSubmit() {
    if (!this.allAnswered) {
      return
    }
    this.submitting = true
    try {
      const answerList: AnswerItem[] = []
      for (const q of this.questions) {
        const ans = this.answers[q.id]
        if (ans) {
          answerList.push({ questionId: q.id, answer: ans })
        }
      }
      const request: SubmitAnswerRequest = {
        sectionId: this.sectionId,
        answers: answerList
      }
      const result = await CourseApi.submitAnswers(getContext(this), request)
      router.replaceUrl({
        url: 'pages/QuizResult',
        params: {
          score: result.score,
          totalQuestions: result.totalQuestions,
          correctCount: result.correctCount,
          sectionId: result.sectionId,
          sectionTitle: this.sectionTitle
        }
      })
    } catch (error) {
      this.errorMsg = (error as Error).message || '提交失败，请重试'
    } finally {
      this.submitting = false
    }
  }

  getOptionLabel(index: number): string {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F']
    return labels[index] || String.fromCharCode(65 + index)
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 内容区域 =====
      if (this.loading) {
        this.buildLoadingState()
      } else if (this.errorMsg && this.questions.length === 0) {
        this.buildErrorState()
      } else if (this.questions.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildQuizContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  buildHeader() {
    Column() {
      Row({ space: 16 }) {
        Text('‹')
          .fontSize(28)
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.back()
          })

        Column({ space: 4 }) {
          Text('答题')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text(this.sectionTitle)
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.7)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
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
  }

  @Builder
  buildLoadingState() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildErrorState() {
    Column() {
      Text('⚠️')
        .fontSize(48)
        .margin({ bottom: 12 })
      Text(this.errorMsg)
        .fontSize(16)
        .fontColor('#999')
        .textAlign(TextAlign.Center)
      Button('重新加载')
        .fontSize(14)
        .fontColor('#6366F1')
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ top: 16 })
        .onClick(() => {
          this.errorMsg = ''
          this.loadQuestions(this.sectionId)
        })
    }
    .layoutWeight(1)
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('📝')
        .fontSize(64)
        .margin({ bottom: 16 })
      Text('暂未设置题目')
        .fontSize(16)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildQuizContent() {
    Column() {
      // 进度条
      this.buildProgressBar()

      Scroll() {
        Column({ space: 20 }) {
          // 题目内容
          if (this.currentQuestion) {
            this.buildQuestionCard(this.currentQuestion)
          }

          // 上一题/下一题 导航
          this.buildQuestionNavigation()

          // 提交按钮
          if (this.allAnswered) {
            this.buildSubmitButton()
          }

          // 错误提示
          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontSize(14)
              .fontColor('#EF4444')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 12 })
          }
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  buildProgressBar() {
    Column({ space: 8 }) {
      Row() {
        Text(`第 ${this.currentIndex + 1}/${this.questions.length} 题`)
          .fontSize(14)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)

        Blank()

        Text(`已答 ${this.answeredCount}/${this.questions.length}`)
          .fontSize(13)
          .fontColor('#999')
      }
      .width('100%')

      Row() {
        Row() {
          Text('')
            .width('100%')
            .height(6)
        }
        .width((this.answeredCount / this.questions.length * 100) + '%')
        .backgroundColor('#6366F1')
        .borderRadius(3)
      }
      .width('100%')
      .height(6)
      .backgroundColor('#F0F0F0')
      .borderRadius(3)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 12, bottom: 0 })
  }

  @Builder
  buildQuestionCard(question: QuestionItem) {
    Column({ space: 16 }) {
      // 题目类型标签
      Row({ space: 8 }) {
        Text(question.type === 'choice' ? '选择题' : '判断题')
          .fontSize(11)
          .fontColor('#fff')
          .backgroundColor(question.type === 'choice' ? '#6366F1' : '#10B981')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .lineHeight(16)

        Text(`第 ${this.currentIndex + 1} 题`)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')

      // 题目内容
      Text(question.content)
        .fontSize(16)
        .fontColor('#333')
        .lineHeight(24)
        .width('100%')

      Divider()
        .color('#F0F0F0')
        .width('100%')

      // 选项
      if (question.type === 'choice') {
        this.buildChoiceOptions(question)
      } else if (question.type === 'true_false') {
        this.buildTrueFalseOptions(question)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  buildChoiceOptions(question: QuestionItem) {
    Column({ space: 10 }) {
      Text('请选择答案')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')

      ForEach(this.parseOptions(question.options), (option: string, index: number) => {
        Row({ space: 12 }) {
          Text(this.getOptionLabel(index))
            .fontSize(14)
            .fontColor(this.answers[question.id] === option ? '#fff' : '#6366F1')
            .fontWeight(FontWeight.Bold)
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(this.answers[question.id] === option ? '#6366F1' : '#EEF2FF')
            .textAlign(TextAlign.Center)
            .lineHeight(28)

          Text(option)
            .fontSize(15)
            .fontColor(this.answers[question.id] === option ? '#6366F1' : '#333')
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor(this.answers[question.id] === option ? '#EEF2FF' : '#F5F6FA')
        .borderRadius(12)
        .border({ width: this.answers[question.id] === option ? 1.5 : 0, color: '#6366F1' })
        .onClick(() => {
          this.selectAnswer(question.id, option)
        })
      })
    }
    .width('100%')
  }

  @Builder
  buildTrueFalseOptions(question: QuestionItem) {
    Column({ space: 12 }) {
      Text('请判断正误')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')

      Row({ space: 16 }) {
        // True 按钮
        Column() {
          Text('✓')
            .fontSize(32)
            .fontColor(this.answers[question.id] === 'true' ? '#fff' : '#10B981')
            .margin({ bottom: 8 })
          Text('正确')
            .fontSize(16)
            .fontColor(this.answers[question.id] === 'true' ? '#fff' : '#10B981')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .height(120)
        .backgroundColor(this.answers[question.id] === 'true' ? '#10B981' : '#F0FDF4')
        .borderRadius(16)
        .border({ width: this.answers[question.id] === 'true' ? 2 : 1, color: this.answers[question.id] === 'true' ? '#10B981' : '#D1FAE5' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.selectAnswer(question.id, 'true')
        })

        // False 按钮
        Column() {
          Text('✗')
            .fontSize(32)
            .fontColor(this.answers[question.id] === 'false' ? '#fff' : '#EF4444')
            .margin({ bottom: 8 })
          Text('错误')
            .fontSize(16)
            .fontColor(this.answers[question.id] === 'false' ? '#fff' : '#EF4444')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .height(120)
        .backgroundColor(this.answers[question.id] === 'false' ? '#EF4444' : '#FEF2F2')
        .borderRadius(16)
        .border({ width: this.answers[question.id] === 'false' ? 2 : 1, color: this.answers[question.id] === 'false' ? '#EF4444' : '#FEE2E2' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.selectAnswer(question.id, 'false')
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  buildQuestionNavigation() {
    Row({ space: 12 }) {
      Button('上一题')
        .layoutWeight(1)
        .height(44)
        .fontSize(15)
        .fontColor('#6366F1')
        .backgroundColor('#fff')
        .borderRadius(12)
        .enabled(this.currentIndex > 0)
        .onClick(() => {
          this.goToQuestion(this.currentIndex - 1)
        })

      Button('下一题')
        .layoutWeight(1)
        .height(44)
        .fontSize(15)
        .fontColor('#fff')
        .backgroundColor('#6366F1')
        .borderRadius(12)
        .enabled(this.currentIndex < this.questions.length - 1)
        .onClick(() => {
          this.goToQuestion(this.currentIndex + 1)
        })
    }
    .width('100%')
  }

  @Builder
  buildSubmitButton() {
    Column() {
      Button(this.submitting ? '提交中...' : '提交答案')
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontColor('#fff')
        .backgroundColor('#6366F1')
        .borderRadius(12)
        .enabled(!this.submitting)
        .onClick(() => {
          this.handleSubmit()
        })
    }
    .width('100%')
    .margin({ top: 8 })
  }
}

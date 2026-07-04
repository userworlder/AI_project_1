import router from '@ohos.router'

@Entry
@Component
struct QuizResult {
  @State score: number = 0
  @State totalQuestions: number = 0
  @State correctCount: number = 0
  @State sectionId: number = 0
  @State sectionTitle: string = ''

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    this.score = (params['score'] as number) || 0
    this.totalQuestions = (params['totalQuestions'] as number) || 0
    this.correctCount = (params['correctCount'] as number) || 0
    this.sectionId = (params['sectionId'] as number) || 0
    this.sectionTitle = (params['sectionTitle'] as string) || ''
  }

  getScoreColor(score: number): string {
    if (score >= 80) return '#10B981'
    if (score >= 60) return '#F59E0B'
    return '#EF4444'
  }

  getScoreLevel(score: number): string {
    if (score >= 90) return '优秀'
    if (score >= 80) return '良好'
    if (score >= 60) return '及格'
    return '不及格'
  }

  getScoreBgColor(score: number): string {
    if (score >= 80) return '#F0FDF4'
    if (score >= 60) return '#FFFBEB'
    return '#FEF2F2'
  }

  getResultMessage(score: number): string {
    if (score >= 90) return '太棒了！继续保持！'
    if (score >= 80) return '做得不错，继续加油！'
    if (score >= 60) return '还需努力，再接再厉！'
    return '要多加复习哦！'
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      Scroll() {
        Column({ space: 20 }) {
          // 得分卡片
          this.buildScoreCard()

          // 统计信息
          this.buildStatsCard()

          // 结果评语
          this.buildResultMessage()

          // 操作按钮
          this.buildActionButtons()
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
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
          Text('答题结果')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text(this.sectionTitle || '章节测试')
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
  buildScoreCard() {
    Column({ space: 16 }) {
      // 大分数显示
      Column({ space: 8 }) {
        Text(this.score.toString())
          .fontSize(64)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getScoreColor(this.score))
          .lineHeight(72)

        Text(this.getScoreLevel(this.score))
          .fontSize(18)
          .fontColor(this.getScoreColor(this.score))
          .fontWeight(FontWeight.Medium)
      }
      .width(160)
      .height(160)
      .backgroundColor(this.getScoreBgColor(this.score))
      .borderRadius(80)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text('得分')
        .fontSize(14)
        .fontColor('#999')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildStatsCard() {
    Column({ space: 16 }) {
      Text('答题统计')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')

      Divider()
        .color('#F0F0F0')
        .width('100%')

      Row({ space: 12 }) {
        this.buildStatItem('总题数', this.totalQuestions.toString(), '#6366F1', '#EEF2FF')
        this.buildStatItem('答对', this.correctCount.toString(), '#10B981', '#F0FDF4')
        this.buildStatItem('答错', (this.totalQuestions - this.correctCount).toString(), '#EF4444', '#FEF2F2')
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  buildStatItem(label: string, value: string, color: string, bgColor: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(12)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(bgColor)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildResultMessage() {
    Column() {
      Text(this.getResultMessage(this.score))
        .fontSize(16)
        .fontColor(this.getScoreColor(this.score))
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  buildActionButtons() {
    Column({ space: 12 }) {
      Button('重新答题')
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontColor('#fff')
        .backgroundColor('#6366F1')
        .borderRadius(12)
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/QuizPage',
            params: { sectionId: this.sectionId, sectionTitle: this.sectionTitle }
          })
        })

      Button('返回课程')
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontColor('#6366F1')
        .backgroundColor('#fff')
        .borderRadius(12)
        .border({ width: 1, color: '#6366F1' })
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
  }
}

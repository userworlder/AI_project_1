import router from '@ohos.router'
import { DateUtil } from '../common/DateUtil'
import { ResumeApi } from '../http/ResumeApi'
import type { ResumeItem } from '../model/Resume'

@Entry
@Component
struct ResumeResult {
  @State resume: ResumeItem | null = null
  @State loading: boolean = true
  @State errorMsg: string = ''

  aboutToAppear() {
    this.loadResult()
  }

  async loadResult() {
    try {
      const params = router.getParams() as Record<string, number>
      const resumeId = params['resumeId']
      if (resumeId) {
        this.resume = await ResumeApi.getById(getContext(this), resumeId)
      }
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载评估结果失败'
    } finally {
      this.loading = false
    }
  }

  getScoreColor(score: number): string {
    if (score >= 80) return '#10B981'
    if (score >= 60) return '#F59E0B'
    if (score >= 40) return '#EF4444'
    return '#999'
  }

  getScoreLevel(score: number): string {
    if (score >= 90) return '优秀'
    if (score >= 80) return '良好'
    if (score >= 70) return '中等'
    if (score >= 60) return '一般'
    return '待优化'
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
            Text('评估结果')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
            Text(this.resume ? this.resume.title : '')
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

      if (this.loading) {
        Column() {
          Text('加载中...').fontSize(16).fontColor('#999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.resume) {
        Scroll() {
          Column({ space: 16 }) {
            // 评分卡
            this.buildScoreCard()

            // 评估结果
            if (this.resume.evaluation) {
              this.buildSectionCard('📋 整体评价', this.resume.evaluation, false)
            }

            // 优势
            if (this.resume.strengths) {
              this.buildSectionCard('✅ 优势分析', this.resume.strengths, true)
            }

            // 优化建议
            if (this.resume.suggestions) {
              this.buildSectionCard('💡 优化建议', this.resume.suggestions, true)
            }

            // 原始简历
            this.buildSectionCard('📄 原始简历', this.resume.content, false)
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 20, bottom: 24 })
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        Column() {
          Text(this.errorMsg || '未找到评估结果')
            .fontSize(16)
            .fontColor('#999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  buildScoreCard() {
    Column({ space: 12 }) {
      Row() {
        Text(this.resume?.title || '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(DateUtil.formatDateTime(this.resume?.createTime || ''))
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')

      Divider().color('#F0F0F0').width('100%')

      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text((this.resume?.score || 0).toString())
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getScoreColor(this.resume?.score || 0))
          Text(this.getScoreLevel(this.resume?.score || 0))
            .fontSize(14)
            .fontColor(this.getScoreColor(this.resume?.score || 0))
        }
        .alignItems(HorizontalAlign.Center)

        Divider()
          .color('#F0F0F0')
          .height(60)
          .vertical(true)

        Column({ space: 6 }) {
          this.buildScoreBar('专业知识', this.resume?.score || 0)
          this.buildScoreBar('项目经验', Math.min((this.resume?.score || 0) + 5, 100))
          this.buildScoreBar('综合表现', this.resume?.score || 0)
        }
        .layoutWeight(1)
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
  buildScoreBar(label: string, value: number) {
    Column({ space: 2 }) {
      Row() {
        Text(label).fontSize(12).fontColor('#999')
        Blank()
        Text(`${value}`).fontSize(12).fontColor('#666')
      }
      .width('100%')

      Row() {
        Row() {
          Text('')
            .width('100%')
            .height(6)
        }
        .width(value + '%')
        .backgroundColor('#6366F1')
        .borderRadius(3)
      }
      .width('100%')
      .height(6)
      .backgroundColor('#F0F0F0')
      .borderRadius(3)
    }
    .width('100%')
  }

  @Builder
  buildSectionCard(iconTitle: string, content: string, isList: boolean) {
    Column({ space: 10 }) {
      Text(iconTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')

      Divider().color('#F0F0F0').width('100%')

      Text(content)
        .fontSize(14)
        .fontColor('#333')
        .lineHeight(22)
        .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }
}

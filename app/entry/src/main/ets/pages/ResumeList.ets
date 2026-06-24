import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import { DateUtil } from '../common/DateUtil'
import { ResumeApi } from '../http/ResumeApi'
import type { ResumeItem } from '../model/Resume'
import type { UserInfo } from '../model/User'

@Entry
@Component
struct ResumeList {
  @State resumes: ResumeItem[] = []
  @State loading: boolean = true
  @State errorMsg: string = ''
  private userId: number = 0

  aboutToAppear() {
    this.loadResumes()
  }

  async loadResumes() {
    this.loading = true
    try {
      const userInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
      if (userInfo) {
        this.userId = userInfo.id
        this.resumes = await ResumeApi.getByUser(getContext(this), userInfo.id)
      }
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载失败'
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

  getStatusLabel(status: string): string {
    if (status === 'completed') return '已完成'
    if (status === 'evaluating') return '评估中'
    if (status === 'failed') return '评估失败'
    return '待评估'
  }

  getStatusColor(status: string): string {
    if (status === 'completed') return '#10B981'
    if (status === 'evaluating') return '#F59E0B'
    if (status === 'failed') return '#EF4444'
    return '#999'
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
            Text('AI 智能分析简历，优化建议')
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

      // 内容
      if (this.loading) {
        Column() {
          Text('加载中...').fontSize(16).fontColor('#999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.resumes.length === 0) {
        Column({ space: 12 }) {
          Text('📄').fontSize(64)
          Text('暂无简历评估记录').fontSize(16).fontColor('#999')
          Text('点击下方按钮开始评估').fontSize(14).fontColor('#ccc')

          Button('新建评估')
            .width(200)
            .height(44)
            .backgroundColor('#6366F1')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(22)
            .margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/ResumeEditor' })
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(`共 ${this.resumes.length} 份简历评估`)
              .fontSize(13)
              .fontColor('#999')
              .width('100%')

            ForEach(this.resumes, (item: ResumeItem) => {
              this.buildResumeCard(item)
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 20, bottom: 24 })
        }
        .layoutWeight(1)
        .width('100%')
      }

      // 底部新建按钮
      Button('+ 新建评估')
        .width('90%')
        .height(50)
        .backgroundColor('#6366F1')
        .fontColor('#fff')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(12)
        .shadow({ radius: 12, color: 'rgba(99,102,241,0.4)', offsetY: 4 })
        .margin({ bottom: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/ResumeEditor' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  buildResumeCard(item: ResumeItem) {
    Column({ space: 8 }) {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (item.score > 0) {
          Text(`${item.score}分`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getScoreColor(item.score))
        }
      }
      .width('100%')

      Text(item.content)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(20)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Divider().color('#F0F0F0').width('100%')

      Row() {
        Text(this.getStatusLabel(item.status))
          .fontSize(12)
          .fontColor('#fff')
          .backgroundColor(this.getStatusColor(item.status))
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })

        Blank()

        Text(DateUtil.formatDateTime(item.createTime))
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ResumeResult',
        params: { resumeId: item.id }
      })
    })
  }
}

import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import { DashboardApi } from '../http/DashboardApi'
import type { UserInfo, DashboardStats } from '../model/User'

@Entry
@Component
struct Home {
  @State username: string = ''
  @State nickname: string = ''
  @State stats: DashboardStats | null = null
  @State statsLoading: boolean = true

  aboutToAppear() {
    this.loadUserInfo()
    this.loadStats()
  }

  async loadUserInfo() {
    try {
      const userInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
      if (userInfo) {
        this.username = userInfo.username
        this.nickname = userInfo.nickname || userInfo.username
      }
    } catch (error) {
      console.error('加载用户信息失败:', error)
    }
  }

  async loadStats() {
    try {
      this.stats = await DashboardApi.getStats(getContext(this))
    } catch (error) {
      console.error('加载统计数据失败:', error)
    } finally {
      this.statsLoading = false
    }
  }

  build() {
    Column() {
      // ===== 顶部用户区域 =====
      Column() {
        Row({ space: 16 }) {
          // 头像
          Column() {
            Text(this.nickname.length > 0 ? this.nickname.substring(0, 1).toUpperCase() : 'U')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
          }
          .width(60)
          .height(60)
          .borderRadius(30)
          .backgroundColor('#6366F1')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 4 }) {
            Text(`你好，${this.nickname || this.username}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
            Text('今天也要加油学习哦！')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
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

      // ===== 统计卡片和功能菜单（可滚动）=====
      Scroll() {
        Column() {
          if (!this.statsLoading && this.stats) {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                this.createStatCard('总用户', this.stats.totalUsers.toString(), '#6366F1', 'rgba(99,102,241,0.1)')
                this.createStatCard('学习时长', `${this.stats.totalLearningHours}h`, '#14B8A6', 'rgba(20,184,166,0.1)')
              }
              .width('100%')

              Row({ space: 12 }) {
                this.createStatCard('AI交互', this.stats.aiInteractions.toString(), '#10B981', 'rgba(16,185,129,0.1)')
                this.createStatCard('活跃用户', this.stats.activeUsers.toString(), '#F59E0B', 'rgba(245,158,11,0.1)')
              }
              .width('100%')
            }
            .padding({ left: 24, right: 24, top: 20 })
          }

          // ===== 功能菜单 =====
          Column({ space: 16 }) {
            Row().width('100%').height(16)

            Text('功能入口')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('100%')
              .padding({ left: 4 })

            this.createMenuItem(
              'AI 智能对话',
              '与大模型 AI 对话，解答学习问题',
              '#6366F1',
              () => { router.pushUrl({ url: 'pages/Chat' }) }
            )

            this.createMenuItem(
              '我的名片',
              '编辑个人资料和展示信息',
              '#14B8A6',
              () => { router.pushUrl({ url: 'pages/Card' }) }
            )

            this.createMenuItem(
              '个人中心',
              '查看账号信息与系统设置',
              '#F59E0B',
              () => { router.pushUrl({ url: 'pages/Profile' }) }
            )

            this.createMenuItem(
              '技能树',
              '浏览学习技能体系',
              '#8B5CF6',
              () => { router.pushUrl({ url: 'pages/SkillTree' }) }
            )

            this.createMenuItem(
              '学习记录',
              '查看学习历史记录',
              '#EC4899',
              () => { router.pushUrl({ url: 'pages/StudyRecords' }) }
            )

            this.createMenuItem(
              '简历评估',
              'AI 智能分析简历，优化建议',
              '#10B981',
              () => { router.pushUrl({ url: 'pages/ResumeList' }) }
            )
          }
          .width('100%')
          .padding({ left: 24, right: 24 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // ===== 底部导航 =====
      Row({ space: 8 }) {
        this.createTabItem('首页', '#6366F1', true, null)
        this.createTabItem('聊天', '#999', false, () => { router.pushUrl({ url: 'pages/Chat' }) })
        this.createTabItem('我的', '#999', false, () => { router.pushUrl({ url: 'pages/Profile' }) })
      }
      .width('100%')
      .height(64)
      .padding({ left: 24, right: 24 })
      .backgroundColor('#fff')
      .justifyContent(FlexAlign.SpaceAround)
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.08)',
        offsetY: -2
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  createStatCard(label: string, value: string, color: string, bgColor: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(13)
        .fontColor('#999')
        .margin({ top: 4 })
    }
    .width('50%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  createMenuItem(title: string, desc: string, color: string, onClick: () => void) {
    Row({ space: 16 }) {
      Row() {
        Text(title.substring(0, 1))
          .fontSize(20)
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(color)
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Text(desc)
          .fontSize(13)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(22)
        .fontColor('#ccc')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .onClick(() => { onClick() })
  }

  @Builder
  createTabItem(label: string, color: string, active: boolean, onClick: (() => void) | null) {
    Column({ space: 4 }) {
      Text('●')
        .fontSize(active ? 8 : 6)
        .fontColor(color)
        .opacity(active ? 1 : 0.3)
      Text(label)
        .fontSize(12)
        .fontColor(color)
        .fontWeight(active ? FontWeight.Bold : FontWeight.Regular)
    }
    .onClick(() => {
      if (onClick) onClick()
    })
  }
}

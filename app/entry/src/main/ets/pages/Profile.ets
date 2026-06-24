import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import type { UserInfo } from '../model/User'

@Entry
@Component
struct Profile {
  @State userInfo: UserInfo | null = null
  @State loading: boolean = false
  @State errorMsg: string = ''

  aboutToAppear() {
    this.loadUserInfo()
  }

  async loadUserInfo() {
    try {
      this.userInfo = (await TokenUtil.getUserInfo(getContext(this))) || null
    } catch (error) {
      console.error('加载用户信息失败:', error)
    }
  }

  getRoleLabel(role: string): string {
    if (role === 'admin') {
      return '管理员'
    }
    if (role === 'teacher') {
      return '教师'
    }
    if (role === 'student') {
      return '学生'
    }
    return role
  }

  async handleLogout() {
    this.loading = true
    try {
      await TokenUtil.clearAll(getContext(this))
      router.replaceUrl({ url: 'pages/Login' })
    } catch (error) {
      this.errorMsg = (error as Error).message || '退出登录失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      // ===== 顶部导航栏 =====
      Row() {
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
            .onClick(() => { router.back() })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)

        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
          .layoutWeight(1)

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .position({ x: 0, y: 0 })
      .zIndex(1)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
      })

      // ===== 顶部用户信息 =====
      Column({ space: 12 }) {
        Column() {
          Text(this.userInfo?.nickname?.substring(0, 1).toUpperCase()
            || this.userInfo?.username?.substring(0, 1).toUpperCase() || 'U')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
        }
        .width(80)
        .height(80)
        .borderRadius(40)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
        })
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 4 })

        Text(this.userInfo?.nickname || this.userInfo?.username || '用户')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')

        if (this.userInfo?.email) {
          Text(this.userInfo.email)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.7)')
        }

        if (this.userInfo?.phone) {
          Text(this.userInfo.phone)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.7)')
        }
      }
      .width('100%')
      .padding({ top: 60, bottom: 30 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
      })
      .margin({ top: 56 })

      // ===== 菜单列表 =====
      Column({ space: 0 }) {
        this.createMenuItem('修改密码', 'security', () => {
          router.pushUrl({ url: 'pages/ChangePassword' })
        })
        this.createDivider()
        this.createMenuItem('个人资料', 'profile', () => {
          router.pushUrl({ url: 'pages/EditProfile' })
        })
        this.createDivider()
        this.createMenuItem('系统设置', 'settings', () => {
          // 系统设置（预留）
        })
      }
      .width('90%')
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      .margin({ top: 24 })

      // 账号信息卡片
      Column({ space: 12 }) {
        Text('账号信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        if (this.userInfo && this.userInfo.username) {
          this.createInfoRow('用户名', this.userInfo.username)
          if (this.userInfo.role) {
            this.createInfoRow('角色', this.getRoleLabel(this.userInfo.role))
          }
          if (this.userInfo.createTime) {
            this.createInfoRow('注册时间', this.userInfo.createTime.substring(0, 10))
          }
        }
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      .margin({ top: 16 })
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 退出按钮
      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#EF4444')
      }

      Button(this.loading ? '退出中...' : '退出登录')
        .width('90%')
        .height(50)
        .backgroundColor('#fff')
        .fontColor('#EF4444')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(12)
        .border({ width: 1, color: '#FFE4E4' })
        .enabled(!this.loading)
        .onClick(() => {
          AlertDialog.show({
            title: '确认退出',
            message: '确定要退出登录吗？',
            primaryButton: {
              value: '取消',
              action: () => {}
            },
            confirm: {
              value: '退出',
              action: () => { this.handleLogout() }
            }
          })
        })
        .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  createMenuItem(label: string, icon: string, onClick: () => void) {
    Row({ space: 12 }) {
      Row() {
        Text(icon === 'security' ? '🔒' : icon === 'profile' ? '👤' : '⚙️')
          .fontSize(18)
      }
      .width(36)
      .height(36)

      Text(label)
        .fontSize(16)
        .fontColor('#333')

      Blank()

      Text('›')
        .fontSize(20)
        .fontColor('#ccc')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(() => { onClick() })
  }

  @Builder
  createDivider() {
    Divider()
      .width('92%')
      .color('#F0F0F0')
      .margin(0)
  }

  @Builder
  createInfoRow(label: string, value: string) {
    Row({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#999')
      Text(value)
        .fontSize(14)
        .fontColor('#333')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

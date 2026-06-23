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
      this.userInfo = await TokenUtil.getUserInfo(getContext(this))
    } catch (error) {
      console.error('加载用户信息失败:', error)
    }
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
        .background(
          new LinearGradient([{ color: '#6366F1' }, { color: '#818CF8' }])
        )
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
      .background(
        new LinearGradient([{ color: '#6366F1' }, { color: '#818CF8' }])
      )

      // ===== 菜单列表 =====
      Column({ space: 0 }) {
        this.createMenuItem('修改密码', 'security', () => {})
        this.createDivider()
        this.createMenuItem('个人资料', 'profile', () => {})
        this.createDivider()
        this.createMenuItem('系统设置', 'settings', () => {})
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

        if (this.userInfo) {
          this.createInfoRow('用户名', this.userInfo.username)
          if (this.userInfo.role) {
            const roleMap: Record<string, string> = { admin: '管理员', teacher: '教师', student: '学生' }
            this.createInfoRow('角色', roleMap[this.userInfo.role] || this.userInfo.role)
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

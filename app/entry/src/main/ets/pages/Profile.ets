import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'

@Entry
@Component
struct Profile {
  @State username: string = ''
  @State phone: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''

  aboutToAppear() {
    this.loadUserInfo()
  }

  async loadUserInfo() {
    try {
      const userInfo = await TokenUtil.getUserInfo(getContext(this))
      if (userInfo) {
        this.username = userInfo.username
        this.phone = userInfo.phone || ''
      }
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
    Column({ space: 20 }) {
      Column({ space: 16 }) {
        Image($r('app.media.startIcon'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor('#f0f0f0')

        Text(this.username)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Text(this.phone)
          .fontSize(16)
          .fontColor('#666')
      }
      .width('100%')
      .padding({ top: 60, bottom: 30 })

      Column({ space: 0 }) {
        Row() {
          Text('修改密码')
            .fontSize(18)
            .fontColor('#333')
          Blank()
          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
        }
        .width('90%')
        .height(50)
        .padding({ left: 16 })
        .backgroundColor('#fff')

        Divider()
          .width('90%')
          .color('#f0f0f0')

        Row() {
          Text('个人资料')
            .fontSize(18)
            .fontColor('#333')
          Blank()
          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
        }
        .width('90%')
        .height(50)
        .padding({ left: 16 })
        .backgroundColor('#fff')

        Divider()
          .width('90%')
          .color('#f0f0f0')

        Row() {
          Text('设置')
            .fontSize(18)
            .fontColor('#333')
          Blank()
          Image($r('app.media.foreground'))
            .width(24)
            .height(24)
        }
        .width('90%')
        .height(50)
        .padding({ left: 16 })
        .backgroundColor('#fff')
      }

      Blank()

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#ff4d4f')
      }

      Button(this.loading ? '退出中...' : '退出登录')
        .width('80%')
        .height(50)
        .backgroundColor('#ff4d4f')
        .fontColor('#fff')
        .borderRadius(8)
        .enabled(!this.loading)
        .onClick(() => {
          this.handleLogout()
        })
        .padding({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

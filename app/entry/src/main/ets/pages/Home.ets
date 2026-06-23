import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'

@Entry
@Component
struct Home {
  @State username: string = ''

  aboutToAppear() {
    this.loadUsername()
  }

  async loadUsername() {
    try {
      const username = await TokenUtil.getUsername(getContext(this))
      if (username) {
        this.username = username
      }
    } catch (error) {
      console.error('加载用户名失败:', error)
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('欢迎回来')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      if (this.username) {
        Text(`您好，${this.username}`)
          .fontSize(20)
          .fontColor('#666')
      }

      Column({ space: 16 }) {
        Button('AI智能对话')
          .width('80%')
          .height(50)
          .backgroundColor('#409EFF')
          .fontColor('#fff')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Chat' })
          })

        Button('我的名片')
          .width('80%')
          .height(50)
          .backgroundColor('#007bff')
          .fontColor('#fff')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Card' })
          })

        Button('个人中心')
          .width('80%')
          .height(50)
          .backgroundColor('#6c757d')
          .fontColor('#fff')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Profile' })
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f5f5f5')
    .padding(24)
  }
}

import router from '@ohos.router'

@Entry
@Component
struct Card {
  @State isEditing: boolean = false
  @State name: string = '张小明'
  @State job: string = '前端开发工程师'
  @State introduction: string = '热爱编程，专注于前端技术，喜欢探索新技术。'

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

        Text('我的名片')
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

      // 顶部渐变背景
      Column() {
        Column({ space: 16 }) {
          // 头像
          Column() {
            Text('张')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
          }
          .width(100)
          .height(100)
          .borderRadius(50)
          .backgroundColor('rgba(255,255,255,0.2)')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 40 })

          if (this.isEditing) {
            TextInput({ text: this.name })
              .onChange((value: string) => { this.name = value })
              .width(200)
              .height(44)
              .backgroundColor('rgba(255,255,255,0.9)')
              .borderRadius(8)
              .padding({ left: 16 })
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .fontColor('#333')

            TextInput({ text: this.job })
              .onChange((value: string) => { this.job = value })
              .width(200)
              .height(40)
              .backgroundColor('rgba(255,255,255,0.9)')
              .borderRadius(8)
              .padding({ left: 16 })
              .fontSize(18)
              .fontColor('#666')
              .textAlign(TextAlign.Center)
          } else {
            Text(this.name)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')

            Text(this.job)
              .fontSize(18)
              .fontColor('rgba(255,255,255,0.8)')
              .margin({ top: -4 })
          }
        }
        .width('100%')
        .padding({ bottom: 40 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
      })
      .margin({ top: 56 })

      // 简介区域
      Column({ space: 16 }) {
        Text('个人简介')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .width('100%')

        if (this.isEditing) {
          TextArea({ text: this.introduction })
            .onChange((value: string) => { this.introduction = value })
            .width('100%')
            .height(120)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding(16)
            .fontSize(16)
            .fontColor('#666')
        } else {
          Text(this.introduction)
            .fontSize(16)
            .fontColor('#666')
            .lineHeight(24)
            .width('100%')
        }
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      .margin({ top: -20, bottom: 24 })

      // 编辑/保存按钮
      Button(this.isEditing ? '保存修改' : '编辑资料')
        .width('90%')
        .height(50)
        .backgroundColor(this.isEditing ? '#10B981' : '#6366F1')
        .fontColor('#fff')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .borderRadius(12)
        .shadow({
          radius: 12,
          color: this.isEditing ? 'rgba(16,185,129,0.4)' : 'rgba(99,102,241,0.4)',
          offsetY: 4
        })
        .onClick(() => {
          this.isEditing = !this.isEditing
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}

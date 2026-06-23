@Entry
@Component
struct Card {
  @State isEditing: boolean = false
  @State name: string = '张小明'
  @State job: string = '前端开发工程师'
  @State introduction: string = '热爱编程，专注于前端技术，喜欢探索新技术。'

  build() {
    Column() {
      Column({ space: 20 }) {
        Image($r('app.media.startIcon'))
          .width(120)
          .height(120)
          .borderRadius(60)
          .backgroundColor('#f0f0f0')

        if (this.isEditing) {
          TextInput({ text: this.name })
            .onChange((value: string) => {
              this.name = value
            })
            .width(200)
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .padding({ left: 12 })
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          TextInput({ text: this.job })
            .onChange((value: string) => {
              this.job = value
            })
            .width(200)
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .padding({ left: 12 })
            .fontSize(18)
            .fontColor('#666')
            .textAlign(TextAlign.Center)
        } else {
          Text(this.name)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')

          Text(this.job)
            .fontSize(20)
            .fontColor('#666')
            .margin({ top: -8 })
        }

        Text(this.introduction)
          .fontSize(16)
          .fontColor('#888')
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .width('80%')

        Button(this.isEditing ? '保存' : '编辑')
          .width(120)
          .height(44)
          .backgroundColor('#007bff')
          .fontColor('#fff')
          .borderRadius(22)
          .onClick(() => {
            this.isEditing = !this.isEditing
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}

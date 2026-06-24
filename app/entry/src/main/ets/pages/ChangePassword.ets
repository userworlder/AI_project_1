import router from '@ohos.router'
import { UserApi } from '../http/UserApi'

@Entry
@Component
struct ChangePassword {
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State saving: boolean = false
  @State errorMsg: string = ''
  @State successMsg: string = ''

  async handleSubmit() {
    // 验证
    if (!this.oldPassword) {
      this.errorMsg = '请输入原密码'
      return
    }
    if (!this.newPassword) {
      this.errorMsg = '请输入新密码'
      return
    }
    if (this.newPassword.length < 6) {
      this.errorMsg = '新密码长度不能少于6位'
      return
    }
    if (this.newPassword !== this.confirmPassword) {
      this.errorMsg = '两次输入的新密码不一致'
      return
    }

    this.saving = true
    this.errorMsg = ''
    this.successMsg = ''

    try {
      await UserApi.changePassword(getContext(this), {
        oldPassword: this.oldPassword,
        newPassword: this.newPassword
      })
      this.successMsg = '密码修改成功'
      // 延迟返回
      setTimeout(() => {
        router.back()
      }, 1500)
    } catch (error) {
      this.errorMsg = (error as Error).message || '密码修改失败'
    } finally {
      this.saving = false
    }
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 表单区域 =====
      Scroll() {
        Column({ space: 16 }) {
          // 表单卡片
          Column({ space: 0 }) {
            this.buildPasswordItem('原密码', this.oldPassword, (value: string) => { this.oldPassword = value }, '请输入原密码')
            this.buildDivider()
            this.buildPasswordItem('新密码', this.newPassword, (value: string) => { this.newPassword = value }, '至少6位字符')
            this.buildDivider()
            this.buildPasswordItem('确认新密码', this.confirmPassword, (value: string) => { this.confirmPassword = value }, '再次输入新密码')
          }
          .width('100%')
          .backgroundColor('#fff')
          .borderRadius(16)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

          // 提示
          Column({ space: 6 }) {
            Text('• 新密码长度不少于6位')
              .fontSize(13)
              .fontColor('#999')
            Text('• 请勿使用与其他网站相同的密码')
              .fontSize(13)
              .fontColor('#999')
          }
          .width('100%')
          .padding({ left: 4 })

          // 错误/成功消息
          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontSize(14)
              .fontColor('#EF4444')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }
          if (this.successMsg) {
            Text(this.successMsg)
              .fontSize(14)
              .fontColor('#10B981')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }

          // 提交按钮
          Button(this.saving ? '提交中...' : '确认修改')
            .width('100%')
            .height(50)
            .backgroundColor('#6366F1')
            .fontColor('#fff')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .shadow({ radius: 12, color: 'rgba(99,102,241,0.4)', offsetY: 4 })
            .enabled(!this.saving)
            .onClick(() => {
              this.handleSubmit()
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 40 })
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

        Text('修改密码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
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
  buildPasswordItem(label: string, value: string, onChange: (value: string) => void, placeholder: string) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#999')
        .width('100%')
        .margin({ top: 12 })

      TextInput({ text: value, placeholder: placeholder })
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#333')
        .backgroundColor('#fff')
        .type(InputType.Password)
        .onChange((val: string) => { onChange(val) })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ bottom: 8 })
  }

  @Builder
  buildDivider() {
    Divider()
      .color('#F0F0F0')
      .width('92%')
      .margin({ left: 16 })
  }
}

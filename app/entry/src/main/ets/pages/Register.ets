import router from '@ohos.router'
import { AuthApi } from '../http/AuthApi'
import type { RegisterRequest } from '../model/User'

@Entry
@Component
struct Register {
  @State username: string = ''
  @State nickname: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''
  @State step: number = 1

  async handleRegister() {
    // 第一步验证
    if (this.step === 1) {
      if (!this.username || !this.password || !this.confirmPassword) {
        this.errorMsg = '请填写必填字段'
        return
      }
      if (this.password !== this.confirmPassword) {
        this.errorMsg = '两次输入的密码不一致'
        return
      }
      if (this.password.length < 6) {
        this.errorMsg = '密码长度至少6位'
        return
      }
      this.errorMsg = ''
      this.step = 2
      return
    }

    this.loading = true
    this.errorMsg = ''

    try {
      const registerData: RegisterRequest = {
        username: this.username,
        password: this.password,
        confirmPassword: this.confirmPassword,
        nickname: this.nickname || this.username,
        email: this.email || undefined,
        phone: this.phone || undefined
      }
      await AuthApi.register(getContext(this), registerData)

      AlertDialog.show({
        title: '注册成功',
        message: '账号注册成功，请登录',
        confirm: {
          value: '去登录',
          action: () => {
            router.replaceUrl({ url: 'pages/Login' })
          }
        }
      })
    } catch (error) {
      this.errorMsg = (error as Error).message || '注册失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      // 顶部
      Column() {
        Text('创建账号')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Text(this.step === 1 ? '填写账号信息' : '完善个人资料（选填）')
          .fontSize(15)
          .fontColor('rgba(255,255,255,0.7)')
          .margin({ top: 8 })

        // 步骤指示器
        Row({ space: 8 }) {
          Row() {
            Text('1')
              .fontSize(12)
              .fontColor(this.step >= 1 ? '#6366F1' : '#fff')
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(this.step >= 1 ? '#fff' : 'rgba(255,255,255,0.3)')
          .justifyContent(FlexAlign.Center)

          Row() {
            Text('2')
              .fontSize(12)
              .fontColor(this.step >= 2 ? '#6366F1' : '#fff')
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(this.step >= 2 ? '#fff' : 'rgba(255,255,255,0.3)')
          .justifyContent(FlexAlign.Center)
        }
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ top: 60, bottom: 30 })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 1.0]]
      })

      // 表单区域（可滚动）
      Scroll() {
        Column({ space: 16 }) {
        if (this.step === 1) {
          // 第一步：账号信息
          TextInput({ placeholder: '用户名 *', text: this.username })
            .onChange((value: string) => { this.username = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)

          TextInput({ placeholder: '密码 *' })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => { this.password = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)

          TextInput({ placeholder: '确认密码 *' })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => { this.confirmPassword = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)
        } else {
          // 第二步：个人资料
          TextInput({ placeholder: '昵称', text: this.nickname })
            .onChange((value: string) => { this.nickname = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)

          TextInput({ placeholder: '邮箱', text: this.email })
            .type(InputType.Email)
            .onChange((value: string) => { this.email = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)

          TextInput({ placeholder: '手机号', text: this.phone })
            .type(InputType.PhoneNumber)
            .onChange((value: string) => { this.phone = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)
        }

        // 错误信息
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#EF4444')
            .width('100%')
        }

        // 按钮
        Button(this.loading ? '处理中...' : (this.step === 1 ? '下一步' : '完成注册'))
          .width('100%')
          .height(50)
          .backgroundColor('#6366F1')
          .fontColor('#fff')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(12)
          .enabled(!this.loading)
          .shadow({ radius: 12, color: 'rgba(99,102,241,0.4)', offsetY: 4 })
          .onClick(() => { this.handleRegister() })

        // 返回登录
        Row({ space: 4 }) {
          Text('已有账号？')
            .fontSize(15)
            .fontColor('#999')
          Text('立即登录')
            .fontSize(15)
            .fontColor('#6366F1')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Login' })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: 32, right: 32, top: 32, bottom: 40 })
      .background('#fff')
      .borderRadius({ topLeft: 24, topRight: 24 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}

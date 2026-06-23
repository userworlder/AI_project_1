import router from '@ohos.router'
import { AuthApi } from '../http/AuthApi'
import type { RegisterRequest } from '../model/User'

@Entry
@Component
struct Register {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State phone: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''

  async handleRegister() {
    if (!this.username || !this.password || !this.confirmPassword || !this.phone) {
      this.errorMsg = '请填写所有字段'
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

    this.loading = true
    this.errorMsg = ''

    try {
      const registerData: RegisterRequest = {
        username: this.username,
        password: this.password,
        confirmPassword: this.confirmPassword,
        phone: this.phone
      }
      await AuthApi.register(getContext(this), registerData)

      router.replaceUrl({ url: 'pages/Login' })
    } catch (error) {
      this.errorMsg = (error as Error).message || '注册失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('注册')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      TextInput({ placeholder: '用户名' })
        .onChange((value: string) => {
          this.username = value
        })
        .width('80%')
        .height(50)
        .backgroundColor('#fff')
        .borderRadius(8)
        .padding({ left: 16 })
        .fontSize(18)

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value
        })
        .width('80%')
        .height(50)
        .backgroundColor('#fff')
        .borderRadius(8)
        .padding({ left: 16 })
        .fontSize(18)

      TextInput({ placeholder: '确认密码' })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.confirmPassword = value
        })
        .width('80%')
        .height(50)
        .backgroundColor('#fff')
        .borderRadius(8)
        .padding({ left: 16 })
        .fontSize(18)

      TextInput({ placeholder: '手机号' })
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.phone = value
        })
        .width('80%')
        .height(50)
        .backgroundColor('#fff')
        .borderRadius(8)
        .padding({ left: 16 })
        .fontSize(18)

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#ff4d4f')
      }

      Button(this.loading ? '注册中...' : '注册')
        .width('80%')
        .height(50)
        .backgroundColor('#007bff')
        .fontColor('#fff')
        .borderRadius(8)
        .enabled(!this.loading)
        .onClick(() => {
          this.handleRegister()
        })

      Row({ space: 8 }) {
        Text('已有账号？')
          .fontSize(16)
          .fontColor('#666')
        Text('立即登录')
          .fontSize(16)
          .fontColor('#007bff')
          .onClick(() => {
            router.replaceUrl({ url: 'pages/Login' })
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

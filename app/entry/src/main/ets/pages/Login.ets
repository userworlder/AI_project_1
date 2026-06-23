import router from '@ohos.router'
import { AuthApi } from '../http/AuthApi'
import { TokenUtil } from '../common/TokenUtil'
import type { LoginRequest } from '../model/User'

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State rememberMe: boolean = false
  @State loading: boolean = false
  @State errorMsg: string = ''

  aboutToAppear() {
    this.loadRememberedAccount()
  }

  async loadRememberedAccount() {
    try {
      const account = await TokenUtil.getRememberedAccount(getContext(this))
      if (account) {
        this.username = account.username
        this.password = account.password
        this.rememberMe = true
      }
    } catch (error) {
      console.error('加载记住的账号失败:', error)
    }
  }

  async handleLogin() {
    if (!this.username || !this.password) {
      this.errorMsg = '请输入用户名和密码'
      return
    }

    this.loading = true
    this.errorMsg = ''

    try {
      const loginData: LoginRequest = {
        username: this.username,
        password: this.password
      }
      const response = await AuthApi.login(getContext(this), loginData)

      await TokenUtil.saveToken(getContext(this), response.token)
      await TokenUtil.saveUserInfo(getContext(this), response.user)

      if (this.rememberMe) {
        await TokenUtil.saveRememberedAccount(getContext(this), this.username, this.password)
      } else {
        await TokenUtil.saveRememberedAccount(getContext(this), '', '')
      }

      router.replaceUrl({ url: 'pages/Home' })
    } catch (error) {
      this.errorMsg = (error as Error).message || '登录失败'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('AI 伴学平台')
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

      Row({ space: 12 }) {
        Checkbox({ name: 'remember', group: 'login' })
          .select(this.rememberMe)
          .onChange((value: boolean) => {
            this.rememberMe = value
          })
        Text('记住密码')
          .fontSize(16)
          .fontColor('#666')
      }
      .width('80%')
      .justifyContent(FlexAlign.Start)

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#ff4d4f')
      }

      Button(this.loading ? '登录中...' : '登录')
        .width('80%')
        .height(50)
        .backgroundColor('#007bff')
        .fontColor('#fff')
        .borderRadius(8)
        .enabled(!this.loading)
        .onClick(() => {
          this.handleLogin()
        })

      Row({ space: 8 }) {
        Text('还没有账号？')
          .fontSize(16)
          .fontColor('#666')
        Text('立即注册')
          .fontSize(16)
          .fontColor('#007bff')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Register' })
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

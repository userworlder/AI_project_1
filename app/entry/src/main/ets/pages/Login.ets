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
      if (account && account.username) {
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
    Column() {
      // ===== 顶部渐变背景 =====
      Column() {
        Column({ space: 8 }) {
          // Logo 图标
          Column() {
            Text('AI')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
          }
          .width(80)
          .height(80)
          .borderRadius(20)
          .backgroundColor('rgba(255,255,255,0.2)')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 16 })

          Text('AI 伴学平台')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')

          Text('智能学习，从这里开始')
            .fontSize(15)
            .fontColor('rgba(255,255,255,0.7)')
        }
        .width('100%')
        .padding({ top: 80, bottom: 40 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#6366F1', 0.0], ['#818CF8', 0.5], ['#A5B4FC', 1.0]]
      })

      // ===== 表单区域（可滚动）=====
      Scroll() {
        Column({ space: 20 }) {
        // 用户名输入
        Column({ space: 8 }) {
          Text('用户名')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')
          TextInput({ placeholder: '请输入用户名', text: this.username })
            .onChange((value: string) => { this.username = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)
        }

        // 密码输入
        Column({ space: 8 }) {
          Text('密码')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')
          TextInput({ placeholder: '请输入密码' })
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange((value: string) => { this.password = value })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)
        }

        // 记住我
        Row({ space: 8 }) {
          Checkbox({ name: 'remember' })
            .select(this.rememberMe)
            .onChange((value: boolean) => { this.rememberMe = value })
            .width(20)
            .height(20)
            .mark({
              strokeColor: '#fff',
              size: 12
            })
          Text('记住密码')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // 错误信息
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#EF4444')
            .width('100%')
            .padding({ left: 4 })
        }

        // 登录按钮
        Button(this.loading ? '登录中...' : '登 录')
          .width('100%')
          .height(50)
          .backgroundColor('#6366F1')
          .fontColor('#fff')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(12)
          .enabled(!this.loading)
          .shadow({ radius: 12, color: 'rgba(99,102,241,0.4)', offsetY: 4 })
          .onClick(() => { this.handleLogin() })

        // 注册链接
        Row({ space: 4 }) {
          Text('还没有账号？')
            .fontSize(15)
            .fontColor('#999')
          Text('立即注册')
            .fontSize(15)
            .fontColor('#6366F1')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.pushUrl({ url: 'pages/Register' })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
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

import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import { UserApi } from '../http/UserApi'
import type { UserInfo, UpdateUserRequest } from '../model/User'

@Entry
@Component
struct EditProfile {
  @State nickname: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State userId: number = 0
  @State loading: boolean = false
  @State saving: boolean = false
  @State errorMsg: string = ''
  @State successMsg: string = ''

  aboutToAppear() {
    this.loadUserInfo()
  }

  async loadUserInfo() {
    this.loading = true
    try {
      const userInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
      if (userInfo) {
        this.userId = userInfo.id
        this.nickname = userInfo.nickname || ''
        this.email = userInfo.email || ''
        this.phone = userInfo.phone || ''
      }
    } catch (error) {
      this.errorMsg = '加载用户信息失败'
    } finally {
      this.loading = false
    }
  }

  async handleSave() {
    // 验证
    if (this.email && !this.isValidEmail(this.email)) {
      this.errorMsg = '邮箱格式不正确'
      return
    }

    this.saving = true
    this.errorMsg = ''
    this.successMsg = ''

    try {
      const data: UpdateUserRequest = {}
      if (this.nickname) data.nickname = this.nickname
      if (this.email) data.email = this.email
      if (this.phone) data.phone = this.phone

      const updatedUser = await UserApi.updateUser(getContext(this), this.userId, data) as UserInfo

      // 更新本地存储的用户信息
      const currentInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
      if (currentInfo) {
        const mergedInfo: UserInfo = {
          id: currentInfo.id,
          username: currentInfo.username,
          nickname: updatedUser.nickname || currentInfo.nickname,
          email: updatedUser.email || currentInfo.email,
          phone: updatedUser.phone || currentInfo.phone,
          avatar: currentInfo.avatar,
          role: currentInfo.role,
          status: currentInfo.status,
          createTime: currentInfo.createTime
        }
        await TokenUtil.saveUserInfo(getContext(this), mergedInfo)
      }

      this.successMsg = '保存成功'
      // 延迟返回
      setTimeout(() => {
        router.back()
      }, 1000)
    } catch (error) {
      this.errorMsg = (error as Error).message || '保存失败'
    } finally {
      this.saving = false
    }
  }

  isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 表单区域 =====
      Scroll() {
        Column({ space: 16 }) {
          if (this.loading) {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999')
              .margin({ top: 40 })
          } else {
            // 表单卡片
            Column({ space: 0 }) {
              this.buildFormItem('昵称', this.nickname, (value: string) => { this.nickname = value }, '请输入昵称', false)
              this.buildDivider()
              this.buildFormItem('邮箱', this.email, (value: string) => { this.email = value }, '请输入邮箱', false)
              this.buildDivider()
              this.buildFormItem('手机号', this.phone, (value: string) => { this.phone = value }, '请输入手机号', false)
            }
            .width('100%')
            .backgroundColor('#fff')
            .borderRadius(16)
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

            // 提示
            Text('仅修改需要更新的字段即可')
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .padding({ left: 4 })

            // 错误/成功消息
            if (this.errorMsg) {
              Text(this.errorMsg)
                .fontSize(14)
                .fontColor('#EF4444')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            if (this.successMsg) {
              Text(this.successMsg)
                .fontSize(14)
                .fontColor('#10B981')
                .width('100%')
                .textAlign(TextAlign.Center)
            }

            // 保存按钮
            Button(this.saving ? '保存中...' : '保存修改')
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
                this.handleSave()
              })
          }
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

        Text('编辑个人资料')
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
  buildFormItem(label: string, value: string, onChange: (value: string) => void, placeholder: string, isPassword: boolean) {
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

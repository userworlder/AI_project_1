import router from '@ohos.router'
import { TokenUtil } from '../common/TokenUtil'
import { DateUtil } from '../common/DateUtil'
import { StudyRecordApi } from '../http/StudyRecordApi'
import type { StudyRecordItem } from '../model/User'
import type { UserInfo } from '../model/User'

@Entry
@Component
struct StudyRecords {
  @State records: StudyRecordItem[] = []
  @State current: number = 1
  @State total: number = 0
  @State loading: boolean = true
  @State loadingMore: boolean = false
  @State errorMsg: string = ''

  // 记录学习 Dialog 状态
  @State showDialog: boolean = false
  @State newContent: string = ''
  @State newDuration: string = '30'
  @State newType: string = 'practice'
  @State saving: boolean = false
  @State dialogError: string = ''
  private userId: number = 0

  private typeOptions: string[] = ['reading', 'practice', 'video', 'quiz', 'coding', 'discussion']

  aboutToAppear() {
    this.loadUserAndRecords()
  }

  async loadUserAndRecords() {
    const userInfo: UserInfo | undefined = await TokenUtil.getUserInfo(getContext(this))
    if (userInfo) {
      this.userId = userInfo.id
    }
    this.loadRecords(1, true)
  }

  async loadRecords(page: number, reset: boolean) {
    if (reset) {
      this.loading = true
    } else {
      this.loadingMore = true
    }

    try {
      const result = await StudyRecordApi.getStudyRecords(getContext(this), page, 10, this.userId)
      if (reset) {
        this.records = result.records
      } else {
        this.records = this.records.concat(result.records)
      }
      this.total = result.total
      this.current = page
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载学习记录失败'
      console.error('加载学习记录失败:', error)
    } finally {
      this.loading = false
      this.loadingMore = false
    }
  }

  loadMore() {
    if (!this.loadingMore && this.records.length < this.total) {
      this.loadRecords(this.current + 1, false)
    }
  }

  openCreateDialog() {
    this.newContent = ''
    this.newDuration = '30'
    this.newType = 'practice'
    this.dialogError = ''
    this.showDialog = true
  }

  closeDialog() {
    this.showDialog = false
    this.dialogError = ''
  }

  async handleCreateRecord() {
    if (!this.newContent.trim()) {
      this.dialogError = '请输入学习内容'
      return
    }
    const durationNum = parseInt(this.newDuration)
    if (isNaN(durationNum) || durationNum <= 0) {
      this.dialogError = '请输入有效的学习时长'
      return
    }

    this.saving = true
    this.dialogError = ''
    try {
      await StudyRecordApi.createStudyRecord(getContext(this), {
        userId: this.userId,
        content: this.newContent.trim(),
        duration: durationNum,
        type: this.newType
      })
      this.closeDialog()
      // 刷新列表
      this.loadRecords(1, true)
    } catch (error) {
      this.dialogError = (error as Error).message || '保存失败'
    } finally {
      this.saving = false
    }
  }

  selectType(type: string) {
    this.newType = type
  }

  getTypeColor(type: string): string {
    if (type === 'reading') return '#6366F1'
    if (type === 'practice') return '#10B981'
    if (type === 'video') return '#F59E0B'
    if (type === 'quiz') return '#EF4444'
    if (type === 'coding') return '#8B5CF6'
    if (type === 'discussion') return '#14B8A6'
    return '#999'
  }

  getTypeLabel(type: string): string {
    if (type === 'reading') return '阅读'
    if (type === 'practice') return '练习'
    if (type === 'video') return '视频'
    if (type === 'quiz') return '测验'
    if (type === 'coding') return '编程'
    if (type === 'discussion') return '讨论'
    return type
  }

  getStatusText(status: number): string {
    if (status === 0) return '未开始'
    if (status === 1) return '进行中'
    if (status === 2) return '已完成'
    if (status === 3) return '已取消'
    return '未知'
  }

  getStatusColor(status: number): string {
    if (status === 0) return '#999'
    if (status === 1) return '#F59E0B'
    if (status === 2) return '#10B981'
    if (status === 3) return '#EF4444'
    return '#999'
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 内容区域 =====
      if (this.loading) {
        this.buildLoadingState()
      } else if (this.errorMsg && this.records.length === 0) {
        this.buildErrorState()
      } else if (this.records.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildRecordList()
      }

      // ===== 浮动添加按钮 =====
      Row() {
        Text('+')
          .fontSize(28)
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor('#6366F1')
      .shadow({ radius: 12, color: 'rgba(99,102,241,0.5)', offsetY: 4 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .position({ x: '80%', y: '85%' })
      .onClick(() => {
        this.openCreateDialog()
      })

      // ===== 创建记录 Dialog（覆盖层） =====
      if (this.showDialog) {
        this.buildCreateDialog()
      }
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

        Column({ space: 4 }) {
          Text('学习记录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text('查看学习历史记录')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.7)')
        }
        .alignItems(HorizontalAlign.Start)
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
  buildLoadingState() {
    Column() {
      Text('加载中...')
        .fontSize(16)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildErrorState() {
    Column() {
      Text('⚠️')
        .fontSize(48)
        .margin({ bottom: 12 })
      Text(this.errorMsg)
        .fontSize(16)
        .fontColor('#999')
        .textAlign(TextAlign.Center)
      Button('重新加载')
        .fontSize(14)
        .fontColor('#6366F1')
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ top: 16 })
        .onClick(() => {
          this.errorMsg = ''
          this.loadRecords(1, true)
        })
    }
    .layoutWeight(1)
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('📝')
        .fontSize(64)
        .margin({ bottom: 16 })
      Text('暂无学习记录')
        .fontSize(16)
        .fontColor('#999')
      Text('点击右下角 + 开始记录')
        .fontSize(14)
        .fontColor('#ccc')
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildRecordList() {
    Scroll() {
      Column({ space: 12 }) {
        Text(`共 ${this.total} 条记录`)
          .fontSize(13)
          .fontColor('#999')
          .width('100%')

        ForEach(this.records, (record: StudyRecordItem) => {
          this.buildRecordCard(record)
        })

        if (this.records.length < this.total) {
          Button(this.loadingMore ? '加载中...' : '加载更多')
            .fontSize(14)
            .fontColor('#6366F1')
            .backgroundColor('#fff')
            .borderRadius(12)
            .width('100%')
            .height(44)
            .enabled(!this.loadingMore)
            .onClick(() => {
              this.loadMore()
            })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20, bottom: 24 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  buildRecordCard(record: StudyRecordItem) {
    Column({ space: 10 }) {
      Row() {
        Text(this.getTypeLabel(record.type))
          .fontSize(12)
          .fontColor('#fff')
          .backgroundColor(this.getTypeColor(record.type))
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .lineHeight(18)

        Blank()

        Text(DateUtil.formatDateTime(record.createTime))
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')

      Text(record.content)
        .fontSize(14)
        .fontColor('#333')
        .lineHeight(22)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Divider()
        .color('#F0F0F0')
        .width('100%')

      Row() {
        Text(`⏱ ${record.duration} 分钟`)
          .fontSize(13)
          .fontColor('#999')

        Blank()

        Text(this.getStatusText(record.status))
          .fontSize(13)
          .fontColor(this.getStatusColor(record.status))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  @Builder
  buildCreateDialog() {
    // 半透明遮罩
    Column() {
      // 居中表单卡片
      Column({ space: 16 }) {
        // 标题
        Row() {
          Text('记录学习')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          Blank()
          Text('✕')
            .fontSize(20)
            .fontColor('#999')
            .onClick(() => {
              this.closeDialog()
            })
        }
        .width('100%')

        // 学习类型选择
        Column({ space: 8 }) {
          Text('学习类型')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.typeOptions, (type: string) => {
              Text(this.getTypeLabel(type))
                .fontSize(12)
                .fontColor(this.newType === type ? '#fff' : '#666')
                .backgroundColor(this.newType === type ? this.getTypeColor(type) : '#F5F6FA')
                .borderRadius(16)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.selectType(type)
                })
            })
          }
          .width('100%')
        }
        .width('100%')

        // 学习内容
        Column({ space: 8 }) {
          Text('学习内容')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')

          TextArea({ text: this.newContent, placeholder: '描述你学习了什么...' })
            .width('100%')
            .height(100)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding(12)
            .fontSize(14)
            .onChange((value: string) => {
              this.newContent = value
            })
        }
        .width('100%')

        // 学习时长
        Column({ space: 8 }) {
          Text('学习时长（分钟）')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')

          TextInput({ text: this.newDuration, placeholder: '30' })
            .width('100%')
            .height(44)
            .backgroundColor('#F5F6FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .fontSize(16)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.newDuration = value
            })
        }
        .width('100%')

        // 错误信息
        if (this.dialogError) {
          Text(this.dialogError)
            .fontSize(14)
            .fontColor('#EF4444')
            .width('100%')
            .textAlign(TextAlign.Center)
        }

        // 按钮
        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F5F6FA')
            .fontColor('#666')
            .fontSize(16)
            .borderRadius(12)
            .onClick(() => {
              this.closeDialog()
            })

          Button(this.saving ? '保存中...' : '保存记录')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#6366F1')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(12)
            .enabled(!this.saving)
            .onClick(() => {
              this.handleCreateRecord()
            })
        }
        .width('100%')
      }
      .width('85%')
      .padding(24)
      .backgroundColor('#fff')
      .borderRadius(20)
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.closeDialog()
    })
  }
}

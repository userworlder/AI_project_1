import router from '@ohos.router'
import { CourseApi } from '../http/CourseApi'
import { TokenUtil } from '../common/TokenUtil'
import type { CourseItem, CourseSectionItem } from '../model/Course'
import type { UserInfo } from '../model/User'

@Entry
@Component
struct CourseDetail {
  @State courses: CourseItem[] = []
  @State sections: CourseSectionItem[] = []
  @State course: CourseItem | null = null
  @State loading: boolean = true
  @State errorMsg: string = ''
  @State viewMode: string = 'courses' // 'courses' or 'sections'
  @State headerTitle: string = '课程列表'
  @State isTeacher: boolean = false
  @State skillId: number = 0

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    const skillId = params['skillId'] as number
    const courseId = params['courseId'] as number
    this.skillId = skillId
    // 检查用户角色
    TokenUtil.getUserInfo(getContext(this)).then((user: UserInfo | undefined) => {
      if (user && (user.role === 'teacher' || user.role === 'admin')) {
        this.isTeacher = true
      }
    })
    if (courseId !== undefined) {
      this.viewMode = 'sections'
      this.loadCourseDetail(courseId)
    } else if (skillId !== undefined) {
      this.viewMode = 'courses'
      this.headerTitle = '课程列表'
      this.loadCourses(skillId)
    } else {
      this.viewMode = 'courses'
      this.headerTitle = '课程列表'
      this.loadCourses()
    }
  }

  async loadCourses(skillId?: number) {
    this.loading = true
    this.errorMsg = ''
    try {
      const result = await CourseApi.getCourses(getContext(this), skillId)
      this.courses = result.records || []
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载课程列表失败'
      console.error('加载课程列表失败:', error)
    } finally {
      this.loading = false
    }
  }

  async loadCourseDetail(courseId: number) {
    this.loading = true
    this.errorMsg = ''
    try {
      this.course = await CourseApi.getCourseById(getContext(this), courseId)
      this.headerTitle = this.course.name
      const sections = await CourseApi.getSections(getContext(this), courseId)
      this.sections = sections || []
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载课程详情失败'
      console.error('加载课程详情失败:', error)
    } finally {
      this.loading = false
    }
  }

  getDifficultyLabel(level: number): string {
    if (level <= 1) return '入门'
    if (level <= 2) return '初级'
    if (level <= 3) return '中级'
    if (level <= 4) return '高级'
    return '专家'
  }

  getDifficultyColor(level: number): string {
    if (level <= 1) return '#10B981'
    if (level <= 2) return '#6366F1'
    if (level <= 3) return '#F59E0B'
    if (level <= 4) return '#EF4444'
    return '#8B5CF6'
  }

  getStatusText(status: number): string {
    if (status === 0) return '未开始'
    if (status === 1) return '进行中'
    if (status === 2) return '已完成'
    return '未知'
  }

  getStatusColor(status: number): string {
    if (status === 0) return '#999'
    if (status === 1) return '#6366F1'
    if (status === 2) return '#10B981'
    return '#999'
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 内容区域 =====
      if (this.loading) {
        this.buildLoadingState()
      } else if (this.errorMsg && this.courses.length === 0 && this.sections.length === 0) {
        this.buildErrorState()
      } else if (this.viewMode === 'courses' && this.courses.length === 0) {
        this.buildEmptyState('暂无课程数据')
      } else if (this.viewMode === 'sections' && this.sections.length === 0) {
        this.buildEmptyState('暂无章节数据')
      } else if (this.viewMode === 'courses') {
        this.buildCourseList()
      } else if (this.viewMode === 'sections') {
        this.buildSectionList()
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
          Text(this.headerTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.viewMode === 'courses') {
            Text('浏览学习课程')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.7)')
          } else if (this.course) {
            Text(this.course.skillName || '课程学习')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.7)')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
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
          const params = router.getParams() as Record<string, number>
          const skillId = params['skillId']
          const courseId = params['courseId']
          if (courseId !== undefined) {
            this.loadCourseDetail(courseId)
          } else {
            this.loadCourses(skillId)
          }
        })
    }
    .layoutWeight(1)
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyState(message: string) {
    Column() {
      Text('📚')
        .fontSize(64)
        .margin({ bottom: 16 })
      Text(message)
        .fontSize(16)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildCourseList() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text(`共 ${this.courses.length} 门课程`)
            .fontSize(13)
            .fontColor('#999')

          Blank()

          if (this.isTeacher) {
            Button('请到后台管理课程')
              .fontSize(12)
              .fontColor('#6366F1')
              .backgroundColor('#EEF2FF')
              .borderRadius(8)
              .height(30)
              .padding({ left: 10, right: 10 })
          }
        }
        .width('100%')

        ForEach(this.courses, (course: CourseItem) => {
          this.buildCourseCard(course)
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20, bottom: 24 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  buildCourseCard(course: CourseItem) {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(course.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row({ space: 8 }) {
            Text(this.getDifficultyLabel(course.difficultyLevel))
              .fontSize(11)
              .fontColor('#fff')
              .backgroundColor(this.getDifficultyColor(course.difficultyLevel))
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .lineHeight(16)

            Text(course.skillName)
              .fontSize(11)
              .fontColor('#6366F1')
              .backgroundColor('#EEF2FF')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .lineHeight(16)
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')

      Text(course.description)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(20)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (course.teacherName) {
        Row() {
          Text(`讲师: ${course.teacherName}`)
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')
      }

      Divider()
        .color('#F0F0F0')
        .width('100%')

      Row() {
        Blank()
        Text('查看章节 ›')
          .fontSize(13)
          .fontColor('#6366F1')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/CourseDetail',
        params: { courseId: course.id }
      })
    })
  }

  @Builder
  buildSectionList() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          // 课程信息卡片
          if (this.course) {
            this.buildCourseInfoCard()
          }

          Row() {
            Text(`共 ${this.sections.length} 个章节`)
              .fontSize(13)
              .fontColor('#999')

            if (this.isTeacher) {
              Blank()
              Button('后台管理')
                .fontSize(13)
                .fontColor('#6366F1')
                .backgroundColor('#EEF2FF')
                .borderRadius(8)
                .height(32)
                .padding({ left: 12, right: 12 })
            }
          }
          .width('100%')
          .margin({ top: 4 })

          ForEach(this.sections, (section: CourseSectionItem) => {
            this.buildSectionCard(section)
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 24 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  buildCourseInfoCard() {
    Column({ space: 10 }) {
      Text(this.course!.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')

      Text(this.course!.description)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (this.course!.skillName || this.course!.teacherName) {
        Row({ space: 16 }) {
          if (this.course!.skillName) {
            Row({ space: 4 }) {
              Text('技能:')
                .fontSize(12)
                .fontColor('#999')
              Text(this.course!.skillName)
                .fontSize(12)
                .fontColor('#6366F1')
            }
          }
          if (this.course!.teacherName) {
            Row({ space: 4 }) {
              Text('讲师:')
                .fontSize(12)
                .fontColor('#999')
              Text(this.course!.teacherName)
                .fontSize(12)
                .fontColor('#666')
            }
          }
        }
        .width('100%')
      }

      Row({ space: 8 }) {
        Text(this.getDifficultyLabel(this.course!.difficultyLevel))
          .fontSize(11)
          .fontColor('#fff')
          .backgroundColor(this.getDifficultyColor(this.course!.difficultyLevel))
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .lineHeight(16)
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
  buildSectionCard(section: CourseSectionItem) {
    Column({ space: 10 }) {
      Row() {
        // 序号
        Text(`${section.orderIndex}`)
          .fontSize(14)
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
          .width(28)
          .height(28)
          .borderRadius(14)
          .backgroundColor(this.getStatusColor(section.progressStatus))
          .textAlign(TextAlign.Center)
          .lineHeight(28)

        Column({ space: 4 }) {
          Text(section.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          if (section.description) {
            Text(section.description)
              .fontSize(13)
              .fontColor('#999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')

      Divider()
        .color('#F0F0F0')
        .width('100%')

      Row() {
        Text(`${section.questionCount} 道题目`)
          .fontSize(12)
          .fontColor('#999')

        Blank()

        Text(this.getStatusText(section.progressStatus))
          .fontSize(12)
          .fontColor(this.getStatusColor(section.progressStatus))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/QuizPage',
        params: { sectionId: section.id, sectionTitle: section.title }
      })
    })
  }
}

import router from '@ohos.router'
import { SkillApi } from '../http/SkillApi'
import type { SkillItem } from '../model/Skill'

@Entry
@Component
struct SkillTree {
  @State skills: SkillItem[] = []
  @State categoryOrder: string[] = []
  @State expandedState: boolean[] = []
  @State loading: boolean = true
  @State errorMsg: string = ''

  aboutToAppear() {
    this.loadSkills()
  }

  async loadSkills() {
    this.loading = true
    try {
      const skills = await SkillApi.getSkillTree(getContext(this))
      this.skills = skills
      this.buildCategoryOrder(skills)
    } catch (error) {
      this.errorMsg = (error as Error).message || '加载技能树失败'
      console.error('加载技能树失败:', error)
    } finally {
      this.loading = false
    }
  }

  buildCategoryOrder(skills: SkillItem[]) {
    const seen: string[] = []
    const order: string[] = []
    for (const skill of skills) {
      const cat = skill.category || '未分类'
      if (!this.contains(seen, cat)) {
        seen.push(cat)
        order.push(cat)
      }
    }
    this.categoryOrder = order
    const expanded: boolean[] = []
    for (let i = 0; i < order.length; i++) {
      expanded.push(true)
    }
    this.expandedState = expanded
  }

  contains(arr: string[], item: string): boolean {
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] === item) {
        return true
      }
    }
    return false
  }

  getSkillsForCategory(category: string): SkillItem[] {
    const result: SkillItem[] = []
    for (const skill of this.skills) {
      const cat = skill.category || '未分类'
      if (cat === category) {
        result.push(skill)
      }
    }
    return result
  }

  toggleCategory(index: number) {
    const newState: boolean[] = []
    for (let i = 0; i < this.expandedState.length; i++) {
      newState.push(this.expandedState[i])
    }
    newState[index] = !newState[index]
    this.expandedState = newState
  }

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      this.buildHeader()

      // ===== 内容区域 =====
      if (this.loading) {
        this.buildLoadingState()
      } else if (this.errorMsg && this.skills.length === 0) {
        this.buildErrorState()
      } else if (this.skills.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildSkillList()
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
          Text('技能树')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text('浏览学习技能体系')
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
          this.loadSkills()
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
      Text('📚')
        .fontSize(64)
        .margin({ bottom: 16 })
      Text('暂无技能数据')
        .fontSize(16)
        .fontColor('#999')
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildSkillList() {
    Scroll() {
      Column({ space: 16 }) {
        ForEach(this.categoryOrder, (category: string, index: number) => {
          Column({ space: 0 }) {
            // 分类标题（可折叠）
            this.buildCategoryHeader(category, index)

            // 技能卡片列表
            if (this.expandedState[index]) {
              Column({ space: 10 }) {
                ForEach(this.getSkillsForCategory(category), (skill: SkillItem) => {
                  this.buildSkillCard(skill)
                })
              }
              .width('100%')
              .margin({ top: 0, bottom: 8 })
            }
          }
          .width('100%')
          .backgroundColor('#fff')
          .borderRadius(16)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20, bottom: 24 })
    }
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  buildCategoryHeader(category: string, index: number) {
    Row() {
      Row() {
        Text(category)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .layoutWeight(1)

      Text(this.expandedState[index] ? '收起 ▲' : '展开 ▼')
        .fontSize(12)
        .fontColor('#6366F1')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      this.toggleCategory(index)
    })
  }

  @Builder
  buildSkillCard(skill: SkillItem) {
    Column({ space: 8 }) {
      Row() {
        Text(skill.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Blank()
        // 等级指示
        this.buildLevelIndicator(skill.level)
      }
      .width('100%')

      Text(skill.description)
        .fontSize(14)
        .fontColor('#666')
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F6FA')
    .borderRadius(12)
    .margin({ left: 12, right: 12 })
  }

  @Builder
  buildLevelIndicator(level: number) {
    Row({ space: 4 }) {
      Text('●')
        .fontSize(10)
        .fontColor(level >= 1 ? '#6366F1' : '#E0E0E0')
      Text('●')
        .fontSize(10)
        .fontColor(level >= 2 ? '#6366F1' : '#E0E0E0')
      Text('●')
        .fontSize(10)
        .fontColor(level >= 3 ? '#6366F1' : '#E0E0E0')
      Text('●')
        .fontSize(10)
        .fontColor(level >= 4 ? '#6366F1' : '#E0E0E0')
      Text('●')
        .fontSize(10)
        .fontColor(level >= 5 ? '#6366F1' : '#E0E0E0')
    }
  }
}

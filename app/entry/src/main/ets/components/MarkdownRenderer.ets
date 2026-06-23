/**
 * Markdown 渲染器组件（练习二）
 * 支持以下 Markdown 语法：
 * - **加粗文本**
 * - `行内代码`
 * - 换行（\n）
 */
@Component
export struct MarkdownRenderer {
  @Prop content: string = ''

  build() {
    Column() {
      // 按换行符分割内容
      ForEach(this.parseContent(), (paragraph: string, index: number) => {
        if (paragraph.trim().length > 0) {
          this.renderParagraph(paragraph, index)
        }
      }, (paragraph: string, index: number) => `${index}-${paragraph}`)
    }
    .width('100%')
  }

  /**
   * 解析内容，按换行符分割
   */
  private parseContent(): string[] {
    return this.content.split('\n')
  }

  /**
   * 渲染单个段落
   */
  @Builder
  renderParagraph(paragraph: string, index: number) {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.tokenize(paragraph), (token: Token, tokenIndex: number) => {
        this.renderToken(token, tokenIndex)
      }, (token: Token, tokenIndex: number) => `${tokenIndex}-${token.type}-${token.content}`)
    }
    .width('100%')
    .margin({ bottom: index < this.parseContent().length - 1 ? 8 : 0 })
  }

  /**
   * 渲染单个 token
   */
  @Builder
  renderToken(token: Token, index: number) {
    if (token.type === 'code') {
      // 行内代码样式
      Text(token.content)
        .fontSize(13)
        .fontFamily('monospace')
        .backgroundColor('#F0F0F0')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(4)
        .margin({ right: 2 })
    } else if (token.type === 'bold') {
      // 加粗文本样式
      Text(token.content)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ right: 2 })
    } else {
      // 普通文本
      Text(token.content)
        .fontSize(14)
        .margin({ right: 2 })
    }
  }

  /**
   * 将段落分割为 token 数组
   * 支持：**加粗** 和 `代码`
   */
  private tokenize(text: string): Token[] {
    const tokens: Token[] = []
    let remaining = text

    while (remaining.length > 0) {
      // 匹配行内代码 `code`
      const codeMatch = remaining.match(/^`([^`]+)`/)
      if (codeMatch) {
        tokens.push({ type: 'code', content: codeMatch[1] })
        remaining = remaining.substring(codeMatch[0].length)
        continue
      }

      // 匹配加粗 **text**
      const boldMatch = remaining.match(/^\*\*([^*]+)\*\*/)
      if (boldMatch) {
        tokens.push({ type: 'bold', content: boldMatch[1] })
        remaining = remaining.substring(boldMatch[0].length)
        continue
      }

      // 匹配普通文本（直到下一个特殊符号）
      const normalMatch = remaining.match(/^[^`*]+/)
      if (normalMatch) {
        tokens.push({ type: 'normal', content: normalMatch[0] })
        remaining = remaining.substring(normalMatch[0].length)
        continue
      }

      // 如果都不匹配，跳过当前字符
      tokens.push({ type: 'normal', content: remaining[0] })
      remaining = remaining.substring(1)
    }

    return tokens
  }
}

/**
 * Token 类型定义
 */
interface Token {
  type: 'normal' | 'code' | 'bold'
  content: string
}

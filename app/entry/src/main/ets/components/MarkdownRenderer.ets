@Component
export struct MarkdownRenderer {
  @Prop content: string = ''

  build() {
    Column() {
      ForEach(this.parseContent(), (block: MarkdownBlock) => {
        this.renderBlock(block)
      }, (block: MarkdownBlock, index: number) => `${index}-${block.type}`)
    }
    .width('100%')
  }

  private parseContent(): MarkdownBlock[] {
    const blocks: MarkdownBlock[] = []
    const decodedContent = this.decodeEscapedContent(this.content)

    // 空内容直接返回
    if (!decodedContent) {
      return blocks
    }

    const lines = decodedContent.split('\n')
    let i = 0

    while (i < lines.length) {
      const line = lines[i]

      if (line.startsWith('```')) {
        const codeContent: string[] = []
        i++ // 跳过开头的 ```

        // 跳过语言标识行（如 java, python, typescript 等）
        if (i < lines.length && !lines[i].startsWith('```') && lines[i].trim().length > 0) {
          i++ // 语言标识行不加入代码内容
        }

        while (i < lines.length && !lines[i].startsWith('```')) {
          codeContent.push(lines[i])
          i++
        }
        i++ // 跳过结尾的 ```
        blocks.push({ type: 'code', content: codeContent.join('\n') })
        continue
      }

      if (line.match(/^#{1,6}\s?/)) {
        const level = line.match(/^#{1,6}/)?.[0].length || 1
        blocks.push({ type: 'header', level: level, tokens: this.parseInline(line.replace(/^#{1,6}\s?/, '')) })
        i++
        continue
      }

      if (line.startsWith('> ')) {
        blocks.push({ type: 'quote', tokens: this.parseInline(line.substring(2)) })
        i++
        continue
      }

      if (line.match(/^---+$/)) {
        blocks.push({ type: 'divider' })
        i++
        continue
      }

      if (line.match(/^[-*]\s/)) {
        blocks.push({ type: 'ul', tokens: this.parseInline(line.replace(/^[-*]\s/, '')) })
        i++
        continue
      }

      if (line.match(/^\d+\.\s/)) {
        const num = line.match(/^\d+/)?.[0] || ''
        blocks.push({ type: 'ol', num: num, tokens: this.parseInline(line.replace(/^\d+\.\s/, '')) })
        i++
        continue
      }

      if (line.trim().length > 0) {
        blocks.push({ type: 'paragraph', tokens: this.parseInline(line) })
      }
      i++
    }

    return blocks
  }

  private parseInline(text: string): InlineToken[] {
    const tokens: InlineToken[] = []
    let remaining = text

    while (remaining.length > 0) {
      const codeMatch = remaining.match(/^`([^`]+)`/)
      if (codeMatch) {
        tokens.push({ type: 'code', content: codeMatch[1] })
        remaining = remaining.substring(codeMatch[0].length)
        continue
      }

      const boldMatch = remaining.match(/^\*\*([\s\S]+?)\*\*/)
      if (boldMatch) {
        tokens.push({ type: 'bold', content: boldMatch[1] })
        remaining = remaining.substring(boldMatch[0].length)
        continue
      }

      const italicMatch = remaining.match(/^\*([\s\S]+?)\*/)
      if (italicMatch) {
        tokens.push({ type: 'italic', content: italicMatch[1] })
        remaining = remaining.substring(italicMatch[0].length)
        continue
      }

      const linkMatch = remaining.match(/^\[([^\]]+)\]\(([^)]+)\)/)
      if (linkMatch) {
        tokens.push({ type: 'link', content: linkMatch[1] })
        remaining = remaining.substring(linkMatch[0].length)
        continue
      }

      const normalMatch = remaining.match(/^[^`*\[\]]+/)
      if (normalMatch) {
        tokens.push({ type: 'normal', content: normalMatch[0] })
        remaining = remaining.substring(normalMatch[0].length)
        continue
      }

      tokens.push({ type: 'normal', content: remaining[0] })
      remaining = remaining.substring(1)
    }

    return tokens
  }

  @Builder
  renderBlock(block: MarkdownBlock) {
    if (block.type === 'code') {
      Scroll() {
        Text(block.content || '')
          .fontSize(13)
          .fontFamily('monospace')
          .backgroundColor('#2d2d2d')
          .fontColor('#f8f8f2')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .borderRadius(8)
          .width('100%')
      }
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 8, bottom: 8 })
      .width('100%')
    } else if (block.type === 'divider') {
      Divider()
        .color('#E0E0E0')
        .strokeWidth(1)
        .margin({ top: 8, bottom: 8 })
    } else {
      this.renderTextBlock(block)
    }
  }

  @Builder
  renderTextBlock(block: MarkdownBlock) {
    if (block.type === 'header') {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(block.tokens || [], (token: InlineToken) => {
          if (token.type === 'bold') {
            Text(token.content)
              .fontSize(this.getFontSize(block.level || 1))
              .fontWeight(FontWeight.Bold)
              .margin({ right: 2 })
          } else if (token.type === 'italic') {
            Text(token.content)
              .fontSize(this.getFontSize(block.level || 1))
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else if (token.type === 'code') {
            Text(token.content)
              .fontSize(13)
              .fontFamily('monospace')
              .backgroundColor('#F0F0F0')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 2 })
          } else if (token.type === 'link') {
            Text(token.content)
              .fontSize(this.getFontSize(block.level || 1))
              .fontColor('#409EFF')
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else {
            Text(token.content)
              .fontSize(this.getFontSize(block.level || 1))
              .fontWeight(FontWeight.Bold)
              .margin({ right: 2 })
          }
        }, (token: InlineToken, i: number) => `h-${i}-${token.type}`)
      }
      .width('100%')
      .margin({ top: (block.level || 1) <= 3 ? 16 : 8, bottom: (block.level || 1) <= 3 ? 8 : 4 })
    } else if (block.type === 'quote') {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(block.tokens || [], (token: InlineToken) => {
          if (token.type === 'bold') {
            Text(token.content)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 2 })
          } else if (token.type === 'italic') {
            Text(token.content)
              .fontSize(14)
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else if (token.type === 'code') {
            Text(token.content)
              .fontSize(13)
              .fontFamily('monospace')
              .backgroundColor('#F0F0F0')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 2 })
          } else if (token.type === 'link') {
            Text(token.content)
              .fontSize(14)
              .fontColor('#409EFF')
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else {
            Text(token.content)
              .fontSize(14)
              .margin({ right: 2 })
          }
        }, (token: InlineToken, i: number) => `q-${i}-${token.type}`)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#F9F9F9')
      .border({ width: { left: 4 }, color: '#409EFF' })
      .margin({ bottom: 8 })
    } else if (block.type === 'ul') {
      Row() {
        Text('•')
          .fontSize(14)
          .margin({ right: 8 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(block.tokens || [], (token: InlineToken) => {
            if (token.type === 'bold') {
              Text(token.content)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .margin({ right: 2 })
            } else if (token.type === 'italic') {
              Text(token.content)
                .fontSize(14)
                .fontStyle(FontStyle.Italic)
                .margin({ right: 2 })
            } else if (token.type === 'code') {
              Text(token.content)
                .fontSize(13)
                .fontFamily('monospace')
                .backgroundColor('#F0F0F0')
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 2 })
            } else if (token.type === 'link') {
              Text(token.content)
                .fontSize(14)
                .fontColor('#409EFF')
                .fontStyle(FontStyle.Italic)
                .margin({ right: 2 })
            } else {
              Text(token.content)
                .fontSize(14)
                .margin({ right: 2 })
            }
          }, (token: InlineToken, i: number) => `ul-${i}-${token.type}`)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 4 })
    } else if (block.type === 'ol') {
      Row() {
        Text(`${block.num}.`)
          .fontSize(14)
          .margin({ right: 8 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(block.tokens || [], (token: InlineToken) => {
            if (token.type === 'bold') {
              Text(token.content)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .margin({ right: 2 })
            } else if (token.type === 'italic') {
              Text(token.content)
                .fontSize(14)
                .fontStyle(FontStyle.Italic)
                .margin({ right: 2 })
            } else if (token.type === 'code') {
              Text(token.content)
                .fontSize(13)
                .fontFamily('monospace')
                .backgroundColor('#F0F0F0')
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 2 })
            } else if (token.type === 'link') {
              Text(token.content)
                .fontSize(14)
                .fontColor('#409EFF')
                .fontStyle(FontStyle.Italic)
                .margin({ right: 2 })
            } else {
              Text(token.content)
                .fontSize(14)
                .margin({ right: 2 })
            }
          }, (token: InlineToken, i: number) => `ol-${i}-${token.type}`)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 4 })
    } else {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(block.tokens || [], (token: InlineToken) => {
          if (token.type === 'bold') {
            Text(token.content)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 2 })
          } else if (token.type === 'italic') {
            Text(token.content)
              .fontSize(14)
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else if (token.type === 'code') {
            Text(token.content)
              .fontSize(13)
              .fontFamily('monospace')
              .backgroundColor('#F0F0F0')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 2 })
          } else if (token.type === 'link') {
            Text(token.content)
              .fontSize(14)
              .fontColor('#409EFF')
              .fontStyle(FontStyle.Italic)
              .margin({ right: 2 })
          } else {
            Text(token.content)
              .fontSize(14)
              .margin({ right: 2 })
          }
        }, (token: InlineToken, i: number) => `p-${i}-${token.type}`)
      }
      .width('100%')
      .margin({ bottom: 8 })
    }
  }

  private getFontSize(level: number): number {
    const sizes: number[] = [24, 22, 20, 18, 16, 15]
    return sizes[level - 1] || 14
  }

  private decodeEscapedContent(content: string): string {
    let result = content
    result = result.replace(/\\n/g, '\n')
    result = result.replace(/\\t/g, '\t')
    result = result.replace(/\\r/g, '\r')
    result = result.replace(/\\"/g, '"')
    result = result.replace(/\\'/g, "'")
    result = result.replace(/\\\\/g, '\\')
    return result
  }
}

interface MarkdownBlock {
  type: 'code' | 'header' | 'quote' | 'divider' | 'ul' | 'ol' | 'paragraph'
  content?: string
  level?: number
  num?: string
  tokens?: InlineToken[]
}

interface InlineToken {
  type: 'normal' | 'code' | 'bold' | 'italic' | 'link'
  content: string
}
interface ChatMessage {
  id: string;
  role: 'ai' | 'user';
  content: string;
  time: string;
}

interface InsightCard {
  value: string;
  label: string;
}

@Component
export struct AICocktailPage {
  @State private inputText: string = '';
  @State private touchStartY: number = 0;
  @State private touchCurrentY: number = 0;

  isNavigationHidden: boolean = false;
  onRequestShowNavigation: () => void = () => {};
  onRequestHideNavigation: () => void = () => {};

  private readonly quickPrompts: string[] = [
    '根据伏特加推荐一杯清爽鸡尾酒',
    '帮我做一杯低酒精度晚安特调',
    '适合女生聚会的高颜值配方'
  ];

  private readonly insightCards: InsightCard[] = [
    { value: '12s', label: '平均生成耗时' },
    { value: '89%', label: '库存匹配度' },
    { value: '3', label: '当前草案' }
  ];

  private readonly messageList: ChatMessage[] = [
    {
      id: 'm1',
      role: 'ai',
      content: '你好，我是 AI 调酒助手。请输入酒基、口味、场景或预算，我将生成配方与步骤。',
      time: '20:36'
    },
    {
      id: 'm2',
      role: 'user',
      content: '我想要一杯偏酸甜、颜色好看的鸡尾酒，基酒用金酒。',
      time: '20:37'
    },
    {
      id: 'm3',
      role: 'ai',
      content: '建议方案：金酒 45ml、柠檬汁 20ml、红石榴糖浆 15ml、苏打水补满，适合高球杯。',
      time: '20:37'
    }
  ];

  private readonly revealThreshold: number = 52;

  private handleRevealGesture(event: TouchEvent): void {
    if (event.type === TouchType.Down && event.touches.length > 0) {
      if (!this.isNavigationHidden) {
        this.onRequestHideNavigation();
      }
      this.touchStartY = event.touches[0].displayY;
      this.touchCurrentY = this.touchStartY;
      return;
    }

    if (event.type === TouchType.Move && event.touches.length > 0) {
      this.touchCurrentY = event.touches[0].displayY;
      return;
    }

    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.isNavigationHidden && this.touchStartY - this.touchCurrentY > this.revealThreshold) {
        this.onRequestShowNavigation();
      }
      this.touchStartY = 0;
      this.touchCurrentY = 0;
    }
  }

  @Builder
  private buildHeader() {
    Column({ space: 12 }) {
      Text('AI 调酒助手')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text('输入需求后自动生成可执行配方，适合快速出杯与方案比对。')
        .fontSize(13)
        .fontColor('#72838F')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildInsightCards() {
    Row({ space: 10 }) {
      ForEach(this.insightCards, (item: InsightCard) => {
        Column({ space: 8 }) {
          Text(item.value)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#153342');

          Text(item.label)
            .fontSize(11)
            .fontColor('#6F818D')
            .textAlign(TextAlign.Center);
        }
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16, left: 10, right: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });
      });
    }
    .width('100%');
  }

  @Builder
  private buildQuickPrompts() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.quickPrompts, (prompt: string) => {
          Text(prompt)
            .fontSize(12)
            .fontColor('#24546A')
            .padding({ left: 14, right: 14, top: 9, bottom: 9 })
            .backgroundColor('#E8F5FB')
            .borderRadius(16)
            .border({ width: 1, color: '#CDE4EF' });
        }, (prompt: string) => prompt);
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildMessageItem(message: ChatMessage) {
    if (message.role === 'ai') {
      Row({ space: 10 }) {
        Row() {
          Text('AI')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1B5567');
        }
        .width(34)
        .height(34)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#DDF5F1')
        .borderRadius(17);

        Column({ space: 6 }) {
          Text(message.content)
            .fontSize(14)
            .fontColor('#173240')
            .lineHeight(21);

          Text(message.time)
            .fontSize(10)
            .fontColor('#7E8F99');
        }
        .constraintSize({ minWidth: '42%', maxWidth: '82%' })
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor('#F4FBFE')
        .borderRadius({ topLeft: 20, topRight: 20, bottomRight: 20, bottomLeft: 6 })
        .border({ width: 1, color: '#D7E6ED' });
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);
    } else {
      Row({ space: 10 }) {
        Blank();

        Column({ space: 6 }) {
          Text(message.content)
            .fontSize(14)
            .fontColor('#173240')
            .lineHeight(21);

          Text(message.time)
            .fontSize(10)
            .fontColor('#6F818D');
        }
        .constraintSize({ minWidth: '42%', maxWidth: '82%' })
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor('#E8F5FB')
        .borderRadius({ topLeft: 20, topRight: 20, bottomRight: 6, bottomLeft: 20 })
        .border({ width: 1, color: '#CDE4EF' });

        Row() {
          Text('我')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E5A70');
        }
        .width(34)
        .height(34)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#CFEFF6')
        .borderRadius(17);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);
    }
  }

  @Builder
  private buildChatPanel() {
    Column({ space: 14 }) {
      Row() {
        Text('对话面板')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Blank();

        Text('支持继续追问酒精度、口味和杯型')
          .fontSize(11)
          .fontColor('#748591');
      }
      .width('100%');

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.messageList, (message: ChatMessage) => {
            this.buildMessageItem(message);
          }, (message: ChatMessage) => message.id);
        }
        .width('100%');
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off);

      this.buildQuickPrompts();

      Row({ space: 10 }) {
        TextInput({ placeholder: '输入你的调酒需求...', text: this.inputText })
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .fontColor('#173240')
          .placeholderColor('#8A9CA8')
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .border({ width: 1, color: '#D7E6ED' })
          .onChange((value: string) => {
            this.inputText = value;
          });

        Button('发送')
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#124056')
          .backgroundColor('#DDF5F1')
          .borderRadius(18)
          .border({ width: 1, color: '#BFE7E6' })
          .padding({ left: 18, right: 18 });
      }
      .width('100%');
    }
    .width('100%')
    .layoutWeight(1)
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildInsightCards();
        this.buildChatPanel();
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.isNavigationHidden ? 8 : 20,
        bottom: this.isNavigationHidden ? 24 : 110
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
    .onTouch((event: TouchEvent) => {
      this.handleRevealGesture(event);
    })
    .scrollBar(BarState.Off);
  }
}

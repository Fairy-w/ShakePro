interface StationCard {
  title: string;
  value: string;
  detail: string;
}

interface WorkflowStep {
  title: string;
  detail: string;
  time: string;
}

@Component
export struct BartendingStationPage {
  private readonly stationCards: StationCard[] = [
    { title: '库存健康度', value: '82%', detail: '当前基酒与辅料可支持主要推荐' },
    { title: '建议杯型', value: 'Highball', detail: '适配当前气泡与清爽型方案' },
    { title: '平均出杯', value: '4m', detail: '适合执行标准化流程' }
  ];

  private readonly workflow: WorkflowStep[] = [
    { title: '预冷杯体', detail: '先做冷杯处理，减少出杯后温度波动。', time: '01' },
    { title: '统一称量', detail: '将主酒、酸味和甜味原料按顺序排开。', time: '02' },
    { title: '摇和收尾', detail: '先短摇，再补气泡，最后处理装饰。', time: '03' }
  ];

  @Builder
  private buildHeader() {
    Column({ space: 10 }) {
      Text('调酒工作台')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text('用模块化方式查看当前库存、推荐方向和执行步骤。')
        .fontSize(13)
        .fontColor('#72838F')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildDashboardCards() {
    Column({ space: 12 }) {
      ForEach(this.stationCards, (item: StationCard, index: number) => {
        Row() {
          Column({ space: 8 }) {
            Text(item.title)
              .fontSize(13)
              .fontColor('#6F818D');

            Text(item.value)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#173240');

            Text(item.detail)
              .fontSize(12)
              .fontColor('#72838F')
              .lineHeight(18);
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          Row() {
            Text(index === 0 ? 'S' : index === 1 ? 'R' : 'T')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1B596E');
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(index === 1 ? '#DDF5F1' : '#E8F5FB')
          .borderRadius(16);
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(22)
        .border({ width: 1, color: '#D7E6ED' });
      });
    }
    .width('100%');
  }

  @Builder
  private buildWorkbenchCard(title: string, detail: string, bgColor: string) {
    Row({ space: 12 }) {
      Row() {
        Text(title.substring(0, 1))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#15445A');
      }
      .width(42)
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(16);

      Column({ space: 8 }) {
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text(detail)
          .fontSize(12)
          .fontColor('#72838F')
          .lineHeight(18);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildRecipeWorkbench() {
    Column({ space: 12 }) {
      Row() {
        Text('区域建议')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Blank();

        Text('按功能分区')
          .fontSize(12)
          .fontColor('#70818D');
      }
      .width('100%');

      Column({ space: 12 }) {
        this.buildWorkbenchCard('基酒区', '金酒、威士忌、伏特加按使用频率摆放。', '#E8F5FB');
        this.buildWorkbenchCard('风味区', '糖浆、苦精和果汁按酸甜层级排列。', '#DDF5F1');
        this.buildWorkbenchCard('装饰区', '冰块、果皮和香草与主流程分离摆放。', '#E8F5FB');
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildWorkflow() {
    Column({ space: 12 }) {
      Row() {
        Text('执行流程')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Blank();

        Text('标准三步')
          .fontSize(12)
          .fontColor('#70818D');
      }
      .width('100%');

      Column({ space: 10 }) {
        ForEach(this.workflow, (item: WorkflowStep) => {
          Row({ space: 12 }) {
            Row() {
              Text(item.time)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#19495E');
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#DDF5F1')
            .borderRadius(16);

            Column({ space: 6 }) {
              Text(item.title)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#173240');

              Text(item.detail)
                .fontSize(12)
                .fontColor('#72838F')
                .lineHeight(18);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .border({ width: 1, color: '#D7E6ED' });
        });
      }
      .width('100%');
    }
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildDashboardCards();
        this.buildRecipeWorkbench();
        this.buildWorkflow();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 110 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }
}

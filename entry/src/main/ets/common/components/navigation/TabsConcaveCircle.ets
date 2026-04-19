import { UiTokens } from '../../constants/UiTokens';
import { TabMenusInterfaceIRequired } from '../../types/TabMenusInterface';

@Component
export struct TabsConcaveCircle {
  @Link @Watch('syncSelectedIndex') selectIndex: number;
  @Link tabsMenu: TabMenusInterfaceIRequired[];
  @Prop tabHeight: number = 82;
  @Prop tabsBgColor: string = UiTokens.surfacePrimary;
  @Prop tabsSelectBgColor: string = UiTokens.aiSoft;
  @Prop tabsFontColor: string = UiTokens.textSecondary;
  @Prop tabsSelectFontColor: string = UiTokens.textPrimary;
  renderContent: (index: number) => void = () => {};

  @State private animateSelectIndex: number = 0;

  aboutToAppear(): void {
    this.animateSelectIndex = this.selectIndex;
  }

  private syncSelectedIndex(): void {
    this.animateSelectIndex = this.selectIndex;
  }
  @Builder
  private buildTabItem(item: TabMenusInterfaceIRequired, index: number) {
    Column({ space: 6 }) {
      Row() {
        Image(this.selectIndex === index && item.selectImage ? item.selectImage : item.image)
          .width(20)
          .height(20)
          .opacity(this.selectIndex === index ? 1 : 0.76);
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .borderRadius(18)
      .backgroundColor(this.selectIndex === index ? UiTokens.aiPrimary : UiTokens.surfaceMuted);
      Text(item.text)
        .fontSize(11)
        .fontWeight(this.selectIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.selectIndex === index ? this.tabsSelectFontColor : this.tabsFontColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .height('100%')
    .padding({ top: 10, bottom: 10, left: 4, right: 4 })
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)
    .backgroundColor(this.selectIndex === index ? this.tabsSelectBgColor : Color.Transparent)
    .border({
      width: this.selectIndex === index ? 1 : 0,
      color: this.selectIndex === index ? UiTokens.borderStrong : Color.Transparent
    })
    .onClick(() => {
      if (this.selectIndex === index) {
        return;
      }
      animateTo({ duration: 220 }, () => {
        this.selectIndex = index;
        this.renderContent(index);
      });
    });
  }

  build() {
    Row({ space: 8 }) {
      ForEach(this.tabsMenu, (item: TabMenusInterfaceIRequired, index: number) => {
        Stack() {
          if (this.animateSelectIndex === index) {
            Column()
              .width('100%')
              .height('100%')
              .borderRadius(20)
              .backgroundColor(this.tabsSelectBgColor)
              .border({ width: 1, color: UiTokens.borderStrong });
          }

          this.buildTabItem(item, index);
        }
        .layoutWeight(1)
        .height('100%');
      });
    }
    .width('100%')
    .height(this.tabHeight)
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .backgroundColor(this.tabsBgColor)
    .borderRadius(26)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 20, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 10 });
  }
}

import { UiTokens } from '../../constants/UiTokens';
import { TabMenusInterfaceIRequired } from '../../types/TabMenusInterface';

@Component
export struct FloatingDock {
  @Link @Watch('syncSelectedIndex') selectedIndex: number;
  @Link items: TabMenusInterfaceIRequired[];
  @Prop dockHeight: number = UiTokens.dockHeight;
  renderContent: (index: number) => void = () => {};

  @State private animateIndex: number = 0;

  aboutToAppear(): void {
    this.animateIndex = this.selectedIndex;
  }

  private syncSelectedIndex(): void {
    this.animateIndex = this.selectedIndex;
  }

  private isSelected(index: number): boolean {
    return this.selectedIndex === index;
  }

  private resolveItemImage(item: TabMenusInterfaceIRequired, index: number): ResourceStr {
    if (this.isSelected(index) && item.selectImage) {
      return item.selectImage;
    }
    return item.image;
  }

  private resolveLabelColor(index: number): string {
    return this.isSelected(index) ? UiTokens.textPrimary : UiTokens.textTertiary;
  }

  private resolveItemOpacity(index: number): number {
    return this.isSelected(index) ? 1 : 0.64;
  }

  @Builder
  private buildDockItem(item: TabMenusInterfaceIRequired, index: number) {
    Column({ space: 4 }) {
      Row() {
        Image(this.resolveItemImage(item, index))
          .width(17)
          .height(17)
          .opacity(this.resolveItemOpacity(index));
      }
      .width(26)
      .height(26)
      .justifyContent(FlexAlign.Center);

      Text(item.text)
        .fontSize(9)
        .fontWeight(this.isSelected(index) ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.resolveLabelColor(index))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: 4, right: 4, top: 8, bottom: 10 })
    .justifyContent(FlexAlign.Center)
    .opacity(this.resolveItemOpacity(index))
    .onClick(() => {
      if (this.selectedIndex === index) {
        return;
      }
      animateTo({ duration: 180 }, () => {
        this.selectedIndex = index;
        this.renderContent(index);
      });
    });
  }

  build() {
    Row() {
      ForEach(this.items, (item: TabMenusInterfaceIRequired, index: number) => {
        this.buildDockItem(item, index);
      }, (item: TabMenusInterfaceIRequired) => item.pagePath);
    }
    .width('100%')
    .height(this.dockHeight)
    .padding({ left: 6, right: 6, top: 3, bottom: 3 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(UiTokens.dockRadius)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 6, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 2 })
    .opacity(0.96);
  }
}

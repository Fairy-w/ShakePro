import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { SelectableMaterial } from '../model/BartendingStationMockData';
import {
  clearStagingMaterials,
  confirmStagingMaterials,
  getStagingMaterialIds,
  getStagingMaterials,
  removeFromStagingMaterials
} from '../model/MaterialStationStore';

@Entry
@Component
export struct MaterialStagingPage {
  @State private stagingMaterialIds: string[] = [];

  aboutToAppear(): void {
    this.refreshStagingMaterials();
  }

  private refreshStagingMaterials(): void {
    this.stagingMaterialIds = getStagingMaterialIds();
  }

  @Builder
  private buildHeader() {
    Row() {
      Row() {
        Text('<')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');
      }
      .width(42)
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .border({ width: 1, color: '#D7E6ED' })
      .onClick(() => {
        router.back();
      });

      Column({ space: 4 }) {
        Text('待入台清单')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('像备料清单一样统一确认，再一次性加入我的材料。')
          .fontSize(12)
          .fontColor('#72838F');
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%');
  }

  @Builder
  private buildSummaryCard() {
    Column({ space: 10 }) {
      Row() {
        Text('当前已选')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#245C82')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#E8F5FB')
          .borderRadius(14);

        Blank();

        Text(this.stagingMaterialIds.length.toString() + ' 项')
          .fontSize(12)
          .fontColor('#72838F');
      }
      .width('100%');

      Text('支持逐个移除，确认后会直接收进“我的材料清单”。')
        .fontSize(12)
        .fontColor('#72838F')
        .lineHeight(18);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildStagingItem(item: SelectableMaterial) {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Row() {
          Text(item.badge)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accentColor);
        }
        .width(46)
        .height(46)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(item.softColor)
        .borderRadius(16);

        Column({ space: 5 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240')
            .maxLines(2);

          Text(item.subtitle)
            .fontSize(11)
            .fontColor('#72838F')
            .lineHeight(17)
            .maxLines(2);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      Row({ space: 8 }) {
        Text(item.categoryName)
          .fontSize(11)
          .fontColor(item.accentColor)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(item.softColor)
          .borderRadius(14);

        if (item.tags.length > 0) {
          Text(item.tags[0])
            .fontSize(11)
            .fontColor('#72838F')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#F4F8FB')
            .borderRadius(14);
        }
      }
      .width('100%');

      Row({ space: 10 }) {
        Text(item.quickNote)
          .layoutWeight(1)
          .fontSize(12)
          .fontColor('#5F7684')
          .lineHeight(18)
          .maxLines(2);

        Button('移除', { type: ButtonType.Capsule })
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#A66A1C')
          .backgroundColor('#F8E9CF')
          .onClick(() => {
            this.removeMaterial(item.id, item.name);
          });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 10 }) {
      Text('待入台清单还是空的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text('回到材料列表，把要用的水果、软饮、糖浆和杯具先挑进来。')
        .fontSize(12)
        .fontColor('#72838F')
        .lineHeight(18)
        .textAlign(TextAlign.Center);

      Button('返回继续挑选', { type: ButtonType.Capsule })
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1B596E')
        .backgroundColor('#DDF5F1')
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildActionBar() {
    Row({ space: 10 }) {
      Button('清空清单', { type: ButtonType.Capsule })
        .width(112)
        .height(48)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5A7180')
        .backgroundColor('#EEF5F8')
        .onClick(() => {
          this.clearAllMaterials();
        });

      Button('确认加入我的材料', { type: ButtonType.Capsule })
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#1B596E')
        .onClick(() => {
          this.confirmMaterials();
        });
    }
    .width('100%');
  }

  private getStagingItems(): SelectableMaterial[] {
    return getStagingMaterials();
  }

  private removeMaterial(materialId: string, materialName: string): void {
    removeFromStagingMaterials(materialId);
    this.refreshStagingMaterials();
    promptAction.showToast({ message: materialName + ' 已从待入台清单移除' });
  }

  private clearAllMaterials(): void {
    if (this.stagingMaterialIds.length === 0) {
      promptAction.showToast({ message: '待入台清单已经是空的' });
      return;
    }
    clearStagingMaterials();
    this.refreshStagingMaterials();
    promptAction.showToast({ message: '待入台清单已清空' });
  }

  private confirmMaterials(): void {
    if (this.stagingMaterialIds.length === 0) {
      promptAction.showToast({ message: '请先加入至少 1 项材料' });
      return;
    }
    const confirmedCount: number = confirmStagingMaterials();
    this.refreshStagingMaterials();
    promptAction.showToast({ message: confirmedCount.toString() + ' 项材料已加入我的材料' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildHeader();
        this.buildSummaryCard();

        if (this.stagingMaterialIds.length === 0) {
          this.buildEmptyState();
        } else {
          Column({ space: 12 }) {
            ForEach(this.getStagingItems(), (item: SelectableMaterial) => {
              this.buildStagingItem(item);
            });
          }
          .width('100%');

          this.buildActionBar();
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 40 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }
}

import router from '@ohos.router';
import {
  MATERIAL_LIST_CATEGORIES,
  MaterialListCategory,
  MaterialRecord,
  STATION_ACTIONS,
  StationAction
} from '../../station/model/BartendingStationMockData';
import { getRecordedMaterials } from '../../station/model/MaterialStationStore';

@Component
export struct BartendingStationPage {
  @State private activeMaterialCategoryId: string = 'all';
  @State private recordedMaterials: MaterialRecord[] = [];

  aboutToAppear(): void {
    this.refreshRecordedMaterials();
  }

  private refreshRecordedMaterials(): void {
    this.recordedMaterials = getRecordedMaterials();
  }

  @Builder
  private buildHeader() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('ShakePro Station')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5D7B8C')
          .letterSpacing(1.1);

        Text('材料录入模式')
          .fontSize(11)
          .fontColor('#A66A1C')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F8E9CF')
          .borderRadius(14);
      }

      Text('我的材料台')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#16303E');

      Text('上方保留录入入口，下方只看我的材料清单。')
        .fontSize(13)
        .fontColor('#6E818D')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildActionCard(item: StationAction, featured: boolean) {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 8 }) {
          Text(item.badge)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accentColor)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(item.softColor)
            .borderRadius(14);

          Text(item.title)
            .fontSize(featured ? 24 : 20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text(item.detail)
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(19)
            .maxLines(3);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Column({ space: 8 }) {
          if (featured) {
            Column({ space: 6 }) {
              Row() {
                Blank();
              }
              .width(54)
              .height(16)
              .borderRadius(8)
              .backgroundColor('#0F3D4D');

              Row() {
                Blank();
              }
              .width(54)
              .height(16)
              .borderRadius(8)
              .backgroundColor('#184E60');

              Row() {
                Blank();
              }
              .width(54)
              .height(16)
              .borderRadius(8)
              .backgroundColor('#205B70');
            }
            .padding(10)
            .backgroundColor('#123A4A')
            .borderRadius(18);
          } else {
            Row() {
              Text('+')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.accentColor);
            }
            .width(54)
            .height(54)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(item.softColor)
            .borderRadius(18);
          }
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Row() {
        Text(item.actionText)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(featured ? '#FFFFFF' : item.accentColor);

        Blank();

        Text('->')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(featured ? '#FFFFFF' : item.accentColor);
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor(featured ? item.accentColor : item.softColor)
      .borderRadius(18);
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      router.pushUrl({ url: item.route }, 3000);
    });
  }

  @Builder
  private buildQuickEntry() {
    Column({ space: 12 }) {
      this.buildActionCard(STATION_ACTIONS[0], true);
      this.buildActionCard(STATION_ACTIONS[1], false);
    }
    .width('100%');
  }

  @Builder
  private buildAiRecipeEntry() {
    Button('根据当前材料生成配方', { type: ButtonType.Capsule })
      .width('100%')
      .height(50)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor('#1B596E')
      .onClick(() => {
        router.pushUrl({ url: 'features/cocktail/pages/AICocktailPage' }, 3000);
      });
  }

  @Builder
  private buildSectionHeader() {
    Row() {
      Column({ space: 4 }) {
        Text('我的材料清单')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('信息还没补完整的材料，只用一个小图标提醒。')
          .fontSize(12)
          .fontColor('#738590');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Text(this.getDisplayedMaterials().length.toString() + ' 项')
        .fontSize(12)
        .fontColor('#72838F');
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom);
  }

  @Builder
  private buildCategoryTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(MATERIAL_LIST_CATEGORIES, (item: MaterialListCategory) => {
          Text(item.title)
            .fontSize(13)
            .fontWeight(item.id === this.activeMaterialCategoryId ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(item.id === this.activeMaterialCategoryId ? '#173240' : '#6E818D')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(item.id === this.activeMaterialCategoryId ? '#DDF5F1' : '#FFFFFF')
            .borderRadius(18)
            .border({ width: 1, color: item.id === this.activeMaterialCategoryId ? '#BFE7E6' : '#D7E6ED' })
            .onClick(() => {
              this.activeMaterialCategoryId = item.id;
            });
        });
      }
      .padding({ right: 16 });
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off);
  }

  @Builder
  private buildMaterialTag(label: string, bgColor: string, textColor: string) {
    Text(label)
      .fontSize(11)
      .fontColor(textColor)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(bgColor)
      .borderRadius(14);
  }

  @Builder
  private buildMaterialCard(item: MaterialRecord) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row({ space: 12 }) {
        Row() {
          Text(item.badge)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accentColor);
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(item.softColor)
        .borderRadius(18);

        Column({ space: 8 }) {
          Text(item.name)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text(item.subtitle)
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(18)
            .maxLines(2);

          Row({ space: 8 }) {
            this.buildMaterialTag(item.categoryName, item.softColor, item.accentColor);
            this.buildMaterialTag(item.amountText, '#F4F8FB', '#5F7684');
          }
          .width('100%');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(22)
      .border({ width: 1, color: '#D7E6ED' });

      if (item.needsCompletion) {
        Row() {
          Text('!')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#A66A1C');
        }
        .width(22)
        .height(22)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F8E9CF')
        .borderRadius(11)
        .margin({ top: 10, right: 10 });
      }
    }
    .width('100%')
    .onClick(() => {
      router.pushUrl({
        url: 'features/station/pages/MaterialEditorPage',
        params: {
          materialId: item.id
        }
      }, 3000);
    });
  }

  private getDisplayedMaterials(): MaterialRecord[] {
    if (this.activeMaterialCategoryId === 'all') {
      return this.recordedMaterials;
    }
    return this.recordedMaterials.filter((item: MaterialRecord): boolean => item.categoryId === this.activeMaterialCategoryId);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildQuickEntry();
        this.buildAiRecipeEntry();
        this.buildSectionHeader();
        this.buildCategoryTabs();

        Column({ space: 12 }) {
          ForEach(this.getDisplayedMaterials(), (item: MaterialRecord) => {
            this.buildMaterialCard(item);
          });
          if (this.getDisplayedMaterials().length === 0) {
            Column({ space: 8 }) {
              Text('这个分类下还没有材料')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#173240');

              Text('先通过扫码或列表选择把材料加进来。')
                .fontSize(12)
                .fontColor('#72838F');
            }
            .width('100%')
            .padding(24)
            .backgroundColor('#FFFFFF')
            .borderRadius(22)
            .border({ width: 1, color: '#D7E6ED' })
            .alignItems(HorizontalAlign.Start);
          }
        }
        .width('100%');
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

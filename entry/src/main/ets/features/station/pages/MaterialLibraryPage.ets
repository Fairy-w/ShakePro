import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import {
  LIBRARY_FILTERS,
  LIBRARY_ITEMS,
  FilterTab,
  SelectableMaterial
} from '../model/BartendingStationMockData';
import {
  getStagingMaterialIds,
  toggleStagingMaterial
} from '../model/MaterialStationStore';

@Entry
@Component
export struct MaterialLibraryPage {
  @State private activeCategoryId: string = 'fruit';
  @State private keyword: string = '';
  @State private stagingMaterialIds: string[] = [];

  aboutToAppear(): void {
    this.refreshStagingMaterials();
  }

  private refreshStagingMaterials(): void {
    this.stagingMaterialIds = getStagingMaterialIds();
  }

  @Builder
  private buildHeader() {
    Column({ space: 14 }) {
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
          Text('从列表选择材料')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text('像备料一样，把水果、软饮、糖浆和杯具加入待入台清单。')
            .fontSize(12)
            .fontColor('#72838F');
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      Row({ space: 10 }) {
        Row({ space: 10 }) {
          Text('查')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#6A8EA0');

          TextInput({ placeholder: '搜索水果、软饮、糖浆或杯具', text: this.keyword })
            .layoutWeight(1)
            .height(46)
            .backgroundColor(Color.Transparent)
            .fontSize(14)
            .placeholderColor('#8BA0AC')
            .onChange((value: string) => {
              this.keyword = value;
            });
        }
        .layoutWeight(1)
        .height(52)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildCategoryTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(LIBRARY_FILTERS, (item: FilterTab) => {
          Text(item.title)
            .fontSize(13)
            .fontWeight(item.id === this.activeCategoryId ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(item.id === this.activeCategoryId ? '#173240' : '#6E818D')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(item.id === this.activeCategoryId ? '#DDF5F1' : '#FFFFFF')
            .borderRadius(18)
            .border({ width: 1, color: item.id === this.activeCategoryId ? '#BFE7E6' : '#D7E6ED' })
            .onClick(() => {
              this.activeCategoryId = item.id;
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
  private buildSummaryCard() {
    Column({ space: 10 }) {
      Row() {
        Text('当前分类')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#245C82')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#E8F5FB')
          .borderRadius(14);

        Blank();

        Text(this.getFilteredMaterials().length.toString() + ' 项可选')
          .fontSize(12)
          .fontColor('#72838F');
      }
      .width('100%');

      Text('先把要用的材料加入待入台清单，再统一确认并加入我的材料。')
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
  private buildStagingEntryCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('待入台清单')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text('已选 ' + this.stagingMaterialIds.length.toString() + ' 项，确认后会直接加入我的材料。')
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(18);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Text('查看 >')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1B596E');
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Button(this.stagingMaterialIds.length === 0 ? '打开待入台清单' : '管理待入台清单', { type: ButtonType.Capsule })
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1B596E')
        .backgroundColor('#DDF5F1')
        .onClick(() => {
          router.pushUrl({ url: 'features/station/pages/MaterialStagingPage' }, 3000);
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      router.pushUrl({ url: 'features/station/pages/MaterialStagingPage' }, 3000);
    });
  }

  @Builder
  private buildLibraryCard(item: SelectableMaterial) {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
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
            .maxLines(3);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      Text(item.quickNote)
        .fontSize(12)
        .fontColor('#5F7684')
        .lineHeight(18)
        .maxLines(2);

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

      Button(this.isInStagingList(item.id) ? '已加入待入台清单' : '加入待入台清单', { type: ButtonType.Capsule })
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isInStagingList(item.id) ? item.accentColor : '#FFFFFF')
        .backgroundColor(this.isInStagingList(item.id) ? item.softColor : item.accentColor)
        .onClick(() => {
          this.handleToggleStaging(item.id, item.name);
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  private handleToggleStaging(materialId: string, materialName: string): void {
    const alreadyAdded: boolean = this.isInStagingList(materialId);
    toggleStagingMaterial(materialId);
    this.refreshStagingMaterials();
    promptAction.showToast({ message: alreadyAdded ? materialName + ' 已从待入台清单移除' : materialName + ' 已加入待入台清单' });
  }

  private resolveLibraryGroupId(item: SelectableMaterial): string {
    if (item.categoryId === 'fruit') {
      return 'fruit';
    }
    if (item.categoryId === 'glassware') {
      return 'glassware';
    }
    if (item.categoryId === 'mixer' && item.categoryName === '糖浆') {
      return 'syrup';
    }
    if (item.categoryId === 'mixer' && item.categoryName === '软饮') {
      return 'soft_drink';
    }
    return '';
  }

  private getFilteredMaterials(): SelectableMaterial[] {
    return LIBRARY_ITEMS.filter((item: SelectableMaterial): boolean => {
      return this.resolveLibraryGroupId(item) === this.activeCategoryId &&
        (this.keyword.length === 0 ||
          item.name.indexOf(this.keyword) !== -1 ||
          item.subtitle.indexOf(this.keyword) !== -1 ||
          item.quickNote.indexOf(this.keyword) !== -1);
    });
  }

  private isInStagingList(materialId: string): boolean {
    return this.stagingMaterialIds.indexOf(materialId) !== -1;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildHeader();
        this.buildCategoryTabs();
        this.buildSummaryCard();
        this.buildStagingEntryCard();

        Column({ space: 12 }) {
          ForEach(this.getFilteredMaterials(), (item: SelectableMaterial) => {
            this.buildLibraryCard(item);
          });
          if (this.getFilteredMaterials().length === 0) {
            Column({ space: 8 }) {
              Text('没有找到匹配材料')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#173240');

              Text('换个关键词，或者切换到其他分类。')
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
      .padding({ left: 16, right: 16, top: 20, bottom: 40 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }
}

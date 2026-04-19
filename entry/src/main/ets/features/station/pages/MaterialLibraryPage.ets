import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import {
  LIBRARY_FILTERS,
  FilterTab,
  SelectableMaterial
} from '../model/BartendingStationMockData';
import {
  clearStagingMaterials,
  getStagingMaterials,
  getStagingMaterialIds,
  saveMaterialDraft,
  toggleStagingMaterial
} from '../model/MaterialStationStore';
import { stationMaterialRepository } from '../repository/StationMaterialRepository';
import { sessionStore } from '../../../common/storage/SessionStore';

@Entry
@Component
export struct MaterialLibraryPage {
  @State private activeCategoryId: string = 'fruit';
  @State private keyword: string = '';
  @State private stagingMaterialIds: string[] = [];
  @State private filterTabs: FilterTab[] = LIBRARY_FILTERS.slice();
  @State private libraryItems: SelectableMaterial[] = [];
  @State private loading: boolean = false;
  @State private requestBusy: boolean = false;

  aboutToAppear(): void {
    this.refreshStagingMaterials();
    void this.refreshLibraryData();
  }

  private refreshStagingMaterials(): void {
    this.stagingMaterialIds = getStagingMaterialIds();
  }

  private getHostContext(): common.BaseContext {
    return this.getUIContext().getHostContext() as common.BaseContext;
  }

  private async ensureSessionStore(): Promise<void> {
    if (sessionStore.isInitialized()) {
      return;
    }

    try {
      await sessionStore.init(this.getHostContext());
    } catch (error) {
      promptAction.showToast({ message: '服务准备中，请稍后再试' });
    }
  }

  private buildFilterId(title: string): string {
    return title.trim().toLowerCase().replace(/[^a-z0-9\u4e00-\u9fa5]+/g, '_');
  }

  private buildCategoryTitlesFromItems(items: SelectableMaterial[]): string[] {
    const titles: string[] = [];
    items.forEach((item: SelectableMaterial) => {
      if (titles.indexOf(item.categoryName) === -1) {
        titles.push(item.categoryName);
      }
    });
    return titles;
  }

  private async refreshLibraryData(): Promise<void> {
    await this.ensureSessionStore();
    this.loading = true;
    try {
      const categories = await stationMaterialRepository.getMaterialCategories();
      const items = await stationMaterialRepository.getManualMaterialOptions();
      const resolvedCategories: string[] = categories.length > 0
        ? categories
        : this.buildCategoryTitlesFromItems(items);
      if (resolvedCategories.length > 0) {
        this.filterTabs = resolvedCategories.map((title: string): FilterTab => {
          return {
            id: this.buildFilterId(title),
            title
          } as FilterTab;
        });
        if (!this.filterTabs.some((item: FilterTab): boolean => item.id === this.activeCategoryId)) {
          this.activeCategoryId = this.filterTabs[0].id;
        }
      }
      this.libraryItems = items;
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      if (typeof message === 'string' && message.trim().length > 0) {
        promptAction.showToast({ message });
      }
    } finally {
      this.loading = false;
    }
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

          Text('直接勾选需要的材料，一次性加入我的材料。')
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
        ForEach(this.filterTabs, (item: FilterTab) => {
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

        Text(this.getFilteredMaterials().length.toString() + ' 项可选 · 已选 ' + this.stagingMaterialIds.length.toString() + ' 项')
          .fontSize(12)
          .fontColor('#72838F');
      }
      .width('100%');

      Text('勾选后可直接提交，不再需要额外确认页。')
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
  private buildSelectionCard() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('当前选择')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text('已选 ' + this.stagingMaterialIds.length.toString() + ' 项，提交后会直接加入我的材料。')
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(18);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        if (this.stagingMaterialIds.length > 0) {
          Button('清空选择', { type: ButtonType.Capsule })
            .height(36)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5A7180')
            .backgroundColor('#EEF5F8')
            .onClick(() => {
              this.clearSelections();
            });
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      if (this.stagingMaterialIds.length === 0) {
        Text('先从下面的列表里选中材料，再点击底部按钮直接加入。')
          .fontSize(12)
          .fontColor('#72838F')
          .lineHeight(18);
      } else {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.getSelectedMaterials(), (item: SelectableMaterial) => {
              Text(item.name)
                .fontSize(12)
                .fontColor(item.accentColor)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(item.softColor)
                .borderRadius(16);
            });
          }
          .padding({ right: 12 });
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
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

      Button(this.isInStagingList(item.id) ? '已选中' : '选中并加入', { type: ButtonType.Capsule })
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
    const materialItem = this.libraryItems.find((item: SelectableMaterial): boolean => item.id === materialId);
    if (!materialItem) {
      promptAction.showToast({ message: '材料信息已过期，请刷新后重试' });
      return;
    }
    toggleStagingMaterial(materialItem);
    this.refreshStagingMaterials();
    promptAction.showToast({ message: alreadyAdded ? materialName + ' 已取消选择' : materialName + ' 已选中' });
  }

  private getFilteredMaterials(): SelectableMaterial[] {
    return this.libraryItems.filter((item: SelectableMaterial): boolean => {
      return this.buildFilterId(item.categoryName) === this.activeCategoryId &&
        (this.keyword.length === 0 ||
          item.name.indexOf(this.keyword) !== -1 ||
          item.subtitle.indexOf(this.keyword) !== -1 ||
          item.quickNote.indexOf(this.keyword) !== -1);
    });
  }

  private isInStagingList(materialId: string): boolean {
    return this.stagingMaterialIds.indexOf(materialId) !== -1;
  }

  private getSelectedMaterials(): SelectableMaterial[] {
    return getStagingMaterials();
  }

  private clearSelections(): void {
    if (this.stagingMaterialIds.length === 0) {
      promptAction.showToast({ message: '当前还没有选中任何材料' });
      return;
    }
    clearStagingMaterials();
    this.refreshStagingMaterials();
    promptAction.showToast({ message: '已清空当前选择' });
  }

  private async submitSelections(): Promise<void> {
    if (this.requestBusy) {
      return;
    }
    const selectedMaterials = this.getSelectedMaterials();
    if (selectedMaterials.length === 0) {
      promptAction.showToast({ message: '请先至少选中 1 项材料' });
      return;
    }

    await this.ensureSessionStore();
    this.requestBusy = true;
    try {
      const savedDrafts = await stationMaterialRepository.batchSaveManualMaterials(selectedMaterials);
      savedDrafts.forEach((item) => {
        saveMaterialDraft(item);
      });
      clearStagingMaterials();
      this.refreshStagingMaterials();
      promptAction.showToast({ message: savedDrafts.length.toString() + ' 项材料已加入我的材料' });
      router.back();
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      promptAction.showToast({
        message: typeof message === 'string' && message.trim().length > 0 ? message : '保存材料失败，请稍后再试'
      });
    } finally {
      this.requestBusy = false;
    }
  }

  @Builder
  private buildBottomBar() {
    Row({ space: 10 }) {
      Button('清空', { type: ButtonType.Capsule })
        .width(96)
        .height(48)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5A7180')
        .backgroundColor('#EEF5F8')
        .enabled(this.stagingMaterialIds.length > 0 && !this.requestBusy)
        .onClick(() => {
          this.clearSelections();
        });

      Button(this.requestBusy
        ? '加入中...'
        : (this.stagingMaterialIds.length === 0
          ? '先选择材料'
          : '加入 ' + this.stagingMaterialIds.length.toString() + ' 项材料'), { type: ButtonType.Capsule })
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#1B596E')
        .enabled(this.stagingMaterialIds.length > 0 && !this.requestBusy)
        .onClick(() => {
          void this.submitSelections();
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor('#F4F8FB');
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 16 }) {
          this.buildHeader();
          this.buildCategoryTabs();
          this.buildSummaryCard();
          this.buildSelectionCard();

          Column({ space: 12 }) {
            if (this.loading) {
              Column({ space: 8 }) {
                Text('正在加载基础材料库')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#173240');

                Text('请稍等一下，马上就好。')
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
            ForEach(this.getFilteredMaterials(), (item: SelectableMaterial) => {
              this.buildLibraryCard(item);
            });
            if (!this.loading && this.getFilteredMaterials().length === 0) {
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
        .padding({ left: 16, right: 16, top: 20, bottom: 108 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F8FB');
      this.buildBottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB');
  }
}

import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { FilterTab, MaterialDraft, SelectableMaterial } from '../model/StationMaterialModels';
import {
  notifyRecordedMaterialsChanged,
  saveMaterialDraft,
  setRecordedMaterialDrafts
} from '../model/MaterialStationStore';
import { stationMaterialRepository } from '../repository/StationMaterialRepository';
import { sessionStore } from '../../../common/storage/SessionStore';
import { OwnershipFilterType } from '../model/StationInventoryFilters';

@Entry
@Component
export struct MaterialLibraryPage {
  @State private activeCategoryId: string = 'all';
  @State private keyword: string = '';
  @State private showSearchInput: boolean = false;
  @State private filterTabs: FilterTab[] = [{ id: 'all', title: '全部' }];
  @State private ownershipFilter: OwnershipFilterType = OwnershipFilterType.ALL;
  @State private showOwnershipFilterSheet: boolean = false;
  @State private libraryItems: SelectableMaterial[] = [];
  @State private selectedMaterialIds: string[] = [];
  @State private ownedMaterialKeys: string[] = [];
  @State private requestBusy: boolean = false;
  @State private loading: boolean = false;
  @State private ownedBarcodeMap: Record<string, string> = {};
  private touchStartAtMap: Record<string, number | null> = {};
  private suppressClickKey: string = '';

  aboutToAppear(): void {
    void this.refreshLibraryData();
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
    const categoryTitles: string[] = [];
    items.forEach((item: SelectableMaterial) => {
      const title = item.categoryName.trim();
      if (title.length === 0) {
        return;
      }
      if (categoryTitles.indexOf(title) === -1) {
        categoryTitles.push(title);
      }
    });
    return categoryTitles;
  }

  private buildMaterialKey(item: SelectableMaterial): string {
    if (typeof item.materialId === 'number' && item.materialId > 0) {
      return `material-${item.materialId.toString()}`;
    }
    return item.id;
  }

  private buildOwnedKeyFromDraft(draft: MaterialDraft): string {
    if (typeof draft.materialId === 'number' && draft.materialId > 0) {
      return `material-${draft.materialId.toString()}`;
    }
    if (draft.id.startsWith('material-')) {
      return draft.id;
    }
    return '';
  }

  private applyOwnedMaterials(drafts: MaterialDraft[]): void {
    const ownedKeys: string[] = [];
    const barcodeMap: Record<string, string> = {};
    drafts.forEach((draft: MaterialDraft) => {
      if (!draft.hasItem) {
        return;
      }
      const ownedKey = this.buildOwnedKeyFromDraft(draft);
      if (ownedKey.length === 0) {
        return;
      }
      if (ownedKeys.indexOf(ownedKey) === -1) {
        ownedKeys.push(ownedKey);
      }
      const barcode = draft.barcode.trim();
      if (barcode.length > 0) {
        barcodeMap[ownedKey] = barcode;
      }
    });

    this.ownedMaterialKeys = ownedKeys;
    this.ownedBarcodeMap = barcodeMap;
    this.selectedMaterialIds = this.selectedMaterialIds.filter((materialId: string): boolean => {
      const item = this.libraryItems.find((libraryItem: SelectableMaterial): boolean => libraryItem.id === materialId);
      if (!item) {
        return false;
      }
      return !this.isOwned(item);
    });
  }

  private mergeOwnedMaterials(drafts: MaterialDraft[]): void {
    const nextOwnedKeys = this.ownedMaterialKeys.slice();
    const nextBarcodeMap: Record<string, string> = {};
    Object.keys(this.ownedBarcodeMap).forEach((key: string) => {
      nextBarcodeMap[key] = this.ownedBarcodeMap[key];
    });

    drafts.forEach((draft: MaterialDraft) => {
      if (!draft.hasItem) {
        return;
      }
      const ownedKey = this.buildOwnedKeyFromDraft(draft);
      if (ownedKey.length === 0) {
        return;
      }
      if (nextOwnedKeys.indexOf(ownedKey) === -1) {
        nextOwnedKeys.push(ownedKey);
      }
      const barcode = draft.barcode.trim();
      if (barcode.length > 0) {
        nextBarcodeMap[ownedKey] = barcode;
      }
    });

    this.ownedMaterialKeys = nextOwnedKeys;
    this.ownedBarcodeMap = nextBarcodeMap;
  }

  private async refreshLibraryData(): Promise<void> {
    await this.ensureSessionStore();
    this.loading = true;
    try {
      const categories = await stationMaterialRepository.getMaterialCategories();
      const items = await stationMaterialRepository.getManualMaterialOptions();
      const userMaterials = await stationMaterialRepository.getUserMaterials();
      const resolvedCategories = categories.length > 0 ? categories : this.buildCategoryTitlesFromItems(items);
      this.filterTabs = ([{ id: 'all', title: '全部' }] as FilterTab[]).concat(resolvedCategories.map((title: string): FilterTab => {
        return {
          id: this.buildFilterId(title),
          title
        } as FilterTab;
      }));

      if (!this.filterTabs.some((item: FilterTab): boolean => item.id === this.activeCategoryId)) {
        this.activeCategoryId = 'all';
      }

      this.libraryItems = items;
      setRecordedMaterialDrafts(userMaterials);
      this.applyOwnedMaterials(userMaterials);
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      promptAction.showToast({
        message: toUserFacingMessage(typeof message === 'string' ? message : undefined, '加载材料库失败，请稍后再试')
      });
    } finally {
      this.loading = false;
    }
  }

  private isOwned(item: SelectableMaterial): boolean {
    return this.ownedMaterialKeys.indexOf(this.buildMaterialKey(item)) !== -1;
  }

  private isSelectedMaterial(materialId: string): boolean {
    return this.selectedMaterialIds.indexOf(materialId) !== -1;
  }

  private isMatchedByOwnershipFilter(item: SelectableMaterial): boolean {
    if (this.ownershipFilter === OwnershipFilterType.OWNED) {
      return this.isOwned(item);
    }
    if (this.ownershipFilter === OwnershipFilterType.UNOWNED) {
      return !this.isOwned(item);
    }
    return true;
  }

  private isMatchedByKeyword(item: SelectableMaterial): boolean {
    const normalizedKeyword = this.keyword.trim().toLowerCase();
    if (normalizedKeyword.length === 0) {
      return true;
    }
    return item.name.toLowerCase().indexOf(normalizedKeyword) !== -1 ||
      item.categoryName.toLowerCase().indexOf(normalizedKeyword) !== -1;
  }

  private isMatchedByCategory(item: SelectableMaterial): boolean {
    if (this.activeCategoryId === 'all') {
      return true;
    }
    return this.buildFilterId(item.categoryName) === this.activeCategoryId;
  }

  private getDisplayedMaterials(): SelectableMaterial[] {
    return this.libraryItems.filter((item: SelectableMaterial): boolean => {
      return this.isMatchedByCategory(item) && this.isMatchedByKeyword(item) && this.isMatchedByOwnershipFilter(item);
    });
  }

  private getSelectedMaterialsForSubmit(): SelectableMaterial[] {
    return this.libraryItems.filter((item: SelectableMaterial): boolean => {
      return this.isSelectedMaterial(item.id) && !this.isOwned(item);
    });
  }

  private getOwnershipFilterLabel(): string {
    if (this.ownershipFilter === OwnershipFilterType.OWNED) {
      return '筛选：已拥有';
    }
    if (this.ownershipFilter === OwnershipFilterType.UNOWNED) {
      return '筛选：未拥有';
    }
    return '筛选：全部';
  }

  private toggleSelected(item: SelectableMaterial): void {
    if (this.isOwned(item)) {
      promptAction.showToast({ message: '该材料已拥有，长按可移除' });
      return;
    }

    if (this.isSelectedMaterial(item.id)) {
      this.selectedMaterialIds = this.selectedMaterialIds.filter((itemId: string): boolean => itemId !== item.id);
      return;
    }
    this.selectedMaterialIds = this.selectedMaterialIds.concat([item.id]);
  }

  private consumeSuppressClick(item: SelectableMaterial): boolean {
    const materialKey = this.buildMaterialKey(item);
    if (this.suppressClickKey !== materialKey) {
      return false;
    }
    this.suppressClickKey = '';
    return true;
  }

  private handleMaterialTouch(item: SelectableMaterial, event: TouchEvent): void {
    const materialKey = this.buildMaterialKey(item);
    if (event.type === TouchType.Down) {
      this.touchStartAtMap[materialKey] = Date.now();
      return;
    }
    if (event.type === TouchType.Up) {
      const touchStartAt = this.touchStartAtMap[materialKey];
      this.touchStartAtMap[materialKey] = null;
      if (touchStartAt === null || typeof touchStartAt !== 'number') {
        return;
      }
      if (Date.now() - touchStartAt < 600) {
        return;
      }
      if (!this.isOwned(item)) {
        return;
      }
      this.suppressClickKey = materialKey;
      void this.removeOwnedMaterial(item);
    }
  }

  private async removeOwnedMaterial(item: SelectableMaterial): Promise<void> {
    if (this.requestBusy) {
      return;
    }
    const materialKey = this.buildMaterialKey(item);
    const barcode = this.ownedBarcodeMap[materialKey];
    if (typeof barcode !== 'string' || barcode.trim().length === 0) {
      promptAction.showToast({ message: '该材料暂无可移除记录' });
      return;
    }

    this.requestBusy = true;
    try {
      await stationMaterialRepository.deleteUserMaterial(barcode);
      const latestUserMaterials = await stationMaterialRepository.getUserMaterials();
      setRecordedMaterialDrafts(latestUserMaterials);
      notifyRecordedMaterialsChanged();
      this.applyOwnedMaterials(latestUserMaterials);
      promptAction.showToast({ message: item.name + ' 已移除' });
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      promptAction.showToast({
        message: toUserFacingMessage(typeof message === 'string' ? message : undefined, '移除失败，请稍后再试')
      });
    } finally {
      this.requestBusy = false;
    }
  }

  private async addSelectedMaterials(): Promise<void> {
    if (this.requestBusy) {
      return;
    }
    const selectedMaterials = this.getSelectedMaterialsForSubmit();
    if (selectedMaterials.length === 0) {
      promptAction.showToast({ message: '请先选中至少 1 个未拥有材料' });
      return;
    }

    this.requestBusy = true;
    try {
      const savedDrafts = await stationMaterialRepository.batchSaveManualMaterials(selectedMaterials, true);
      savedDrafts.forEach((draft: MaterialDraft) => {
        saveMaterialDraft(draft);
      });
      this.selectedMaterialIds = [];
      this.mergeOwnedMaterials(savedDrafts);
      promptAction.showToast({ message: '已添加 ' + savedDrafts.length.toString() + ' 个材料' });
      router.back();
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      promptAction.showToast({
        message: toUserFacingMessage(typeof message === 'string' ? message : undefined, '添加失败，请稍后再试')
      });
    } finally {
      this.requestBusy = false;
    }
  }

  @Builder
  private buildHeader() {
    Column({ space: 12 }) {
      Row() {
        Row() {
          Text('<')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);
        }
        .width(42)
        .height(42)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .onClick(() => {
          router.back();
        });

        Text('材料库')
          .layoutWeight(1)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .margin({ left: 12 });

        Row() {
          Text('⌕')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);
        }
        .width(42)
        .height(42)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary })
        .onClick(() => {
          this.showSearchInput = !this.showSearchInput;
          if (!this.showSearchInput) {
            this.keyword = '';
          }
        });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      if (this.showSearchInput) {
        Row({ space: 8 }) {
          Text('查')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textAccent);

          TextInput({ placeholder: '搜索材料', text: this.keyword })
            .layoutWeight(1)
            .height(44)
            .backgroundColor(Color.Transparent)
            .fontSize(14)
            .placeholderColor(UiTokens.textTertiary)
            .onChange((value: string) => {
              this.keyword = value;
            });
        }
        .width('100%')
        .height(50)
        .padding({ left: 14, right: 14 })
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(16)
        .border({ width: 1, color: UiTokens.borderPrimary });
      }
    }
    .width('100%');
  }

  @Builder
  private buildCategoryAndFilter() {
    Row({ space: 10 }) {
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.filterTabs, (item: FilterTab) => {
            Text(item.title)
              .fontSize(13)
              .fontWeight(item.id === this.activeCategoryId ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(item.id === this.activeCategoryId ? UiTokens.textPrimary : UiTokens.textSecondary)
              .padding({ left: 14, right: 14, top: 9, bottom: 9 })
              .backgroundColor(item.id === this.activeCategoryId ? UiTokens.pageAccentMint : UiTokens.surfacePrimary)
              .borderRadius(16)
              .border({
                width: 1,
                color: item.id === this.activeCategoryId ? UiTokens.borderStrong : UiTokens.borderPrimary
              })
              .onClick(() => {
                this.activeCategoryId = item.id;
              });
          });
        }
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off);

      Button(this.getOwnershipFilterLabel(), { type: ButtonType.Capsule })
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.primary)
        .backgroundColor(UiTokens.primarySoft)
        .onClick(() => {
          this.showOwnershipFilterSheet = true;
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildStatusChip(item: SelectableMaterial) {
    Text(this.isOwned(item) ? '✔ 已添加' : (this.isSelectedMaterial(item.id) ? '✔ 已选中' : '○ 未添加'))
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.isOwned(item)
        ? UiTokens.success
        : (this.isSelectedMaterial(item.id) ? UiTokens.primary : UiTokens.textSecondary))
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.isOwned(item)
        ? UiTokens.successSoft
        : (this.isSelectedMaterial(item.id) ? UiTokens.primarySoft : UiTokens.surfaceOverlay))
      .borderRadius(12);
  }

  private resolveMaterialCardImageUrl(item: SelectableMaterial): string {
    if (typeof item.imageUrlCard === 'string' && item.imageUrlCard.trim().length > 0) {
      return item.imageUrlCard;
    }
    if (typeof item.imageUrlThumb === 'string' && item.imageUrlThumb.trim().length > 0) {
      return item.imageUrlThumb;
    }
    if (typeof item.imageUrl === 'string' && item.imageUrl.trim().length > 0) {
      return item.imageUrl;
    }
    if (typeof item.imageUrlDetail === 'string' && item.imageUrlDetail.trim().length > 0) {
      return item.imageUrlDetail;
    }
    return '';
  }

  @Builder
  private buildMaterialImage(item: SelectableMaterial) {
    if (this.resolveMaterialCardImageUrl(item).length > 0) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height(148)
          .backgroundColor(UiTokens.surfaceSecondary)
          .borderRadius(16);

        Image(this.resolveMaterialCardImageUrl(item))
          .width('100%')
          .height('100%')
          .borderRadius(16)
          .objectFit(ImageFit.Contain)
          .padding(8);
      }
      .width('100%')
      .height(148)
      .backgroundColor(UiTokens.surfaceSecondary)
      .borderRadius(16)
      .clip(true);
    } else {
      Column()
        .width('100%')
        .height(148)
        .backgroundColor(UiTokens.surfaceSecondary)
        .borderRadius(16);
    }
  }

  @Builder
  private buildMaterialCard(item: SelectableMaterial) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 10 }) {
        this.buildMaterialImage(item);

        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        if (typeof item.description === 'string' && item.description.trim().length > 0) {
          Text(item.description)
            .fontSize(11)
            .fontColor(UiTokens.textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }

        Row() {
          Text(item.categoryName)
            .fontSize(11)
            .fontColor(UiTokens.textSecondary);
          Blank();
          if (this.isOwned(item)) {
            Text('长按可移除')
              .fontSize(10)
              .fontColor(UiTokens.textTertiary);
          }
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .opacity(this.isOwned(item) ? 0.58 : 1.0);

      this.buildStatusChip(item);
    }
    .width('100%')
    .height(260)
    .padding(12)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(18)
    .border({
      width: this.isSelectedMaterial(item.id) ? 2 : 1,
      color: this.isSelectedMaterial(item.id) ? UiTokens.primary : UiTokens.borderPrimary
    })
    .onTouch((event: TouchEvent) => {
      this.handleMaterialTouch(item, event);
    })
    .onClick(() => {
      if (this.consumeSuppressClick(item)) {
        return;
      }
      this.toggleSelected(item);
    });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 10 }) {
      Text('暂无匹配材料')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text('可以调整分类、筛选条件或搜索关键字')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);
    }
    .width('100%')
    .padding({ top: 32, bottom: 32 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(20)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildMaterialGrid() {
    if (this.loading) {
      Column({ space: 10 }) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color(UiTokens.primary);
        Text('正在加载材料库...')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%')
      .height(180)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(20)
      .border({ width: 1, color: UiTokens.borderPrimary });
    } else if (this.getDisplayedMaterials().length === 0) {
      this.buildEmptyState();
    } else {
      Grid() {
        ForEach(this.getDisplayedMaterials(), (item: SelectableMaterial) => {
          GridItem() {
            this.buildMaterialCard(item);
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('100%');
    }
  }

  @Builder
  private buildBottomActionBar() {
    if (this.selectedMaterialIds.length > 0) {
      Row({ space: 12 }) {
        Column({ space: 2 }) {
          Text('已选 ' + this.selectedMaterialIds.length.toString() + ' 项')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text('加入后会立刻同步到我的材料库')
            .fontSize(11)
            .fontColor(UiTokens.textSecondary);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button(this.requestBusy ? '加入中...' : '加入我的材料库', { type: ButtonType.Capsule })
          .height(44)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.primary)
          .enabled(!this.requestBusy)
          .onClick(() => {
            void this.addSelectedMaterials();
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 20 })
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius({ topLeft: 22, topRight: 22 })
      .border({ width: 1, color: UiTokens.borderPrimary })
      .shadow({ radius: 18, color: UiTokens.shadowMedium, offsetX: 0, offsetY: -6 });
    }
  }

  @Builder
  private buildOwnershipFilterOption(label: string, value: OwnershipFilterType) {
    Row({ space: 10 }) {
      Text(this.ownershipFilter === value ? '✔' : '○')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.ownershipFilter === value ? UiTokens.primary : UiTokens.textSecondary);

      Text(label)
        .fontSize(14)
        .fontWeight(this.ownershipFilter === value ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 8, bottom: 8 })
    .onClick(() => {
      this.ownershipFilter = value;
      this.showOwnershipFilterSheet = false;
    });
  }

  @Builder
  private buildOwnershipFilterSheet() {
    Column({ space: 10 }) {
      Text('筛选')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      this.buildOwnershipFilterOption('全部', OwnershipFilterType.ALL);
      this.buildOwnershipFilterOption('已拥有', OwnershipFilterType.OWNED);
      this.buildOwnershipFilterOption('未拥有', OwnershipFilterType.UNOWNED);

      Button('取消', { type: ButtonType.Capsule })
        .width('100%')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textSecondary)
        .backgroundColor(UiTokens.pageGradientMiddle)
        .onClick(() => {
          this.showOwnershipFilterSheet = false;
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 18, bottom: 24 })
    .backgroundColor(UiTokens.pageBackground)
    .borderRadius({ topLeft: 24, topRight: 24 });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 14 }) {
          this.buildHeader();
          this.buildCategoryAndFilter();
          this.buildMaterialGrid();
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 18,
          bottom: this.selectedMaterialIds.length > 0 ? 132 : 36
        });
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .backgroundColor(UiTokens.pageBackground)
      .scrollBar(BarState.Off);

      this.buildBottomActionBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground)
    .bindSheet($$this.showOwnershipFilterSheet, this.buildOwnershipFilterSheet, {
      showClose: false,
      height: SheetSize.FIT_CONTENT,
      backgroundColor: UiTokens.pageBackground,
      onDisappear: () => {
        this.showOwnershipFilterSheet = false;
      }
    });
  }
}

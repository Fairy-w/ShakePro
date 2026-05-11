import { RoutePaths } from '../../../core/router/RoutePaths';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { UiTokens } from '../../../common/constants/UiTokens';
import {
  MaterialImagePreviewOverlay,
  MaterialPreviewTagStyle,
  resolveMaterialPreviewImageUrl
} from '../../../common/components/MaterialImagePreviewOverlay';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import { MaterialRecord } from '../../station/model/StationMaterialModels';
import {
  getRecordedMaterials,
  removeRecordedMaterialById,
  setRecordedMaterialDrafts
} from '../../station/model/MaterialStationStore';
import { stationMaterialRepository } from '../../station/repository/StationMaterialRepository';
import { sessionStore } from '../../../common/storage/SessionStore';
import { InventoryTab, INVENTORY_TABS } from '../../station/model/StationInventoryFilters';

@Component
export struct BartendingStationPage {
  @Prop floatingActionBottomInset: number = 0;
  @Prop contentBottomInset: number = 0;
  @StorageLink('station.recordedMaterialsRefreshSignal')
  @Watch('syncRecordedMaterialsFromStore')
  private recordedMaterialsRefreshSignal: number = 0;

  @State private activeTabId: string = 'all';
  @State private keyword: string = '';
  @State private showSearchBar: boolean = false;
  @State private recordedMaterials: MaterialRecord[] = [];
  @State private loading: boolean = false;
  @State private deleteBusy: boolean = false;
  @State private showAddSheet: boolean = false;
  @State private batchMode: boolean = false;
  @State private pendingDeleteIds: string[] = [];
  @State private materialPreviewVisible: boolean = false;
  @State private previewTarget: MaterialRecord | undefined = undefined;

  aboutToAppear(): void {
    void this.refreshRecordedMaterials();
  }

  private syncRecordedMaterialsFromStore(): void {
    if (this.loading) {
      return;
    }
    this.recordedMaterials = getRecordedMaterials();
  }

  private resolveFloatingActionBottomInset(): number {
    return this.floatingActionBottomInset > 0 ? this.floatingActionBottomInset : 16;
  }

  private resolveContentBottomInset(): number {
    return this.contentBottomInset > 0 ? this.contentBottomInset : 120;
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

  private async refreshRecordedMaterials(): Promise<void> {
    await this.ensureSessionStore();
    this.loading = true;
    try {
      const drafts = await stationMaterialRepository.getUserMaterials();
      setRecordedMaterialDrafts(drafts);
      this.recordedMaterials = getRecordedMaterials();
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      if (typeof message === 'string' && message.trim().length > 0) {
        promptAction.showToast({ message: toUserFacingMessage(message, '暂时无法刷新材料列表，请稍后再试') });
      }
      this.recordedMaterials = getRecordedMaterials();
    } finally {
      this.loading = false;
    }
  }

  private normalizeKeyword(): string {
    return this.keyword.trim().toLowerCase();
  }

  private belongsToTab(item: MaterialRecord, tabId: string): boolean {
    if (tabId === 'all') {
      return true;
    }
    if (tabId === 'base_liquor') {
      return item.categoryId === 'spirit' || item.categoryId === 'liqueur';
    }
    if (tabId === 'fruit_flavor') {
      return item.categoryId === 'fruit' || item.categoryId === 'mixer';
    }
    const hasGarnishTag = item.tags.some((tag: string): boolean => {
      return tag.indexOf('装饰') !== -1 || tag.indexOf('香料') !== -1;
    });
    return item.categoryId === 'glassware' || hasGarnishTag;
  }

  private matchesKeyword(item: MaterialRecord): boolean {
    const normalizedKeyword = this.normalizeKeyword();
    if (normalizedKeyword.length === 0) {
      return true;
    }
    const joinedTags = item.tags.join(',');
    return item.name.toLowerCase().indexOf(normalizedKeyword) !== -1 ||
      item.categoryName.toLowerCase().indexOf(normalizedKeyword) !== -1 ||
      item.statusText.toLowerCase().indexOf(normalizedKeyword) !== -1 ||
      joinedTags.toLowerCase().indexOf(normalizedKeyword) !== -1;
  }

  private getDisplayedMaterials(): MaterialRecord[] {
    return this.recordedMaterials.filter((item: MaterialRecord): boolean => {
      return this.belongsToTab(item, this.activeTabId) && this.matchesKeyword(item);
    });
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private resolveAddDateText(addedAt?: string): string {
    if (typeof addedAt !== 'string' || addedAt.trim().length === 0) {
      return '添加日期待同步';
    }
    const parsedDate = new Date(addedAt);
    if (Number.isNaN(parsedDate.getTime())) {
      return '添加于 ' + addedAt.substring(0, Math.min(10, addedAt.length));
    }
    const year = parsedDate.getFullYear().toString();
    const month = (parsedDate.getMonth() + 1).toString().padStart(2, '0');
    const day = parsedDate.getDate().toString().padStart(2, '0');
    return '添加于 ' + year + '-' + month + '-' + day;
  }

  private resolveMaterialCardImageUrl(item: MaterialRecord): string {
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
  private buildMaterialImage(item: MaterialRecord) {
    if (this.resolveMaterialCardImageUrl(item).length > 0) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height(124)
          .backgroundColor(UiTokens.surfaceSecondary)
          .borderRadius(16);

        Image(this.resolveMaterialCardImageUrl(item))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius(16)
          .padding(8);
      }
      .width('100%')
      .height(124)
      .backgroundColor(UiTokens.surfaceSecondary)
      .borderRadius(16)
      .clip(true);
    } else {
      Column()
        .width('100%')
        .height(124)
        .backgroundColor(UiTokens.surfaceSecondary)
        .borderRadius(16);
    }
  }

  private openMaterialPreview(item: MaterialRecord): void {
    this.previewTarget = item;
    this.materialPreviewVisible = true;
  }

  private closeMaterialPreview(): void {
    this.materialPreviewVisible = false;
    this.previewTarget = undefined;
  }

  private getPreviewTitle(): string {
    return this.previewTarget ? this.previewTarget.name : '';
  }

  private getPreviewImageUrl(): string {
    if (!this.previewTarget) {
      return '';
    }
    return resolveMaterialPreviewImageUrl(this.previewTarget);
  }

  private getPreviewPrimaryTag(): MaterialPreviewTagStyle {
    if (!this.previewTarget) {
      return {
        label: '',
        textColor: UiTokens.textAccent,
        backgroundColor: UiTokens.primarySoft
      };
    }
    return {
      label: this.previewTarget.categoryName,
      textColor: this.previewTarget.accentColor,
      backgroundColor: this.previewTarget.softColor
    };
  }

  private getPreviewSecondaryTag(): MaterialPreviewTagStyle {
    if (!this.previewTarget) {
      return {
        label: '',
        textColor: UiTokens.success,
        backgroundColor: UiTokens.successSoft
      };
    }
    const hasItem = this.previewTarget.statusText === '我有';
    return {
      label: this.previewTarget.statusText,
      textColor: hasItem ? UiTokens.success : UiTokens.warning,
      backgroundColor: hasItem ? UiTokens.successSoft : UiTokens.warningSoft
    };
  }

  private toggleBatchMode(): void {
    this.batchMode = !this.batchMode;
    if (!this.batchMode) {
      this.pendingDeleteIds = [];
    }
  }

  private togglePendingDelete(materialId: string): void {
    if (!this.batchMode) {
      this.batchMode = true;
    }
    if (this.pendingDeleteIds.indexOf(materialId) !== -1) {
      this.pendingDeleteIds = this.pendingDeleteIds.filter((itemId: string): boolean => itemId !== materialId);
      return;
    }
    this.pendingDeleteIds = this.pendingDeleteIds.concat([materialId]);
  }

  private async removeMaterial(item: MaterialRecord): Promise<void> {
    if (this.deleteBusy) {
      return;
    }

    const barcode = typeof item.barcode === 'string' ? item.barcode.trim() : '';
    if (barcode.length === 0) {
      promptAction.showToast({ message: '该材料还未同步到可移出状态，请稍后重试' });
      return;
    }

    this.deleteBusy = true;
    try {
      await stationMaterialRepository.deleteUserMaterial(barcode);
      removeRecordedMaterialById(item.id);
      this.recordedMaterials = getRecordedMaterials();
      this.pendingDeleteIds = this.pendingDeleteIds.filter((materialId: string): boolean => materialId !== item.id);
      promptAction.showToast({ message: item.name + ' 已移出调酒台' });
    } catch (error) {
      promptAction.showToast({ message: this.resolveErrorMessage(error as Object, '移出材料失败，请稍后再试') });
    } finally {
      this.deleteBusy = false;
    }
  }

  private async removeSelectedMaterials(): Promise<void> {
    if (this.deleteBusy || this.pendingDeleteIds.length === 0) {
      return;
    }

    this.deleteBusy = true;
    let removedCount = 0;
    let skippedCount = 0;

    for (let index = 0; index < this.pendingDeleteIds.length; index += 1) {
      const materialId = this.pendingDeleteIds[index];
      const targetMaterial = this.recordedMaterials.find((item: MaterialRecord): boolean => item.id === materialId);
      if (!targetMaterial) {
        continue;
      }
      const barcode = typeof targetMaterial.barcode === 'string' ? targetMaterial.barcode.trim() : '';
      if (barcode.length === 0) {
        skippedCount += 1;
        continue;
      }
      try {
        await stationMaterialRepository.deleteUserMaterial(barcode);
        removeRecordedMaterialById(targetMaterial.id);
        removedCount += 1;
      } catch (error) {
      }
    }

    this.recordedMaterials = getRecordedMaterials();
    this.pendingDeleteIds = [];
    this.batchMode = false;
    this.deleteBusy = false;

    if (removedCount > 0) {
      promptAction.showToast({
        message: skippedCount > 0
          ? '已移出 ' + removedCount.toString() + ' 项，另有 ' + skippedCount.toString() + ' 项暂不可删除'
          : '已移出 ' + removedCount.toString() + ' 项材料'
      });
      return;
    }

    promptAction.showToast({ message: '当前选择的材料暂不可删除' });
  }

  @Builder
  private buildHeader() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('我的调酒台（' + this.recordedMaterials.length.toString() + '）')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text('支持扫码录入、手动挑选和批量移出，调酒台状态一眼可查。')
            .fontSize(12)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(18);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Row({ space: 8 }) {
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
          this.showSearchBar = !this.showSearchBar;
          if (!this.showSearchBar) {
            this.keyword = '';
          }
        });
      }
      .width('100%');

      if (this.showSearchBar) {
        Row({ space: 10 }) {
          Text('查')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textAccent);

          TextInput({ placeholder: '搜索已录入材料', text: this.keyword })
            .layoutWeight(1)
            .height(44)
            .backgroundColor(Color.Transparent)
            .fontSize(14)
            .placeholderColor(UiTokens.textTertiary)
            .onChange((value: string) => {
              this.keyword = value;
            });

          if (this.keyword.length > 0) {
            Button('清空', { type: ButtonType.Capsule })
              .height(34)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiTokens.textSecondary)
              .backgroundColor(UiTokens.pageGradientMiddle)
              .onClick(() => {
                this.keyword = '';
              });
          }
        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 12 })
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(18)
        .border({ width: 1, color: UiTokens.borderPrimary });
      }

      Row() {
        Button(this.batchMode ? '完成管理' : '批量管理', { type: ButtonType.Capsule })
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.batchMode ? UiTokens.textPrimary : UiTokens.primary)
          .backgroundColor(this.batchMode ? UiTokens.pageAccentMint : UiTokens.primarySoft)
          .onClick(() => {
            this.toggleBatchMode();
          });

        Blank();

        Button('刷新', { type: ButtonType.Capsule })
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.primary)
          .backgroundColor(UiTokens.primarySoft)
          .enabled(!this.loading)
          .onClick(() => {
            void this.refreshRecordedMaterials();
          });
      }
      .width('100%');

      Row({ space: 12 }) {
        Column()
          .width(10)
          .height(58)
          .borderRadius(8)
          .linearGradient({
            direction: GradientDirection.Top,
            repeating: false,
            colors: [[UiTokens.aiPrimary, 0.0], [UiTokens.primarySoft, 1.0]]
          });

        Column({ space: 6 }) {
          Text('集中管理已录入的材料')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text('已录入 ' + this.recordedMaterials.length.toString() + ' 项材料，支持扫码、搜索和批量管理。')
            .fontSize(12)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(18);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(UiTokens.aiSurface)
      .borderRadius(20)
      .border({ width: 1, color: UiTokens.borderPrimary });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildCategoryTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(INVENTORY_TABS, (item: InventoryTab) => {
          Text(item.title)
            .fontSize(13)
            .fontWeight(item.id === this.activeTabId ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(item.id === this.activeTabId ? UiTokens.textPrimary : UiTokens.textSecondary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(item.id === this.activeTabId ? UiTokens.pageAccentMint : UiTokens.surfacePrimary)
            .borderRadius(18)
            .border({ width: 1, color: item.id === this.activeTabId ? UiTokens.borderStrong : UiTokens.borderPrimary })
            .onClick(() => {
              this.activeTabId = item.id;
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
  private buildTag(label: string, textColor: string, bgColor: string) {
    Text(label)
      .fontSize(11)
      .fontColor(textColor)
      .padding({ left: 8, right: 8, top: 5, bottom: 5 })
      .backgroundColor(bgColor)
      .borderRadius(12);
  }

  @Builder
  private buildDeleteTrigger(item: MaterialRecord) {
    Row() {
      if (this.batchMode) {
        if (this.pendingDeleteIds.indexOf(item.id) !== -1) {
          Text('✓')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.surfacePrimary);
        } else {
          Text('')
            .fontSize(12);
        }
      } else {
        Text('x')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textTertiary);
      }
    }
    .width(28)
    .height(28)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.batchMode
      ? (this.pendingDeleteIds.indexOf(item.id) !== -1 ? UiTokens.primary : UiTokens.pageGradientMiddle)
      : UiTokens.surfacePrimary)
    .borderRadius(14)
    .border({ width: 1, color: this.batchMode ? UiTokens.borderSecondary : UiTokens.borderPrimary })
    .onClick(() => {
      if (this.batchMode) {
        this.togglePendingDelete(item.id);
        return;
      }
      void this.removeMaterial(item);
    });
  }

  @Builder
  private buildMaterialCard(item: MaterialRecord) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 10 }) {
        this.buildMaterialImage(item);

        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(this.resolveAddDateText(item.addedAt))
          .fontSize(11)
          .fontColor(UiTokens.textSecondary);

        Row({ space: 6 }) {
          this.buildTag(
            item.statusText,
            item.statusText === '我有' ? UiTokens.success : UiTokens.warning,
            item.statusText === '我有' ? UiTokens.successSoft : UiTokens.warningSoft
          );
          this.buildTag(item.categoryName, item.accentColor, item.softColor);
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      this.buildDeleteTrigger(item);
    }
    .width('100%')
    .height(246)
    .padding(12)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(18)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .onClick(() => {
      if (this.batchMode) {
        this.togglePendingDelete(item.id);
        return;
      }
      this.openMaterialPreview(item);
    });
  }

  @Builder
  private buildLoadingCard() {
    Column({ space: 8 }) {
      LoadingProgress()
        .width(24)
        .height(24)
        .color(UiTokens.primary);

      Text('正在同步材料...')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);
    }
    .width('100%')
    .height(160)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(18)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 12 }) {
      Image($r('app.media.icon_cocktail'))
        .width(88)
        .height(88)
        .opacity(0.9)
        .objectFit(ImageFit.Contain);

      Text('还没材料？快扫码添加一个吧')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      Text('点底部 + 进入扫码或手动挑选，录入后会自动刷新列表。')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .textAlign(TextAlign.Center)
        .lineHeight(18);
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(20)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildInventoryGrid() {
    if (this.loading) {
      Grid() {
        ForEach([0, 1, 2, 3], (item: number) => {
          GridItem() {
            this.buildLoadingCard();
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('100%');
    } else if (this.getDisplayedMaterials().length === 0) {
      this.buildEmptyState();
    } else {
      Grid() {
        ForEach(this.getDisplayedMaterials(), (item: MaterialRecord) => {
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
  private buildFloatingActionBar() {
    Column({ space: 12 }) {
      if (this.batchMode) {
        Row({ space: 10 }) {
          Text('已选 (' + this.pendingDeleteIds.length.toString() + ')')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Blank();

          Button(this.deleteBusy ? '移出中...' : '批量移出', { type: ButtonType.Capsule })
            .height(34)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.error)
            .backgroundColor(UiTokens.errorSoft)
            .enabled(!this.deleteBusy && this.pendingDeleteIds.length > 0)
            .onClick(() => {
              void this.removeSelectedMaterials();
            });
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(18)
        .border({ width: 1, color: UiTokens.borderPrimary });
      }

      Column({ space: 6 }) {
        Row() {
          Text('+')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.surfacePrimary);
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(UiTokens.primary)
        .borderRadius(39)
        .shadow({ radius: 20, color: UiTokens.shadowMedium, offsetX: 0, offsetY: 5 });

      }
      .onClick(() => {
        this.showAddSheet = true;
      });
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: this.resolveFloatingActionBottomInset() })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private buildAddEntryAction(title: string, detail: string, accentColor: string, softColor: string, onTap: () => void) {
    Row({ space: 12 }) {
      Row() {
        Text(title.substring(0, 1))
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(accentColor);
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(softColor)
      .borderRadius(16);

      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(detail)
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(18)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(14)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(18)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .onClick(() => {
      onTap();
    });
  }

  @Builder
  private buildAddSheet() {
    Column({ space: 12 }) {
      Text('添加材料')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text('选择录入方式：扫码快速识别，或进入材料百科手动挑选。')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(18)
        .width('100%');

      this.buildAddEntryAction('扫码添加', '调起相机后自动识别条码，一键存入调酒台。', UiTokens.primary, UiTokens.pageAccentMint, () => {
        this.showAddSheet = false;
        router.pushUrl({ url: RoutePaths.MATERIAL_SCANNER }, 3000);
      });

      this.buildAddEntryAction('手动挑选', '进入材料百科进行多选，适合水果、调味和装饰材料。', UiTokens.primary, UiTokens.primarySoft, () => {
        this.showAddSheet = false;
        router.pushUrl({ url: RoutePaths.MATERIAL_LIBRARY }, 3000);
      });

      Button('取消', { type: ButtonType.Capsule })
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textSecondary)
        .backgroundColor(UiTokens.pageGradientMiddle)
        .onClick(() => {
          this.showAddSheet = false;
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
        Column({ space: 16 }) {
          this.buildHeader();
          this.buildCategoryTabs();
          this.buildInventoryGrid();
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 18, bottom: this.resolveContentBottomInset() });
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .backgroundColor(UiTokens.pageBackground)
      .scrollBar(BarState.Off);
      this.buildFloatingActionBar();

      if (this.materialPreviewVisible) {
        MaterialImagePreviewOverlay({
          title: this.getPreviewTitle(),
          imageUrl: this.getPreviewImageUrl(),
          primaryTag: this.getPreviewPrimaryTag(),
          secondaryTag: this.getPreviewSecondaryTag(),
          onClose: () => {
            this.closeMaterialPreview();
          }
        });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground)
    .bindSheet($$this.showAddSheet, this.buildAddSheet, {
      showClose: false,
      height: SheetSize.FIT_CONTENT,
      backgroundColor: UiTokens.pageBackground,
      onDisappear: () => {
        this.showAddSheet = false;
      }
    });
  }
}

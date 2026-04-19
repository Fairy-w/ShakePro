import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { sessionStore } from '../../../common/storage/SessionStore';
import {
  MATERIAL_CATEGORIES,
  MaterialCategory,
  MaterialDraft,
  getDraftById
} from '../model/BartendingStationMockData';
import { getRecordedDraftById, removeRecordedMaterialById, saveMaterialDraft } from '../model/MaterialStationStore';
import { stationMaterialRepository } from '../repository/StationMaterialRepository';

interface EditorRouteParams {
  materialId?: string;
  source?: string;
  draftJson?: string;
}
@Entry
@Component
export struct MaterialEditorPage {
  private readonly remainOptions: string[] = ['满瓶', '2/3', '1/3', '少量'];
  private readonly flavorTags: string[] = ['柑橘', '草本', '甜感', '苦味', '辛香', '气泡', '清新', '经典'];

  @State private materialId: string = '';
  @State private source: string = 'manual';
  @State private sourceLabel: string = '手动录入';
  @State private subtitle: string = '';
  @State private badge: string = 'NM';
  @State private accentColor: string = '#1B596E';
  @State private softColor: string = '#DDF5F1';
  @State private name: string = '';
  @State private brand: string = '';
  @State private barcode: string = '';
  @State private capacityText: string = '';
  @State private categoryId: string = 'spirit';
  @State private remainLevel: string = '满瓶';
  @State private opened: boolean = false;
  @State private hasItem: boolean = true;
  @State private note: string = '';
  @State private selectedTags: string[] = [];
  @State private standardMaterialId: number | undefined = undefined;
  @State private requestBusy: boolean = false;
  @State private deleteBusy: boolean = false;

  aboutToAppear(): void {
    const routeParams: EditorRouteParams = router.getParams() as EditorRouteParams;
    void this.ensureSessionStore();
    this.loadDraft(routeParams);
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

  private async hasAuthorization(): Promise<boolean> {
    await this.ensureSessionStore();
    if (!sessionStore.isInitialized()) {
      return false;
    }
    const authorization = await sessionStore.getAuthorizationValue();
    return authorization.trim().length > 0;
  }

  private loadDraft(routeParams?: EditorRouteParams): void {
    const draft: MaterialDraft = this.resolveRouteDraft(routeParams);
    this.applyDraft(draft);
  }

  private resolveRouteDraft(routeParams?: EditorRouteParams): MaterialDraft {
    const routeDraft = this.parseRouteDraft(routeParams?.draftJson);
    if (routeDraft !== undefined) {
      return routeDraft;
    }
    const cachedDraft = getRecordedDraftById(routeParams?.materialId);
    if (cachedDraft !== undefined) {
      return cachedDraft;
    }
    return getDraftById(routeParams?.materialId);
  }

  private parseRouteDraft(draftJson?: string): MaterialDraft | undefined {
    if (typeof draftJson !== 'string' || draftJson.trim().length === 0) {
      return undefined;
    }

    try {
      const parsedDraft = JSON.parse(draftJson) as MaterialDraft;
      if (typeof parsedDraft.id !== 'string' || parsedDraft.id.trim().length === 0) {
        return undefined;
      }
      return parsedDraft;
    } catch (error) {
      return undefined;
    }
  }

  private applyDraft(draft: MaterialDraft): void {
    this.materialId = draft.id;
    this.source = draft.source;
    this.sourceLabel = draft.sourceLabel;
    this.subtitle = draft.subtitle;
    this.badge = draft.badge;
    this.accentColor = draft.accentColor;
    this.softColor = draft.softColor;
    this.name = draft.name;
    this.brand = draft.brand;
    this.barcode = draft.barcode;
    this.capacityText = draft.capacityText;
    this.categoryId = draft.categoryId;
    this.remainLevel = draft.remainLevel;
    this.opened = draft.opened;
    this.hasItem = draft.hasItem;
    this.note = draft.note;
    this.selectedTags = draft.tags.slice();
    this.standardMaterialId = draft.materialId;
  }

  private isPresenceOnlyCategory(): boolean {
    return this.categoryId === 'fruit' || this.categoryId === 'glassware';
  }

  private getPresenceCategoryTitle(): string {
    if (this.categoryId === 'fruit') {
      return '水果与装饰';
    }
    if (this.categoryId === 'glassware') {
      return '杯具与工具';
    }
    return '材料';
  }

  private getPrimaryActionText(): string {
    if (this.isPresenceOnlyCategory()) {
      return '保存有无状态';
    }
    return '保存修改';
  }

  private canDeleteMaterial(): boolean {
    return this.barcode.trim().length > 0;
  }

  private getSaveToastMessage(): string {
    if (this.isPresenceOnlyCategory() && !this.hasItem) {
      return this.name + ' 已标记为没有';
    }
    if (this.isPresenceOnlyCategory()) {
      return this.name + ' 已标记为有';
    }
    return this.name + ' 已保存到材料台';
  }

  private buildDraftSnapshot(): MaterialDraft {
    return {
      id: this.materialId,
      source: this.source,
      sourceLabel: this.sourceLabel,
      name: this.name,
      subtitle: this.subtitle,
      brand: this.brand,
      categoryId: this.categoryId,
      barcode: this.barcode,
      materialId: this.standardMaterialId,
      capacityText: this.capacityText,
      remainLevel: this.remainLevel,
      opened: this.opened,
      hasItem: this.hasItem,
      tags: this.selectedTags.slice(),
      note: this.note,
      badge: this.badge,
      accentColor: this.accentColor,
      softColor: this.softColor
    };
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    if (typeof message === 'string' && message.trim().length > 0) {
      return message;
    }
    return fallbackMessage;
  }

  private shouldRedirectToLogin(error: Object): boolean {
    const errorObject = error as Record<string, Object>;
    const code = errorObject['code'];
    const statusCode = errorObject['statusCode'];
    return code === 40100 || statusCode === 401;
  }

  private navigateToLogin(message: string): void {
    promptAction.showToast({ message });
    router.pushUrl({ url: 'features/auth/pages/LoginPage' });
  }

  private async handleDelete(): Promise<void> {
    if (this.deleteBusy || this.requestBusy) {
      return;
    }

    if (!(await this.hasAuthorization())) {
      this.navigateToLogin('请先登录后再删除材料');
      return;
    }

    if (!this.canDeleteMaterial()) {
      promptAction.showToast({ message: '当前材料还未保存，无法删除' });
      return;
    }

    this.deleteBusy = true;
    try {
      await stationMaterialRepository.deleteUserMaterial(this.barcode);
      removeRecordedMaterialById(this.materialId);
      promptAction.showToast({ message: this.name + ' 已从材料台移除' });
      router.back();
    } catch (error) {
      const message = this.resolveErrorMessage(error as Object, '删除材料失败，请稍后再试');
      promptAction.showToast({ message });
      if (this.shouldRedirectToLogin(error as Object)) {
        router.pushUrl({ url: 'features/auth/pages/LoginPage' });
      }
    } finally {
      this.deleteBusy = false;
    }
  }

  private async handleSave(): Promise<void> {
    if (this.requestBusy) {
      return;
    }

    if (!(await this.hasAuthorization())) {
      this.navigateToLogin('请先登录后再保存材料');
      return;
    }

    this.requestBusy = true;
    try {
      const draftSnapshot = this.buildDraftSnapshot();
      const savedDraft = draftSnapshot.source === 'scan'
        ? await stationMaterialRepository.saveScannedMaterial(draftSnapshot)
        : await stationMaterialRepository.saveManualMaterial(draftSnapshot);
      this.standardMaterialId = savedDraft.materialId;
      saveMaterialDraft(savedDraft);
      promptAction.showToast({ message: this.getSaveToastMessage() });
      router.back();
    } catch (error) {
      const message = this.resolveErrorMessage(error as Object, '保存材料失败，请稍后再试');
      promptAction.showToast({ message });
      if (this.shouldRedirectToLogin(error as Object)) {
        router.pushUrl({ url: 'features/auth/pages/LoginPage' });
      }
    } finally {
      this.requestBusy = false;
    }
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
        Text('快速编辑材料')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('优先调整库存状态，其他信息放在下面按需补充。')
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
  private buildSourceCard() {
    Row({ space: 14 }) {
      Row() {
        Text(this.badge)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.accentColor);
      }
      .width(58)
      .height(58)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.softColor)
      .borderRadius(20);

      Column({ space: 6 }) {
        Text(this.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text(this.sourceLabel)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.accentColor)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.softColor)
          .borderRadius(14);

        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#72838F')
          .lineHeight(18)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildPresenceOnlySection() {
    Column({ space: 14 }) {
      this.buildSectionTitle('有无状态', '水果和杯具只需要标记有或者没有，不需要补充别的信息。');

      Column({ space: 10 }) {
        this.buildFieldLabel(this.getPresenceCategoryTitle() + '状态');

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('有')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.hasItem ? '#2B6C63' : '#173240');

            Text('会参与后续推荐和材料匹配')
              .fontSize(12)
              .fontColor('#72838F')
              .lineHeight(18)
              .textAlign(TextAlign.Center);
          }
          .layoutWeight(1)
          .padding({ top: 18, bottom: 18, left: 12, right: 12 })
          .backgroundColor(this.hasItem ? '#EEF6F2' : '#F4F8FB')
          .borderRadius(20)
          .border({ width: 1, color: this.hasItem ? '#BEE0D2' : '#D7E6ED' })
          .onClick(() => {
            this.hasItem = true;
          });

          Column({ space: 8 }) {
            Text('没有')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(!this.hasItem ? '#A66A1C' : '#173240');

            Text('暂不参与推荐，后续仍可再修改')
              .fontSize(12)
              .fontColor('#72838F')
              .lineHeight(18)
              .textAlign(TextAlign.Center);
          }
          .layoutWeight(1)
          .padding({ top: 18, bottom: 18, left: 12, right: 12 })
          .backgroundColor(!this.hasItem ? '#F8E9CF' : '#F4F8FB')
          .borderRadius(20)
          .border({ width: 1, color: !this.hasItem ? '#E4C892' : '#D7E6ED' })
          .onClick(() => {
            this.hasItem = false;
          });
        }
        .width('100%');
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildSectionTitle(title: string, subtitle: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text(subtitle)
        .fontSize(12)
        .fontColor('#72838F')
        .lineHeight(18);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildFieldLabel(label: string) {
    Text(label)
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor('#173240');
  }

  @Builder
  private buildInputCard(label: string, value: string, placeholder: string, onChange: (value: string) => void) {
    Column({ space: 10 }) {
      this.buildFieldLabel(label);
      TextInput({ placeholder, text: value })
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F4F8FB')
        .borderRadius(16)
        .fontSize(14)
        .placeholderColor('#90A4AE')
        .onChange((text: string) => {
          onChange(text);
        });
    }
    .width('100%');
  }

  @Builder
  private buildCategoryChip(item: MaterialCategory) {
    Text(item.title)
      .fontSize(12)
      .fontWeight(item.id === this.categoryId ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(item.id === this.categoryId ? item.accentColor : '#72838F')
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(item.id === this.categoryId ? item.softColor : '#F4F8FB')
      .borderRadius(16)
      .border({ width: 1, color: item.id === this.categoryId ? item.softColor : '#E3EDF2' })
      .margin({ right: 10, bottom: 10 })
      .onClick(() => {
        this.categoryId = item.id;
      });
  }

  @Builder
  private buildRemainChip(option: string) {
    Text(option)
      .fontSize(12)
      .fontWeight(option === this.remainLevel ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(option === this.remainLevel ? '#245C82' : '#72838F')
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(option === this.remainLevel ? '#E8F5FB' : '#F4F8FB')
      .borderRadius(16)
      .margin({ right: 10, bottom: 10 })
      .onClick(() => {
        this.remainLevel = option;
      });
  }

  @Builder
  private buildBooleanChip(title: string, selected: boolean, onTap: () => void) {
    Text(title)
      .fontSize(12)
      .fontWeight(selected ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(selected ? '#2B6C63' : '#72838F')
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(selected ? '#EEF6F2' : '#F4F8FB')
      .borderRadius(16)
      .margin({ right: 10, bottom: 10 })
      .onClick(() => {
        onTap();
      });
  }

  @Builder
  private buildTagChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontWeight(this.selectedTags.indexOf(tag) !== -1 ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.selectedTags.indexOf(tag) !== -1 ? '#A66A1C' : '#72838F')
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(this.selectedTags.indexOf(tag) !== -1 ? '#F8E9CF' : '#F4F8FB')
      .borderRadius(16)
      .margin({ right: 10, bottom: 10 })
      .onClick(() => {
        this.toggleTag(tag);
      });
  }

  private toggleTag(tag: string): void {
    const nextTags: string[] = [];
    let existed = false;
    this.selectedTags.forEach((item: string) => {
      if (item === tag) {
        existed = true;
        return;
      }
      nextTags.push(item);
    });
    if (!existed) {
      nextTags.push(tag);
    }
    this.selectedTags = nextTags;
  }

  @Builder
  private buildQuickInventorySection() {
    Column({ space: 14 }) {
      this.buildSectionTitle('快速状态', '先处理有货、开封和剩余量，这是最常用的库存修改。');

      Column({ space: 10 }) {
        this.buildFieldLabel('当前状态');
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start
        }) {
          this.buildBooleanChip('有货', this.hasItem, () => {
            this.hasItem = true;
          });
          this.buildBooleanChip('缺货', !this.hasItem, () => {
            this.hasItem = false;
          });
          this.buildBooleanChip('已开封', this.opened, () => {
            this.opened = true;
          });
          this.buildBooleanChip('未开封', !this.opened, () => {
            this.opened = false;
          });
        }
        .width('100%');
      }
      .width('100%');

      this.buildInputCard('容量 / 数量', this.capacityText, '例如 700ml / 6 瓶 / 4 只', (value: string) => {
        this.capacityText = value;
      });

      Column({ space: 10 }) {
        this.buildFieldLabel('剩余量');
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start
        }) {
          ForEach(this.remainOptions, (item: string) => {
            this.buildRemainChip(item);
          });
        }
        .width('100%');
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildSupplementSection() {
    Column({ space: 14 }) {
      this.buildSectionTitle('补充信息', '只在需要时补充品牌、分类和风味标签，不强制一次填完。');
      this.buildInputCard('材料名称', this.name, '例如 亨利爵士金酒', (value: string) => {
        this.name = value;
      });
      this.buildInputCard('品牌 / 来源', this.brand, '例如 Hendrick\'s / 鲜果材料', (value: string) => {
        this.brand = value;
      });
      Column({ space: 10 }) {
        this.buildFieldLabel('所属分类');
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start
        }) {
          ForEach(MATERIAL_CATEGORIES, (item: MaterialCategory) => {
            this.buildCategoryChip(item);
          });
        }
        .width('100%');
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildBottomBar() {
    Column({ space: 10 }) {
      if (this.canDeleteMaterial()) {
        Button(this.deleteBusy ? '删除中...' : '删除材料', { type: ButtonType.Capsule })
          .width('100%')
          .height(44)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#B42318')
          .backgroundColor('#FDECEC')
          .enabled(!this.requestBusy && !this.deleteBusy)
          .onClick(() => {
            void this.handleDelete();
          });
      }

      Row({ space: 10 }) {
        Button('取消', { type: ButtonType.Capsule })
          .width(96)
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5A7180')
          .backgroundColor('#EEF5F8')
          .enabled(!this.requestBusy && !this.deleteBusy)
          .onClick(() => {
            router.back();
          });

        Button(this.requestBusy ? '保存中...' : this.getPrimaryActionText(), { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(this.accentColor)
          .enabled(!this.requestBusy && !this.deleteBusy)
          .onClick(() => {
            void this.handleSave();
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor('#F4F8FB');
  }

  @Builder
  private buildTagSection() {
    Column({ space: 14 }) {
      this.buildSectionTitle('风味标签', '仅在你想优化后续推荐时再补充。');
      Column({ space: 10 }) {
        this.buildFieldLabel('已选标签');
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start
        }) {
          ForEach(this.flavorTags, (item: string) => {
            this.buildTagChip(item);
          });
        }
        .width('100%');
      }
      .width('100%');

      this.buildInputCard('备注', this.note, '例如 适合清爽型 long drink', (value: string) => {
        this.note = value;
      });
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 16 }) {
          this.buildHeader();
          this.buildSourceCard();
          if (this.isPresenceOnlyCategory()) {
            this.buildPresenceOnlySection();
          } else {
            this.buildQuickInventorySection();
            this.buildSupplementSection();
            this.buildTagSection();
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 148 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F8FB')
      .scrollBar(BarState.Off);

      this.buildBottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8FB');
  }
}

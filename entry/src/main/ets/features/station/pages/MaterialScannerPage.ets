import { RoutePaths } from '../../../core/router/RoutePaths';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { customScan, scanCore } from '@kit.ScanKit';
import { UiTokens } from '../../../common/constants/UiTokens';
import { toUserFacingMessage } from '../../../common/network/ApiResponse';
import {
  MaterialImagePreviewOverlay,
  MaterialPreviewTagStyle,
  resolveMaterialPreviewImageUrl
} from '../../../common/components/MaterialImagePreviewOverlay';
import { sessionStore } from '../../../common/storage/SessionStore';
import { MaterialDraft } from '../model/StationMaterialModels';
import { saveMaterialDraft } from '../model/MaterialStationStore';
import { stationMaterialRepository } from '../repository/StationMaterialRepository';
import { Position, ScanOptions, ScanResult, ViewControl } from '../model/ScannerViewModels';

@Entry
@Component
export struct MaterialScannerPage {
  @State private flashEnabled: boolean = false;
  @State private manualMode: boolean = false;
  @State private manualBarcode: string = '';
  @State private scanResult: MaterialDraft | undefined = undefined;
  @State private showScanResult: boolean = false;
  @State private cameraBusy: boolean = false;
  @State private requestBusy: boolean = false;
  @State private previewReady: boolean = false;
  @State private scannerStatus: string = '正在准备相机预览...';
  @State private materialPreviewVisible: boolean = false;
  @State private previewTarget: MaterialDraft | undefined = undefined;

  private readonly cameraPermissionList: Permissions[] = ['ohos.permission.CAMERA'];
  private readonly previewWidthVp: number = 328;
  private readonly previewHeightVp: number = 320;
  private readonly previewController: XComponentController = new XComponentController();
  private previewSurfaceId: string = '';
  private scannerInitialized: boolean = false;
  private scannerStarted: boolean = false;
  private lastRecognizedBarcode: string = '';

  aboutToAppear(): void {
    void this.ensureSessionStore();
  }

  aboutToDisappear(): void {
    void this.releaseScanner();
  }

  private getHostContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
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

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private shouldRedirectToLogin(error: Object): boolean {
    const errorObject = error as Record<string, Object>;
    const code = errorObject['code'];
    const statusCode = errorObject['statusCode'];
    return code === 40100 || statusCode === 401;
  }

  private navigateToLogin(message: string): void {
    promptAction.showToast({ message });
    router.pushUrl({ url: RoutePaths.LOGIN });
  }

  private getPrimaryScanButtonText(): string {
    if (this.requestBusy) {
      return '识别中...';
    }
    if (this.cameraBusy) {
      return '扫描中...';
    }
    if (this.showScanResult) {
      return '重新扫描';
    }
    return '开始扫描';
  }

  private getScannerHeadline(): string {
    if (this.requestBusy) {
      return '正在识别商品信息';
    }
    if (this.cameraBusy) {
      return '正在框内识别条码';
    }
    if (this.previewReady) {
      return '将酒瓶条码放入框内';
    }
    return '正在加载相机预览';
  }

  private getScannerSubline(): string {
    if (this.requestBusy) {
      return '已捕获条码，正在查询商品信息。';
    }
    if (this.cameraBusy) {
      return '请将条码保持在黄色扫描框内，系统会自动识别。';
    }
    if (this.previewReady) {
      return '识别成功后直接标记你现在是否持有，不再补库存细节。';
    }
    return '请稍候，等待扫描组件完成预览初始化。';
  }

  private getStatusChipText(): string {
    if (this.requestBusy) {
      return '识别结果查询中';
    }
    if (this.cameraBusy) {
      return '实时扫描中';
    }
    if (this.previewReady) {
      return '实时预览';
    }
    return '预览初始化';
  }

  private openMaterialPreview(item: MaterialDraft): void {
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
    const sourceLabel = this.previewTarget.sourceLabel.trim().length > 0 ? this.previewTarget.sourceLabel : '扫码识别';
    return {
      label: sourceLabel,
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
    const hasItem = this.previewTarget.hasItem;
    return {
      label: hasItem ? '我有' : '暂时没有',
      textColor: hasItem ? UiTokens.success : UiTokens.warning,
      backgroundColor: hasItem ? UiTokens.successSoft : UiTokens.warningSoft
    };
  }

  private buildScanOptions(): ScanOptions {
    return {
      scanTypes: [
        scanCore.ScanType.EAN13_CODE,
        scanCore.ScanType.EAN8_CODE,
        scanCore.ScanType.UPC_A_CODE,
        scanCore.ScanType.UPC_E_CODE,
        scanCore.ScanType.CODE128_CODE,
        scanCore.ScanType.CODE39_CODE,
        scanCore.ScanType.CODABAR_CODE
      ],
      enableMultiMode: false,
      enableAlbum: false
    };
  }

  private buildViewControl(): ViewControl {
    return {
      width: Math.round(vp2px(this.previewWidthVp)),
      height: Math.round(vp2px(this.previewHeightVp)),
      surfaceId: this.previewSurfaceId
    };
  }

  private pickRecognizedBarcode(results: Array<ScanResult>): string {
    for (let index = 0; index < results.length; index++) {
      const value = results[index].originalValue;
      if (typeof value === 'string' && value.trim().length > 0) {
        return value.trim();
      }
    }
    return '';
  }

  private async ensureCameraPermission(): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result = await atManager.requestPermissionsFromUser(this.getHostContext(), this.cameraPermissionList);
      if (result.authResults.length === 0) {
        return false;
      }
      return result.authResults[0] === 0;
    } catch (error) {
      promptAction.showToast({ message: '相机权限申请失败' });
      return false;
    }
  }

  private async initScannerIfNeeded(): Promise<void> {
    if (this.scannerInitialized) {
      return;
    }
    customScan.init(this.buildScanOptions());
    this.scannerInitialized = true;
  }

  private async stopScanner(): Promise<void> {
    if (this.flashEnabled) {
      try {
        customScan.closeFlashLight();
      } catch (error) {
      }
      this.flashEnabled = false;
    }

    if (this.scannerInitialized) {
      try {
        await customScan.stop();
      } catch (error) {
      }
    }

    this.scannerStarted = false;
    this.cameraBusy = false;
  }

  private async releaseScanner(): Promise<void> {
    await this.stopScanner();
    if (!this.scannerInitialized) {
      return;
    }
    try {
      await customScan.release();
    } catch (error) {
    }
    this.scannerInitialized = false;
  }

  private async resetScannerSession(): Promise<void> {
    await this.releaseScanner();
    if (this.previewReady) {
      this.scannerStatus = '相机预览已就绪，可开始扫描';
    }
  }

  private async handlePreviewLoad(): Promise<void> {
    this.previewSurfaceId = this.previewController.getXComponentSurfaceId();
    this.previewReady = this.previewSurfaceId.length > 0;
    this.scannerStatus = this.previewReady ? '相机预览已就绪，可开始扫描' : '相机预览初始化失败';
    if (this.previewReady) {
      void this.startScannerPreview();
    }
  }

  private async toggleFlashLight(): Promise<void> {
    if (!this.previewReady || !this.scannerInitialized || !this.scannerStarted) {
      promptAction.showToast({ message: '请先开始扫描，再切换闪光灯' });
      return;
    }

    try {
      if (this.flashEnabled) {
        customScan.closeFlashLight();
        this.flashEnabled = false;
        return;
      }
      customScan.openFlashLight();
      this.flashEnabled = true;
    } catch (error) {
      promptAction.showToast({ message: '当前无法切换闪光灯' });
    }
  }

  private async startScannerPreview(): Promise<void> {
    if (this.cameraBusy || this.requestBusy) {
      return;
    }
    if (!this.previewReady || this.previewSurfaceId.length === 0) {
      promptAction.showToast({ message: '相机预览还未准备好，请稍后再试' });
      return;
    }

    const granted = await this.ensureCameraPermission();
    if (!granted) {
      promptAction.showToast({ message: '未获得相机权限，无法开始扫描' });
      return;
    }

    this.showScanResult = false;
    this.scanResult = undefined;
    this.lastRecognizedBarcode = '';
    this.scannerStatus = '请将酒瓶条码对准扫描框中心';

    try {
      await this.resetScannerSession();
      await this.initScannerIfNeeded();
      this.cameraBusy = true;
      this.scannerStarted = true;
      const results = await customScan.start(this.buildViewControl());
      await this.resetScannerSession();

      if (!Array.isArray(results) || results.length === 0) {
        this.scannerStatus = '未识别到条码，请调整距离后重试';
        promptAction.showToast({ message: '未识别到有效条码' });
        return;
      }

      const barcode = this.pickRecognizedBarcode(results);
      if (barcode.length === 0) {
        this.scannerStatus = '未识别到有效条码，请调整距离后重试';
        promptAction.showToast({ message: '未识别到有效条码' });
        return;
      }

      this.lastRecognizedBarcode = barcode;
      this.scannerStatus = '已识别到条码，正在查询商品信息';
      await this.lookupBarcode(barcode, '扫描成功，已识别到条码');
    } catch (error) {
      await this.resetScannerSession();
      this.scannerStatus = '启动扫码失败，请稍后重试';
      promptAction.showToast({ message: this.resolveErrorMessage(error as Object, '启动扫码失败，请稍后重试') });
    }
  }

  private async lookupBarcode(barcode: string, successMessage: string): Promise<void> {
    if (this.requestBusy) {
      return;
    }

    if (!(await this.hasAuthorization())) {
      await this.resetScannerSession();
      this.navigateToLogin('请先登录后再识别条码');
      return;
    }

    this.requestBusy = true;
    this.showScanResult = false;
    this.scanResult = undefined;

    try {
      const draft = await stationMaterialRepository.lookupBarcode({
        barcode,
        locale: 'zh-CN'
      });
      this.scanResult = draft;
      this.manualBarcode = draft.barcode;
      this.showScanResult = true;
      this.scannerStatus = '识别成功，可直接标记有无状态';
      promptAction.showToast({ message: successMessage });
    } catch (error) {
      const message = this.resolveErrorMessage(error as Object, '条码识别失败，请稍后再试');
      this.scannerStatus = message;
      promptAction.showToast({ message });
      if (this.shouldRedirectToLogin(error as Object)) {
        router.pushUrl({ url: RoutePaths.LOGIN });
      }
    } finally {
      this.requestBusy = false;
    }
  }

  private async handleDirectSave(item: MaterialDraft, hasItem: boolean): Promise<void> {
    if (this.requestBusy) {
      return;
    }

    if (!(await this.hasAuthorization())) {
      this.navigateToLogin('请先登录后再保存材料');
      return;
    }

    this.requestBusy = true;
    try {
      const nextDraft: MaterialDraft = {
        id: item.id,
        source: item.source,
        sourceLabel: item.sourceLabel,
        name: item.name,
        subtitle: hasItem ? '已识别成功，你当前标记为有。' : '当前只记录有无状态，你标记为暂时没有。',
        brand: item.brand,
        categoryId: item.categoryId,
        imageUrl: item.imageUrl,
        imageUrlThumb: item.imageUrlThumb,
        imageUrlCard: item.imageUrlCard,
        imageUrlDetail: item.imageUrlDetail,
        barcode: item.barcode,
        addedAt: item.addedAt,
        materialId: item.materialId,
        capacityText: item.capacityText,
        remainLevel: item.remainLevel,
        opened: item.opened,
        hasItem,
        tags: item.tags.slice(),
        note: item.note,
        badge: item.badge,
        accentColor: item.accentColor,
        softColor: item.softColor
      };
      const savedDraft = await stationMaterialRepository.saveScannedMaterial(nextDraft);
      this.scanResult = savedDraft;
      saveMaterialDraft(savedDraft);
      promptAction.showToast({ message: hasItem ? savedDraft.name + ' 已标记为我有' : savedDraft.name + ' 已标记为暂时没有' });
      router.back();
    } catch (error) {
      const message = this.resolveErrorMessage(error as Object, '保存材料失败，请稍后再试');
      promptAction.showToast({ message });
      if (this.shouldRedirectToLogin(error as Object)) {
        router.pushUrl({ url: RoutePaths.LOGIN });
      }
    } finally {
      this.requestBusy = false;
    }
  }

  private async mockRecognizeByManualCode(): Promise<void> {
    if (this.manualBarcode.length === 0) {
      promptAction.showToast({ message: '请先输入一个条码' });
      return;
    }
    await this.resetScannerSession();
    this.scannerStatus = '已收到手输条码，正在查询商品信息';
    await this.lookupBarcode(this.manualBarcode, '已获取条码识别结果');
  }

  @Builder
  private buildHeader() {
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

      Column({ space: 4 }) {
        Text('扫描酒瓶条码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text('扫描识别后直接标记我有或暂时没有，不再补库存细节。')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%');
  }

  @Builder
  private buildScannerCorner(position: Position) {
    Row() {
      Blank();
    }
    .width(28)
    .height(28)
    .border({ width: 3, color: UiTokens.accentWarm })
    .borderRadius(10)
    .position(position);
  }

  @Builder
  private buildScannerViewport() {
    Stack({ alignContent: Alignment.Center }) {
      XComponent({
        id: 'station-scanner-preview',
        type: XComponentType.SURFACE,
        controller: this.previewController
      })
        .width('100%')
        .height(this.previewHeightVp)
        .borderRadius(28)
        .backgroundColor(UiTokens.brandStrong)
        .onLoad(() => {
          void this.handlePreviewLoad();
        })
        .onDestroy(() => {
          void this.releaseScanner();
        });

      Column()
        .width('100%')
        .height(this.previewHeightVp)
        .borderRadius(28)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#08131B18', 0.0], ['#07141C08', 0.46], ['#02080D2E', 1.0]]
        });

      Column({ space: 14 }) {
        Row() {
          Text(this.getStatusChipText())
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(UiTokens.primarySoft)
            .borderRadius(14);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);

        Blank()
          .layoutWeight(1);

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(250)
            .height(150)
            .borderRadius(24)
            .border({ width: 2, color: UiTokens.borderWarm });

          Row()
            .width(206)
            .height(2)
            .backgroundColor(UiTokens.borderWarm)
            .opacity(0.9);

          this.buildScannerCorner({ x: 23, y: 23 });
          this.buildScannerCorner({ x: 199, y: 23 });
          this.buildScannerCorner({ x: 23, y: 99 });
          this.buildScannerCorner({ x: 199, y: 99 });

          if (!this.previewReady) {
            Column({ space: 10 }) {
              LoadingProgress()
                .width(24)
                .height(24)
                .color(UiTokens.accentWarm);

              Text('相机预览准备中')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(UiTokens.textInverse);
            }
          }
        }

        Column({ space: 6 }) {
          Text(this.getScannerHeadline())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textInverse);

          Text(this.getScannerSubline())
            .fontSize(12)
            .fontColor(UiTokens.textInverse)
            .opacity(0.86)
            .textAlign(TextAlign.Center)
            .lineHeight(18);

          Text(this.scannerStatus)
            .fontSize(12)
            .fontColor(UiTokens.textInverse)
            .opacity(0.94)
            .textAlign(TextAlign.Center)
            .lineHeight(18);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .height('100%')
      .padding(18);
    }
    .width('100%')
    .height(this.previewHeightVp)
    .backgroundColor(UiTokens.brandStrong)
    .borderRadius(28)
    .clip(true)
    .onClick(() => {
      void this.startScannerPreview();
    });
  }

  @Builder
  private buildActionChip(title: string, active: boolean, onTap: () => void) {
    Text(title)
      .fontSize(12)
      .fontWeight(active ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(active ? UiTokens.textPrimary : UiTokens.textSecondary)
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(active ? UiTokens.primarySoft : UiTokens.surfaceSecondary)
      .borderRadius(16)
      .onClick(() => {
        onTap();
      });
  }

  @Builder
  private buildControlPanel() {
    Column({ space: 16 }) {
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          this.buildActionChip(this.flashEnabled ? '关闭闪光灯' : '开启闪光灯', this.flashEnabled, () => {
            void this.toggleFlashLight();
          });
          this.buildActionChip(this.manualMode ? '手动条码输入中' : '手动输入条码', this.manualMode, () => {
            this.manualMode = !this.manualMode;
          });
        }
        .width('100%');

        if (this.manualMode) {
          Column({ space: 12 }) {
            TextInput({ placeholder: '输入条码，例如 5010327755017', text: this.manualBarcode })
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor(UiTokens.surfaceSecondary)
              .borderRadius(16)
              .fontSize(14)
              .placeholderColor(UiTokens.textTertiary)
              .onChange((value: string) => {
                this.manualBarcode = value;
              });

            Row({ space: 10 }) {
              Button(this.requestBusy ? '识别中...' : '识别输入条码', { type: ButtonType.Capsule })
                .layoutWeight(1)
                .height(46)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(UiTokens.textInverse)
                .backgroundColor(UiTokens.primary)
                .enabled(!this.requestBusy)
                .onClick(() => {
                  void this.mockRecognizeByManualCode();
                });

              Button('清空', { type: ButtonType.Capsule })
                .width(96)
                .height(46)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(UiTokens.textSecondary)
                .backgroundColor(UiTokens.surfaceMuted)
                .onClick(() => {
                  this.manualBarcode = '';
                });
            }
            .width('100%');
          }
          .width('100%');
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Row({ space: 10 }) {
        Button(this.getPrimaryScanButtonText(), { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.primary)
          .enabled(this.previewReady && !this.requestBusy && !this.cameraBusy)
          .onClick(() => {
            void this.startScannerPreview();
          });

        Button('改用列表勾选', { type: ButtonType.Capsule })
          .width(132)
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.textAccent)
          .backgroundColor(UiTokens.primarySoft)
          .enabled(!this.requestBusy)
          .onClick(() => {
            router.pushUrl({ url: RoutePaths.MATERIAL_LIBRARY }, 3000);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildResultCard(item: MaterialDraft) {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Row() {
          Text(item.badge)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accentColor);
        }
        .width(54)
        .height(54)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(item.softColor)
        .borderRadius(18);

        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text(item.brand + ' · ' + item.sourceLabel)
            .fontSize(12)
            .fontColor(UiTokens.textSecondary);

          Text('识别成功后只需要标记你现在是否持有。')
            .fontSize(12)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(18)
            .maxLines(2);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      Row({ space: 8 }) {
        Text('条码 ' + item.barcode)
          .fontSize(11)
          .fontColor(UiTokens.textAccent)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(UiTokens.primarySoft)
          .borderRadius(14);

        Text(item.hasItem ? '当前标记为有' : '当前标记为暂时没有')
          .fontSize(11)
          .fontColor(item.hasItem ? UiTokens.success : UiTokens.warning)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(item.hasItem ? UiTokens.successSoft : UiTokens.warningSoft)
          .borderRadius(14);
      }
      .width('100%');

      if (item.tags.length > 0) {
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start
        }) {
          ForEach(item.tags.slice(0, 4), (tag: string) => {
            Text(tag)
              .fontSize(11)
              .fontColor(item.accentColor)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(item.softColor)
              .borderRadius(14)
              .margin({ right: 8, bottom: 8 });
          });
        }
        .width('100%');
      }

      Row({ space: 10 }) {
        Button('标记为我有', { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.primary)
          .enabled(!this.requestBusy)
          .onClick(() => {
            void this.handleDirectSave(item, true);
          });

        Button('标记为暂时没有', { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiTokens.warning)
          .backgroundColor(UiTokens.warningSoft)
          .enabled(!this.requestBusy)
          .onClick(() => {
            void this.handleDirectSave(item, false);
          });
      }
      .width('100%');

      Button('查看材料大图', { type: ButtonType.Capsule })
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(item.accentColor)
        .backgroundColor(item.softColor)
        .enabled(!this.requestBusy)
        .onClick(() => {
          this.openMaterialPreview(item);
        });
    }
    .width('100%')
    .padding(18)
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll() {
        Column({ space: 18 }) {
          this.buildHeader();
          this.buildScannerViewport();
          this.buildControlPanel();
          if (this.showScanResult && this.scanResult !== undefined) {
            this.buildResultCard(this.scanResult);
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 40 });
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .backgroundColor(UiTokens.pageBackground)
      .scrollBar(BarState.Off);

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
    .backgroundColor(UiTokens.pageBackground);
  }
}

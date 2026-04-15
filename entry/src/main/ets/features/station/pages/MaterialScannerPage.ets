import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { getDraftById, MaterialDraft } from '../model/BartendingStationMockData';
import { directIntakeScannedMaterial } from '../model/MaterialStationStore';
@Entry
@Component
export struct MaterialScannerPage {
  @State private flashEnabled: boolean = false;
  @State private manualMode: boolean = false;
  @State private manualBarcode: string = '';
  @State private scanResultId: string = 'hendricks-gin';
  @State private showScanResult: boolean = false;
  @State private cameraBusy: boolean = false;

  private readonly cameraPermissionList: Permissions[] = ['ohos.permission.CAMERA'];
  private scanTimerId: number = -1;

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
        Text('扫描酒瓶条码')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('尽量一步完成：识别后可直接收录，补信息改成可选。')
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
  private buildScannerViewport() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height(320)
        .borderRadius(28)
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [['#173240', 0.0], ['#1B596E', 0.58], ['#245C82', 1.0]]
        });

      Column()
        .width(240)
        .height(240)
        .borderRadius(120)
        .backgroundColor('#FFFFFF')
        .opacity(0.06)
        .position({ x: -54, y: -70 });

      Column()
        .width(180)
        .height(180)
        .borderRadius(90)
        .backgroundColor('#DDF5F1')
        .opacity(0.12)
        .position({ x: 160, y: 150 });

      Column({ space: 16 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(250)
            .height(150)
            .borderRadius(24)
            .border({ width: 2, color: '#DDF5F1' })
            .backgroundColor('#FFFFFF12');

          Column()
            .width(206)
            .height(2)
            .backgroundColor('#F8E9CF')
            .opacity(0.86)
            .position({ x: 22, y: 72 });

          Row({ space: 16 }) {
            Column({ space: 10 }) {
              Row() {
                Blank();
              }
              .width(18)
              .height(80)
              .backgroundColor('#F8E9CF')
              .borderRadius(10);

              Row() {
                Blank();
              }
              .width(10)
              .height(110)
              .backgroundColor('#FFFFFF')
              .opacity(0.9)
              .borderRadius(8);
            }

            Column({ space: 10 }) {
              Row() {
                Blank();
              }
              .width(12)
              .height(96)
              .backgroundColor('#DDF5F1')
              .borderRadius(8);

              Row() {
                Blank();
              }
              .width(20)
              .height(72)
              .backgroundColor('#FFFFFF')
              .opacity(0.86)
              .borderRadius(10);
            }

            Column({ space: 10 }) {
              Row() {
                Blank();
              }
              .width(16)
              .height(118)
              .backgroundColor('#FFFFFF')
              .opacity(0.92)
              .borderRadius(10);

              Row() {
                Blank();
              }
              .width(12)
              .height(56)
              .backgroundColor('#F8E9CF')
              .borderRadius(8);
            }

            Column({ space: 10 }) {
              Row() {
                Blank();
              }
              .width(22)
              .height(86)
              .backgroundColor('#DDF5F1')
              .borderRadius(10);

              Row() {
                Blank();
              }
              .width(10)
              .height(104)
              .backgroundColor('#FFFFFF')
              .opacity(0.86)
              .borderRadius(8);
            }
          }
        }

        Column({ space: 6 }) {
          Text(this.cameraBusy ? '正在框内识别条码' : '将酒瓶条码放入框内')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF');

          Text(this.cameraBusy ? '请将条码保持在黄色框内，系统会自动识别。' : '识别成功后可以直接收录到材料台，也可以稍后再补信息。')
            .fontSize(12)
            .fontColor('#D7E6ED')
            .textAlign(TextAlign.Center)
            .lineHeight(18);
        }
      }
    }
    .width('100%')
    .onClick(() => {
      void this.openCameraForScan();
    });
  }

  @Builder
  private buildActionChip(title: string, active: boolean, onTap: () => void) {
    Text(title)
      .fontSize(12)
      .fontWeight(active ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(active ? '#173240' : '#6E818D')
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor(active ? '#DDF5F1' : '#F4F8FB')
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
          this.buildActionChip(this.flashEnabled ? '闪光灯已开' : '开启闪光灯', this.flashEnabled, () => {
            this.flashEnabled = !this.flashEnabled;
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
              .backgroundColor('#F4F8FB')
              .borderRadius(16)
              .fontSize(14)
              .placeholderColor('#91A4AE')
              .onChange((value: string) => {
                this.manualBarcode = value;
              });

            Row({ space: 10 }) {
              Button('根据条码模拟识别', { type: ButtonType.Capsule })
                .layoutWeight(1)
                .height(46)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .backgroundColor('#1B596E')
                .onClick(() => {
                  this.mockRecognizeByManualCode();
                });

              Button('清空', { type: ButtonType.Capsule })
                .width(96)
                .height(46)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#5A7180')
                .backgroundColor('#EEF5F8')
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
        Button(this.cameraBusy ? '正在框内扫描' : '开始框内扫描', { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#1B596E')
          .enabled(!this.cameraBusy)
          .onClick(() => {
            void this.openCameraForScan();
          });

        Button('直接手动添加', { type: ButtonType.Capsule })
          .width(132)
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#245C82')
          .backgroundColor('#E8F5FB')
          .onClick(() => {
            router.pushUrl({
              url: 'features/station/pages/MaterialEditorPage',
              params: {
                materialId: 'hendricks-gin'
              }
            }, 3000);
          });
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
            .fontColor('#173240');

          Text(item.brand + ' · ' + item.sourceLabel)
            .fontSize(12)
            .fontColor('#72838F');

          Text(item.subtitle)
            .fontSize(12)
            .fontColor('#72838F')
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
          .fontColor('#245C82')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#E8F5FB')
          .borderRadius(14);

        Text('类别已匹配')
          .fontSize(11)
          .fontColor('#2B6C63')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EEF6F2')
          .borderRadius(14);
      }
      .width('100%');

      Row({ space: 10 }) {
        Button('直接收录', { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(item.accentColor)
          .onClick(() => {
            directIntakeScannedMaterial(item.id);
            promptAction.showToast({ message: item.name + ' 已直接收录' });
            router.back();
          });

        Button('补信息', { type: ButtonType.Capsule })
          .width(112)
          .height(50)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.accentColor)
          .backgroundColor(item.softColor)
          .onClick(() => {
            router.pushUrl({
              url: 'features/station/pages/MaterialEditorPage',
              params: {
                materialId: item.id,
                source: 'scan'
              }
            }, 3000);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  private getHostContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private async ensureCameraPermission(): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let result = await atManager.requestPermissionsFromUser(this.getHostContext(), this.cameraPermissionList);
      if (result.authResults.length === 0) {
        return false;
      }
      return result.authResults[0] === 0;
    } catch (error) {
      promptAction.showToast({ message: '相机权限申请失败' });
      return false;
    }
  }

  aboutToDisappear(): void {
    if (this.scanTimerId !== -1) {
      clearTimeout(this.scanTimerId);
      this.scanTimerId = -1;
    }
  }

  private finishInlineScan(): void {
    this.scanResultId = 'hendricks-gin';
    this.showScanResult = true;
    this.cameraBusy = false;
    this.scanTimerId = -1;
    promptAction.showToast({ message: '已在扫描框内识别到 1 个结果' });
  }

  private async openCameraForScan(): Promise<void> {
    if (this.cameraBusy) {
      return;
    }

    try {
      let granted = await this.ensureCameraPermission();
      if (!granted) {
        promptAction.showToast({ message: '未获得相机权限，无法开始扫码' });
        return;
      }

      this.showScanResult = false;
      this.cameraBusy = true;
      promptAction.showToast({ message: '请将条码对准黄色扫描框' });

      if (this.scanTimerId !== -1) {
        clearTimeout(this.scanTimerId);
      }

      this.scanTimerId = setTimeout((): void => {
        this.finishInlineScan();
      }, 1200);
    } catch (error) {
      this.cameraBusy = false;
      promptAction.showToast({ message: '启动扫码失败，请稍后重试' });
    }
  }

  private mockRecognizeByManualCode(): void {
    if (this.manualBarcode.length === 0) {
      promptAction.showToast({ message: '请先输入一个条码' });
      return;
    }

    if (this.manualBarcode.indexOf('8000') === 0) {
      this.scanResultId = 'campari';
    } else if (this.manualBarcode.indexOf('7610') === 0) {
      this.scanResultId = 'bacardi-rum';
    } else {
      this.scanResultId = 'hendricks-gin';
    }
    this.showScanResult = true;
    promptAction.showToast({ message: '已生成模拟识别结果' });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildScannerViewport();
        this.buildControlPanel();
        if (this.showScanResult) {
          this.buildResultCard(getDraftById(this.scanResultId));
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

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import {
  MATERIAL_LIST_CATEGORIES,
  MaterialListCategory,
  MaterialRecord
} from '../../station/model/BartendingStationMockData';
import { getRecordedMaterials, setRecordedMaterialDrafts } from '../../station/model/MaterialStationStore';
import { stationMaterialRepository } from '../../station/repository/StationMaterialRepository';
import { sessionStore } from '../../../common/storage/SessionStore';

@Component
export struct BartendingStationPage {
  @State private activeMaterialCategoryId: string = 'all';
  @State private recordedMaterials: MaterialRecord[] = [];
  @State private loading: boolean = false;

  aboutToAppear(): void {
    void this.refreshRecordedMaterials();
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
    } catch (error) {
      const errorObject = error as Record<string, Object>;
      const message = errorObject['message'];
      if (typeof message === 'string' && message.trim().length > 0) {
        promptAction.showToast({ message });
      }
    } finally {
      this.loading = false;
    }
    this.recordedMaterials = getRecordedMaterials();
  }

  @Builder
  private buildHeader() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Text('ShakePro Station')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5D7B8C')
          .letterSpacing(1.1);

        Text('库存管理')
          .fontSize(11)
          .fontColor('#245C82')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#E8F5FB')
          .borderRadius(14);
      }

      Text('我的材料台')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#16303E');

      Text('专注查看、筛选和更新库存，录入入口缩成一排工具操作。')
        .fontSize(13)
        .fontColor('#6E818D')
        .lineHeight(20);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildOverviewMetric(value: string, label: string, accentColor: string, softColor: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text(label)
        .fontSize(12)
        .fontColor('#6E818D');

      Row()
        .width(28)
        .height(4)
        .borderRadius(2)
        .backgroundColor(accentColor)
        .opacity(0.75);
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(softColor)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildOverviewCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('库存概况')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240');

          Text('先看状态，再决定是补录还是调整现有材料。')
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(18);
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Text(this.recordedMaterials.length.toString() + ' 项')
          .fontSize(12)
          .fontColor('#72838F');
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      Row({ space: 10 }) {
        this.buildOverviewMetric(
          this.recordedMaterials.length.toString(),
          '已收录材料',
          '#1B596E',
          '#DDF5F1'
        );
        this.buildOverviewMetric(
          this.getPendingCompletionCount().toString(),
          '待补全',
          '#A66A1C',
          '#F8E9CF'
        );
        this.buildOverviewMetric(
          this.getReadyCount().toString(),
          '可直接使用',
          '#245C82',
          '#E8F5FB'
        );
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildCompactAction(title: string, detail: string, accentColor: string, softColor: string, route: string) {
    Row({ space: 10 }) {
      Row() {
        Text(title.substring(0, 1))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(accentColor);
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(softColor)
      .borderRadius(14);

      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text(detail)
          .fontSize(11)
          .fontColor('#72838F')
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      router.pushUrl({ url: route }, 3000);
    });
  }

  @Builder
  private buildQuickActions() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        this.buildCompactAction(
          '扫码录入',
          '适合酒瓶包装材料',
          '#1B596E',
          '#DDF5F1',
          'features/station/pages/MaterialScannerPage'
        );
        this.buildCompactAction(
          '手动添加',
          '适合水果和杯具',
          '#245C82',
          '#E8F5FB',
          'features/station/pages/MaterialLibraryPage'
        );
      }
      .width('100%');

      Row({ space: 10 }) {
        Text('需要灵感时再去生成配方，不打断库存管理主流程。')
          .layoutWeight(1)
          .fontSize(12)
          .fontColor('#72838F')
          .lineHeight(18);

        Button('去配方', { type: ButtonType.Capsule })
          .height(38)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1B596E')
          .backgroundColor('#DDF5F1')
          .onClick(() => {
            router.pushUrl({ url: 'features/cocktail/pages/AICocktailPage' }, 3000);
          });
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .border({ width: 1, color: '#D7E6ED' });
    }
    .width('100%');
  }

  private getPendingCompletionCount(): number {
    return this.recordedMaterials.filter((item: MaterialRecord): boolean => item.needsCompletion).length;
  }

  private getReadyCount(): number {
    return this.recordedMaterials.filter((item: MaterialRecord): boolean => !item.needsCompletion).length;
  }

  @Builder
  private buildSectionHeader() {
    Row() {
      Column({ space: 4 }) {
        Text('库存列表')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240');

        Text('点开卡片即可快速修改库存或补全信息。')
          .fontSize(12)
          .fontColor('#738590');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Button('刷新', { type: ButtonType.Capsule })
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#245C82')
        .backgroundColor('#E8F5FB')
        .enabled(!this.loading)
        .onClick(() => {
          void this.refreshRecordedMaterials();
        });
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
        this.buildOverviewCard();
        this.buildQuickActions();
        this.buildSectionHeader();
        this.buildCategoryTabs();

        Column({ space: 12 }) {
          if (this.loading) {
            Column({ space: 8 }) {
              Text('正在加载材料台')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#173240');

              Text('稍等一下，正在同步你的材料列表。')
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
          ForEach(this.getDisplayedMaterials(), (item: MaterialRecord) => {
            this.buildMaterialCard(item);
          });
          if (!this.loading && this.getDisplayedMaterials().length === 0) {
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

import promptAction from '@ohos.promptAction';
import ItemData from '../model/ItemData';
import MainViewModel from '../viewmodel/MainViewModel';
import { router } from '@kit.ArkUI';

interface DashboardStat {
  value: string;
  label: string;
}

@Entry({ routeName: 'MainPage' })
@Component
export struct MainPage {
  private swiperController: SwiperController = new SwiperController();

  private readonly stats: DashboardStat[] = [
    { value: '12', label: '今日建议' },
    { value: '84%', label: '库存匹配' },
    { value: '3.2m', label: '平均出杯' }
  ];

  @Builder
  private buildHeader() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 6 }) {
          Text('ShakePro Control')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5D7B8C')
            .letterSpacing(1.1);

          Text('智能调酒工作台')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#16303E');

          Text('集中查看推荐、库存和功能入口。')
            .fontSize(13)
            .fontColor('#6E818D');
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Row() {
          Image($r('app.media.myself'))
            .width(48)
            .height(48)
            .borderRadius(24);
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .border({ width: 1, color: '#D7E6ED' });
      }
      .width('100%');

      Row({ space: 10 }) {
        Row({ space: 10 }) {
          Text('◌')
            .fontSize(18)
            .fontColor('#6A8EA0');

          TextInput({ placeholder: $r('app.string.search_interesting_content') })
            .layoutWeight(1)
            .height(48)
            .backgroundColor(Color.Transparent)
            .fontSize(15)
            .placeholderColor('#8BA0AC');
        }
        .layoutWeight(1)
        .height(54)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });

        Column({ space: 2 }) {
          Text('AI')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#124056');
        }
        .width(58)
        .height(54)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#DDF5F1')
        .borderRadius(18)
        .border({ width: 1, color: '#BFE7E6' });
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildHeroSection() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Swiper(this.swiperController) {
        ForEach(MainViewModel.getSwiperImages(), (img: Resource, index: number) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(img)
              .width('100%')
              .height(228)
              .borderRadius(24)
              .objectFit(ImageFit.Cover);

            Column()
              .width('100%')
              .height('100%')
              .borderRadius(24)
              .linearGradient({
                direction: GradientDirection.Top,
                repeating: false,
                colors: [['#1D4A5A12', 0.0], ['#1D4A5A55', 0.58], ['#123241D0', 1.0]]
              });

            // Column({ space: 10 }) {
            //   Text(index === 0 ? '今日推荐酒单' : '精选灵感库')
            //     .fontSize(14)
            //     .fontWeight(FontWeight.Medium)
            //     .fontColor('#D7EEF6');
            //
            //   Text(index === 0 ? '根据库存与偏好自动生成推荐方案' : '从经典到新配方，快速定位当前需求')
            //     .fontSize(24)
            //     .fontWeight(FontWeight.Bold)
            //     .fontColor('#FFFFFF')
            //     .lineHeight(30);
            //
            //   Text('支持 AI 建议、原料筛选和功能模块联动。')
            //     .fontSize(12)
            //     .fontColor('#D8EBF2');
            // }
            // .width('100%')
            // .alignItems(HorizontalAlign.Start)
            // .padding(20);
          }
        });
      }
      .autoPlay(true)
      .indicator(true)
      .interval(3600)
      .width('100%')
      .height(228);
    }
    .width('100%');
  }

  @Builder
  private buildStatsPanel() {
    Row({ space: 10 }) {
      ForEach(this.stats, (item: DashboardStat) => {
        Column({ space: 8 }) {
          Text(item.value)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#153342');

          Text(item.label)
            .fontSize(12)
            .fontColor('#71838F')
            .textAlign(TextAlign.Center);
        }
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .border({ width: 1, color: '#D7E6ED' });
      });
    }
    .width('100%');
  }

  @Builder
  private buildSectionHeader(title: string, subtitle: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#16303E');

        Text(subtitle)
          .fontSize(12)
          .fontColor('#738590');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Text('更多')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C8192');
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom);
  }

  @Builder
  private buildQuickActionCard(item: ItemData, index: number) {
    Row({ space: 12 }) {
      Row() {
        if (item.img) {
          Image(item.img)
            .width(34)
            .height(34)
            .objectFit(ImageFit.Contain);
        }
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(index % 2 === 0 ? '#E8F5FB' : '#DDF5F1')
      .borderRadius(18);

      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#193342')
          .maxLines(2);

        Text(this.getMenuDescription(item.title))
          .fontSize(9)
          .fontColor('#72838F')
          .lineHeight(17)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({ width: 1, color: '#D7E6ED' })
    .onClick(() => {
      this.navigateToPage(item.title);
    });
  }

  @Builder
  private buildQuickActions() {
    Column({ space: 12 }) {
      this.buildSectionHeader('功能模块', '按用途分组显示')

      Grid() {
        ForEach(MainViewModel.getFirstGirdData(), (item: ItemData, index: number) => {
          GridItem() {
            this.buildQuickActionCard(item, index);
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildRecipeCard(item: ItemData, index: number) {
    Row({ space: 14 }) {
      if (item.img) {
        Image(item.img)
          .width(100)
          .height(120)
          .borderRadius(20)
          .objectFit(ImageFit.Cover);
      }

      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#173240')
          .maxLines(2);

        if (item.others) {
          Text(item.others)
            .fontSize(12)
            .fontColor('#5C8797');
        }

        Text(index === 0 ? '结构清晰，适合标准化复刻。' : index === 1 ? '层次更强，适合聚会与展示。' : '风味轻盈，适合快速上手。')
          .fontSize(12)
          .fontColor('#71828D')
          .lineHeight(18)
          .maxLines(3);

        Row({ space: 8 }) {
          Text(index === 0 ? '经典' : index === 1 ? '推荐' : '轻饮')
            .fontSize(11)
            .fontColor('#1D5667')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#E8F5FB')
            .borderRadius(14);

          Text('查看酒谱')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4F7E91');
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#D7E6ED' });
  }

  @Builder
  private buildFeaturedRecipes() {
    Column({ space: 12 }) {
      this.buildSectionHeader('推荐配方', '结合当前素材和常用主题')

      Column({ space: 12 }) {
        ForEach(MainViewModel.getSecondGridData(), (item: ItemData, index: number) => {
          this.buildRecipeCard(item, index);
        });
      }
      .width('100%');
    }
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.buildHeader();
        this.buildHeroSection();
        this.buildStatsPanel();
        this.buildQuickActions();
        this.buildFeaturedRecipes();
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 110 });
    }
    .height('100%')
    .backgroundColor('#F4F8FB')
    .scrollBar(BarState.Off);
  }

  private getMenuDescription(title: Resource): string {
    if (title.id === $r('app.string.my_cocktail').id) {
      return '查看已保存的配方与出杯记录';
    }
    if (title.id === $r('app.string.material_selection').id) {
      return '根据原料快速定位可执行方案';
    }
    if (title.id === $r('app.string.favorite_recipes').id) {
      return '集中管理高频使用的收藏酒谱';
    }
    if (title.id === $r('app.string.classic_formula').id) {
      return '按标准结构浏览经典配方';
    }
    if (title.id === $r('app.string.friend').id) {
      return '用于分享作品和查看协作内容';
    }
    return '后续用于扩展更多历史与实验模块';
  }

  private navigateToPage(title: Resource): void {
    let targetUrl: string = '';

    if (title.id === $r('app.string.my_cocktail').id) {
      targetUrl = 'features/cocktail/pages/MyCocktailPage';
    } else if (title.id === $r('app.string.material_selection').id) {
      targetUrl = 'features/cocktail/pages/CocktailPhotoPage';
    }

    if (!targetUrl) {
      promptAction.showToast({ message: '该功能页面暂未开放' });
      return;
    }

    router.pushUrl({ url: targetUrl }, 3000);
  }
}

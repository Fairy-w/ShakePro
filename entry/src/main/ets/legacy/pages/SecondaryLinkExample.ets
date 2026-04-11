import { COMPONENT_STYLE, CustomDataType, ListIndexPosition, MyDataSource } from './DataTypeDemo';

interface TagListItem {
  name: Resource;
  img: Resource;
}

interface RightContentItem {
  image: Resource;
  title: Resource;
}

@Component
export struct SecondaryLinkExample {
  @State @Watch('onIndexChange') currentTagIndex: number = 0;
  private tagLists: TagListItem[] = [];
  private rightContentItems: RightContentItem[] = [];
  @State contentData: MyDataSource = new MyDataSource();
  private records: Array<number> = [];
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();
  private tagIndexPosition: ListIndexPosition = { start: 0, end: 0 };
  private isClickTagList: boolean = false;

  private createRightContentItems(): RightContentItem[] {
    return [
      { image: $r('app.media.list_1'), title: $r('app.string.Christmas_Solero') },
      { image: $r('app.media.list_2'), title: $r('app.string.Blue_Coral_Sea') },
      { image: $r('app.media.list_3'), title: $r('app.string.Eye_Opener') },
      { image: $r('app.media.list_4'), title: $r('app.string.Hot_Girl') },
      { image: $r('app.media.list_5'), title: $r('app.string.Rum_Colins') },
      { image: $r('app.media.list_6'), title: $r('app.string.Dash_of_Danger_Daiquiri') },
      { image: $r('app.media.list_7'), title: $r('app.string.Florida_Negroni') }
    ];
  }

  aboutToAppear(): void {
    this.contentData = new MyDataSource();
    this.records = [];
    this.tagLists = [
      { name: $r('app.string.Gin_desc'), img: $r('app.media.cocktail_1') },
      { name: $r('app.string.Liqueur_desc'), img: $r('app.media.cocktail_2') },
      { name: $r('app.string.Tequila_desc'), img: $r('app.media.cocktail_3') },
      { name: $r('app.string.Whiskey_desc'), img: $r('app.media.cocktail_4') },
      { name: $r('app.string.Vodka_desc'), img: $r('app.media.cocktail_5') },
      { name: $r('app.string.Brandy_desc'), img: $r('app.media.cocktail_6') },
      { name: $r('app.string.SoftDrink_desc'), img: $r('app.media.cocktail_7') },
      { name: $r('app.string.Beer_desc'), img: $r('app.media.cocktail_8') }
    ];
    this.rightContentItems = this.createRightContentItems();

    this.tagLists.forEach((tagItem: TagListItem) => {
      this.records.push(this.contentData.length);
      this.rightContentItems.forEach((contentItem: RightContentItem) => {
        this.contentData.pushData({
          desc: contentItem.title,
          tag: tagItem.name,
          image: contentItem.image
        });
      });
    });
  }

  @Builder
  private buildHeader() {
    Column({ space: 12 }) {
      Text('灵感检索')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#173240');

      Text('按基酒筛选推荐酒谱，右侧列表实时联动。')
        .fontSize(13)
        .fontColor('#72838F');

      Row({ space: 10 }) {
        Text('◌')
          .fontSize(18)
          .fontColor('#6A8EA0');

        TextInput({ placeholder: $r('app.string.search_cocktail_content') })
          .layoutWeight(1)
          .height(48)
          .backgroundColor(Color.Transparent)
          .fontSize(15)
          .placeholderColor('#8EA1AC');
      }
      .width('100%')
      .height(54)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .border({ width: 1, color: '#D7E6ED' });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  contentListNoMoreBuilder() {
    ListItem() {
      Text('已加载全部内容')
        .fontSize(12)
        .fontColor('#7A8A95')
        .margin({ top: 12, bottom: 18 });
    }
    .width('100%');
  }

  @Builder
  contentListItemBuilder(item: CustomDataType, index: number) {
    ListItem() {
      Row({ space: 12 }) {
        Image(item.image)
          .width(92)
          .height(112)
          .borderRadius(18)
          .objectFit(ImageFit.Cover);

        Column({ space: 8 }) {
          Text(item.tag)
            .fontSize(11)
            .fontColor('#2A6579')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#E8F5FB')
            .borderRadius(14);

          Text(item.desc)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#173240')
            .maxLines(2);

          Text(index % 2 === 0 ? '适合清爽、轻酒体方向。' : '适合层次更明显的社交场景。')
            .fontSize(12)
            .fontColor('#72838F')
            .lineHeight(18)
            .maxLines(2);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(22)
      .border({ width: 1, color: '#D7E6ED' });
    }
  }

  @Builder
  tagListItemBuilder(item: TagListItem, index: number) {
    ListItem() {
      Column({ space: 8 }) {
        Image(item.img)
          .width(60)
          .height(60)
          .borderRadius(16)
          .objectFit(ImageFit.Cover);

        Text(item.name)
          .fontSize(12)
          .fontWeight(this.currentTagIndex === index ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.currentTagIndex === index ? '#173240' : '#748591')
          .textAlign(TextAlign.Center)
          .maxLines(2);
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 8, right: 8 })
      .backgroundColor(this.currentTagIndex === index ? '#DDF5F1' : '#FFFFFF')
      .borderRadius(18)
      .border({ width: 1, color: this.currentTagIndex === index ? '#BFE7E6' : '#D7E6ED' })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isClickTagList = true;
        }
      })
      .onClick(() => {
        this.currentTagIndex = index;
        this.scroller.scrollToIndex(this.findItemIndex(index), true);
      });
    }
    .margin({ bottom: 10 });
  }

  build() {
    Column({ space: 16 }) {
      this.buildHeader();

      Row({ space: 14 }) {
        List({ scroller: this.classifyScroller, initialIndex: 0 }) {
          ForEach(this.tagLists, (item: TagListItem, index: number) => {
            this.tagListItemBuilder(item, index);
          });
        }
        .onScrollIndex((start: number, end: number) => {
          this.tagIndexPosition = { start, end };
        })
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .width(102)
        .height('100%');

        List({ scroller: this.scroller, space: COMPONENT_STYLE.ITEM_GUTTER }) {
          LazyForEach(this.contentData, (item: CustomDataType, index: number) => {
            this.contentListItemBuilder(item, index);
          });
          this.contentListNoMoreBuilder();
        }
        .scrollBar(BarState.Off)
        .listDirection(Axis.Vertical)
        .layoutWeight(1)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isClickTagList = false;
          }
        })
        .onScrollIndex((start: number) => {
          const currentClassIndex = this.findClassIndex(start);
          if (currentClassIndex !== this.currentTagIndex && !this.isClickTagList) {
            this.currentTagIndex = currentClassIndex;
            this.classifyScroller.scrollToIndex(currentClassIndex, true);
          }
        });
      }
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 110 })
    .backgroundColor('#F4F8FB');
  }

  findItemIndex(index: number): number {
    return this.records[index];
  }

  findClassIndex(index: number): number {
    for (let i = 0; i < this.records.length; i++) {
      const next = i + 1 < this.records.length ? this.records[i + 1] : this.contentData.length;
      if (index >= this.records[i] && index < next) {
        return i;
      }
    }
    return this.tagLists.length - 1;
  }

  onIndexChange() {
    const start = this.tagIndexPosition.start;
    const end = this.tagIndexPosition.end;
    if (this.currentTagIndex >= end - 1) {
      const nextIndex = this.currentTagIndex + 1 >= this.tagLists.length ? this.tagLists.length - 1 : this.currentTagIndex + 1;
      this.classifyScroller.scrollToIndex(nextIndex, true);
    }
    if (this.currentTagIndex <= start + 1) {
      const previousIndex = this.currentTagIndex - 1 <= 0 ? 0 : this.currentTagIndex - 1;
      this.classifyScroller.scrollToIndex(previousIndex, true);
    }
  }
}

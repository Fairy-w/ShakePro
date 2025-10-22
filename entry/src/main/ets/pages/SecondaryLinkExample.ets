
import { COMPONENT_STYLE, CustomDataType, ListIndexPosition, MyDataSource } from './DataType';

// import { FunctionDescription } from '../utils/FunctionDescription';
// import { CustomDataType, MyDataSource, ListIndexPosition, COMPONENT_STYLE } from './DataType';

const TAG_LIST_LENGTH = 12; // TagList长度
const CONTENT_PER_TAG = 6; // 每个TAG对应多少个元素

/**
 * 功能描述: 本示例主要介绍了List组件实现二级联动（Cascading List）的场景
 *
 * 推荐场景: 需要使用多级列表联合滚动的场景，如：外卖点单页面等
 *
 * 核心组件:
 * 1. SecondaryLinkExample.tagListItemBuilder
 *
 * 实现步骤:
 * 1. 一二级列表分别绑定不同的Scroller对象，一级列表(tagLists)绑定classifyScroller对象，二级列表绑定scroller对象
 * 2. 点击一级列表后，通过一级列表的索引获取二级列表的索引，调用scrollToIndex方法将一二级列表滚动到指定索引值
 * 3. 滑动二级列表触发组件滚动事件后，获取到列表可视区域第一个item对应的索引值，通过二级列表索引获取一级列表索引，调用scrollToIndex方法将一级列表滚动到指定索引值
 */

interface TagListItem {
  name: Resource ;
  img: Resource;
}

interface RightContentItem {

  image: Resource; // 图片资源
  title: Resource;   // 标题文本

}



@Component
export struct SecondaryLinkExample {


  @State @Watch('onIndexChange') currentTagIndex: number = 0; // 一级列表焦点索引值
  private tagLists: TagListItem[] = []; // 修改这里，使其能够存储TagListItem对象
  private rightContentItems: RightContentItem[] = []; // 独立的右侧内容数据源
  @State contentData: MyDataSource = new MyDataSource(); // 二级列表数据
  private records: Array<number> = []; // 二级列表分组count数量
  // TODO:知识点: 1.级联列表分别绑定不同的Scroller对象，通过调用Scroller对象方法实现控制列表滚动
  private classifyScroller: Scroller = new Scroller(); // 一级列表Scroller对象
  private scroller: Scroller = new Scroller(); // 二级列表Scroller对象
  private tagIndexPosition: ListIndexPosition = { start: 0, end: 0 }; // 一级列表可视区域的起始索引和终点索引
  private isClickTagList: boolean = false; // 是否点击一级列表

  private createRightContentItems(): RightContentItem[] {
    const rightContentItems: RightContentItem[] = [
    // 初始化右侧内容项，例如：
      { image: $r('app.media.list_1'), title: $r('app.string.Christmas_Solero')},
      { image: $r('app.media.list_2'), title: $r('app.string.Blue_Coral_Sea')},
      { image: $r('app.media.list_3'), title: $r('app.string.Eye_Opener')},
      { image: $r('app.media.list_4'), title: $r('app.string.Hot_Girl')},
      { image: $r('app.media.list_5'), title: $r('app.string.Rum_Colins')},
      { image: $r('app.media.list_6'), title: $r('app.string.Dash_of_Danger_Daiquiri')},
      { image: $r('app.media.list_7'), title: $r('app.string.Florida_Negroni')},



    // ... 更多右侧内容项
    ];
    return rightContentItems;
  }


   // * 生命周期函数
  aboutToAppear(): void {
    const tagListItems: TagListItem[] = [
      { name: $r('app.string.Gin_desc'), img: $r('app.media.cocktail_1') },
      { name: $r('app.string.Liqueur_desc'), img: $r('app.media.cocktail_2') },
      { name: $r('app.string.Tequila_desc'), img: $r('app.media.cocktail_3') },
      { name: $r('app.string.Whiskey_desc'), img: $r('app.media.cocktail_4') },
      { name: $r('app.string.Vodka_desc'), img: $r('app.media.cocktail_5') },
      { name: $r('app.string.Brandy_desc'), img: $r('app.media.cocktail_6') },
      { name: $r('app.string.SoftDrink_desc'), img: $r('app.media.cocktail_7') },
      { name: $r('app.string.Beer_desc'), img: $r('app.media.cocktail_8') },

    ]


    this.tagLists = tagListItems;
    this.rightContentItems = this.createRightContentItems(); //右侧部分初始化

    // 假设每个类别下有相同数量的子项
    const subItemsPerTag = 6;
    for (let i = 0; i < tagListItems.length; i++) {
      const startIndex = i * subItemsPerTag;
      const endIndex = Math.min(startIndex + subItemsPerTag, this.rightContentItems.length);
      for (let j = startIndex; j < endIndex; j++) {
        this.contentData.pushData({
          desc: this.rightContentItems[j].title,
          tag: tagListItems[i].name,
          image: this.rightContentItems[j].image
        });
      }
      this.records.push(this.contentData.length - 1); // 记录每个一级标签对应的二级列表项的结束索引
    }
  }

  build() {
    Column() {
      Row(){
        Image($r('app.media.icon_cocktail'))
          .width(38)
          .height(38)
        TextInput({placeholder:$r('app.string.search_cocktail_content')})
          .width('90%')
          .height(40)
          .margin({top:10})

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({bottom:10})

      Row() {
        // TODO:知识点: 2.一级列表绑定Scroller对象
        List({ scroller: this.classifyScroller, initialIndex: 0 }) {
          // 性能知识点：此处为横向列表，列表项确定且数量较少，使用了ForEach，在列表项多的情况下，推荐使用LazyForeEach
          ForEach(this.tagLists, (item: TagListItem, index: number) => {
            this.tagListItemBuilder(item, index); // 确保tagListItemBuilder接受TagListItem类型
          })
        }
        .onScrollIndex((start: number, end: number) => {
          this.tagIndexPosition = { start, end };
        })
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .height('100%')
        .width('27%')

        // 二级列表
        List({ scroller: this.scroller, space: COMPONENT_STYLE.ITEM_GUTTER }) {
          /*
            性能知识点：列表中数据较多且不确定的情况下，使用LazyForEach进行数据循环渲染。
            当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用。
            文档参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-rendering-control-lazyforeach-0000001820879609
           */
          LazyForEach(this.contentData, (item: CustomDataType, index: number) => {
            this.contentListItemBuilder(item, index);
          })

          this.contentListNoMoreBuilder();
        }
        .scrollBar(BarState.Off)
        .listDirection(Axis.Vertical) // 列表排列方向水平
        .flexShrink(1)
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.ohos_id_color_list_separator'),
          startMargin: $r('sys.float.ohos_id_card_margin_start'),
          endMargin: $r('sys.float.ohos_id_card_margin_end')
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isClickTagList = false; // 当前点击的非一级列表
          }
        })
        // 性能知识点:onScrollIndex事件在列表滚动时频繁执行，在回调中需要尽量减少耗时和冗余操作，例如减少不必要的日志打印
        .onScrollIndex((start: number) => {
          // TODO:知识点: 4.滑动二级列表触发组件滚动事件后，返回列表可视区域的第一个item对应的索引值，当前通过二级列表索引获取一级列表索引，操作一级列表Scroller对象使列表滚动到指定位置
          const currentClassIndex = this.findClassIndex(start);
          if (currentClassIndex !== this.currentTagIndex && this.isClickTagList !== true) {
            this.currentTagIndex = currentClassIndex;
            this.classifyScroller.scrollToIndex(currentClassIndex, true);
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .padding({left:12,right:12})
  }

  /**
   * 内容底部"没有更多"视图
   */
  @Builder
  contentListNoMoreBuilder() {
    ListItem() {
      Text($r('app.string.secondarylinkage_nomore'))
        .fontColor($r('sys.color.ohos_fa_text_secondary'))
    }
    .width('100%')
  }

  /**
   * 右侧内容视图
   */
  @Builder
  contentListItemBuilder(item: CustomDataType, index: number) {
    ListItem() {
      Column({ space: COMPONENT_STYLE.ITEM_GUTTER }) {
        // 展示右侧内容的图片和标题
        Image(this.rightContentItems[index].image)
          .width('100%') // 图片宽度设置为100%
          .height(250) // 根据需要调整图片高度
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))

        // 展示右侧内容的标题
        Text(this.rightContentItems[index].title)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)
          .fontColor('#DE7623')

        // 如果需要展示副标题，可以在这里添加
        // Text(this.rightContentItems[index].subtitle)
        //   .fontSize($r('sys.float.ohos_id_text_size_body3'))
        //   .fontColor($r('app.color.secondarylinkage_contentTextFontColor'))
        //   .textAlign(TextAlign.Center)
      }
      .backgroundColor('#F1F3F5')
      .height('41%')
      .padding({
        left: $r('sys.float.ohos_id_card_margin_start'),
        right: $r('sys.float.ohos_id_card_margin_end'),
      })
    }
  }
  /**
   * 左侧类别视图
   */
  @Builder
  tagListItemBuilder(item: TagListItem, index: number) { // 修改参数类型为TagListItem
    ListItem() {
      Column({ space: COMPONENT_STYLE.ITEM_GUTTER }) {
        Image(item.img) // 直接使用item.image
          .width('250px') // 根据需要调整宽度
          .height('250px') // 根据需要调整高度
          .borderRadius(38)
          .aspectRatio(1) // 根据图片的实际宽高比调整

          // .crop(CropType.TOP) // 裁剪图片，只保留顶部部分

        Text(item.name) // 使用item.name
          .fontWeight(FontWeight.Regular)
          .fontColor(this.currentTagIndex === index ? Color.Orange :
          $r('sys.color.ohos_fa_text_secondary'))

          .textAlign(TextAlign.Center)
      }
      .backgroundColor(this.currentTagIndex === index ? '#F1F3F5' :
        '#F1F3F5')
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isClickTagList = true; // 当前点击的是一级列表
        }
      })
      .onClick(() => {
        this.currentTagIndex = index;
        const itemIndex = this.findItemIndex(index);
        this.scroller.scrollToIndex(itemIndex, true);
      })
    }
  }

  /**
   * 根据一级列表索引值获取二级列表索引值
   *
   * @param {number} index - 一级列表索引值
   * @returns {number} 二级列表索引值
   */
  findItemIndex(index: number): number {
    return this.records[index];
  }

  /**
   * 根据二级列表索引值获取对应一级列表索引
   *
   * @param {number} index - 二级列表索引值
   * @returns {number} 一级列表索引值
   */
  findClassIndex(index: number): number {
    for (let i = 0; i < this.records.length - 1; i++) {
      if (index >= this.records[i] && index <= this.records[i + 1]) {
        return i;
      }
    }
    return this.tagLists.length - 1;
  }

  /**
   * 监听一级列表获焦索引变化
   */
  onIndexChange() {
    const start = this.tagIndexPosition.start;
    const end = this.tagIndexPosition.end;
    if ((this.currentTagIndex === end || this.currentTagIndex === end - 1)) {
      let leftScrollCount: number = this.currentTagIndex + 1;
      leftScrollCount = leftScrollCount >= this.tagLists.length - 1 ? this.tagLists.length - 1 : leftScrollCount;
      /**
       * scrollToIndex(value: number, smooth?: boolean, align?: ScrollAlign)
       * 性能知识点：开启smooth动效时，会对经过的所有item进行加载和布局计算，当大量加载item时会导致性能问题。
       */
      this.classifyScroller.scrollToIndex(leftScrollCount, true); // 使获焦item向左滚动
    }
    if (this.currentTagIndex === start || this.currentTagIndex === start + 1) {
      let rightScrollCount: number = this.currentTagIndex - 1;
      rightScrollCount = rightScrollCount <= 0 ? 0 : rightScrollCount;
      this.classifyScroller.scrollToIndex(rightScrollCount, true); // 使获焦item向右滚动
    }
  }
}

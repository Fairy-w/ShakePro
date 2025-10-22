/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import promptAction from '@ohos.promptAction';
import { IconAndDescription, Size } from '../model/Util';
import { router } from '@kit.ArkUI';

const SETTING_WIDTH = 24;
const HIT_TEST_BLOCK_THRESHOLD = 0.2;

/**
 * 滑动页面改变顶部个人信息栏显示效果
 * 效果：上滑页面，用户头像逐渐缩小并移动到返回文字的后方，原本展示的用户名/选择身份/设置/客服的文本和图标渐隐，顶部用户名文本渐显
 * 下滑页面，用户头像逐渐放大并向下移动，顶部用户名文本渐隐，下方用户名/选择身份/设置/客服的文本和图标渐显
 */

@Component
export struct SlideToHideAndDisplaceComponent {
  // 用户头像图片后方个人信息相关组件(用户名/选择身份/满意度调查)的透明度
  @State userRowOpacity: number = 1;
  // 返回文字后方的用户名的透明度(进入页面时处于隐藏状态)
  @State userNameOpacity: number = 0;
  // 用户头像图片高度
  @State userImageHeight: number = 50;
  // Scroll组件顶部与上方Row组件(个人信息栏)的上边距
  @State scrollMarginTop: number = 0;
  // 用户头像图片顶部与父组件Row的上边距
  @State userImageMarginTop: number = 0;
  // 用户头像图片左侧与父组件Row的左边距
  @State userImageMarginLeft: number = 0;
  // 订单相关的图标和描述的数据列表
  ordersInfo: IconAndDescription[] = [
    new IconAndDescription($r("app.media.slidetohideanddisplace_payment"),
      $r('app.string.slidetohideanddisplace_payment')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_receiving"),
      $r('app.string.slidetohideanddisplace_receiving')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_comments"),
      $r('app.string.slidetohideanddisplace_comments')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_more"),
      $r('app.string.slidetohideanddisplace_more'))
  ]
  // 粉丝/收藏/关注/历史相关的栏目的图标和描述的数据列表
  interactionInfo: IconAndDescription[] = [
    new IconAndDescription($r("app.media.slidetohideanddisplace_fans"),
      $r('app.string.slidetohideanddisplace_fans')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_favorites"),
      $r('app.string.slidetohideanddisplace_favorites')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_follow"),
      $r('app.string.slidetohideanddisplace_follow')),
    new IconAndDescription($r("app.media.slidetohideanddisplace_history"),
      $r('app.string.slidetohideanddisplace_history'))
  ]
  // 商品会场的图标和描述的数据列表

  // 可滑动容器组件的控制器
  scroller: Scroller = new Scroller();
  // 处理onclick事件的方法
  handleClick: (() => void) | undefined = undefined;

  // 自定义构建函数，将重复使用的UI元素抽象成一个方法。此处样式为：上方图标下方文字
  @Builder
  iconAndDescription(icon: Resource, description: string | Resource, iconSize?: Size, radius?: number,
    handleClick?: () => void) {
    Column() {
      Image(icon)
        .size(iconSize === undefined ? {
          height: 32,
          width: 32
        } : iconSize)
        .borderRadius(radius)
      Text(description)
        .margin({ top: 5 })
    }
    .onClick(() => {
      // 修改的主要目的是为了让开发者方便找到业务代码，然后修改成自己的业务
      router.pushUrl({
        url: 'pages/Mine',
      },3000);
    })
  }

  // 订单与互动栏的通用样式
  @Styles
  rowStyles() {
    .width($r('app.string.slidetohideanddisplace_size_full'))
    .padding(10)
    .margin({ top:10 })
    .backgroundColor('#aaffffff')
    .borderRadius(8)
  }

  // 自定义构建函数。此处样式为在Row组件中横向排列订单相关的标签：待支付，待收货，待评价，更多
  @Builder
  orders() {
    Row() {
      // 性能知识点：此处在Row中横向排列组件，列表项确定、数量较少，且需要一次性加载，因此使用ForEach。在列表项多的情况下，推荐使用LazyForEach
      ForEach(this.ordersInfo, (item: IconAndDescription) => {
        Column() {
          this.iconAndDescription(item.icon, item.description, undefined, 0, () => {
          })
        }
        .width($r("app.string.slidetohideanddisplace_width_of_elements_in_orders"))
      })
    }
    .rowStyles()
    .justifyContent(FlexAlign.SpaceAround)
  }

  // 自定义构建函数。此处样式为在Row组件中横向排列互动相关的标签：粉丝，收藏，关注，历史
  @Builder
  interaction() {
    Row() {
      ForEach(this.interactionInfo, (item: IconAndDescription) => {
        Column() {
          this.iconAndDescription(item.icon, item.description, undefined, 0, () => {
          })
        }
        .width($r("app.string.slidetohideanddisplace_width_of_elements_in_interaction"))
      })
    }
    .rowStyles()
  }

  // 会员和权益中心栏目
  @Builder
  memberBanner() {
    Row() {
      Column() {
        Text($r('app.string.slidetohideanddisplace_member'))
          .fontSize(20)
          .fontColor('#ffffdd00')
        Text($r('app.string.slidetohideanddisplace_get_off_your_purchases'))
          .margin({ top: 5 })
          .fontColor('#ffcd9900')
      }
      .alignItems(HorizontalAlign.Start)
      .padding(10)

      Blank() // 在容器主轴方向上自动填充容器空余部分

      Column() {
        Image($r("app.media.slidetohideanddisplace_crown"))
          .size({
            width: 32,
            height: 32
          })
        Text($r('app.string.slidetohideanddisplace_center_of_right'))
          .margin({ top: 5 })
          .fontColor('#ffffd247')
      }
      .padding(10)
    }
    .height(80)
    .width($r('app.string.slidetohideanddisplace_size_full'))
    .borderRadius(8)
    .linearGradient({
      angle: 45, // 设置颜色渐变起始角度为顺时针方向45°
      colors: [[0x30fa908a, 0.0], [0x44aaaaa, 0.5], [0x30c2b1fa, 1.0]]
    })
    .onClick(() => {
      promptAction.showToast({ message: $r('app.string.slidetohideanddisplace_member_services') });
    })
  }

  /**
   * 创建一个Row组件，用来显示用户信息，然后在下面创建一个Scroll组件，用来显示其他内容，
   * 当Scroll滑动时，Row组件隐藏且里面的子组件渐隐
   */
  build() {
    Column() {
      Row() {
        Text($r('app.string.slidetohideanddisplace_vip'))
          .onClick(() => {
            promptAction.showToast({ message: $r('app.string.slidetohideanddisplace_vip') });
          })
          .fontWeight(FontWeight.Bolder)
          .fontSize(17)
          .fontColor('#ffcd9900')
        Text($r("app.string.slidetohideanddisplace_user_name"))
          .margin({ left: 30 })
          .opacity(this.userNameOpacity) // userNameOpacity控制顶部用户名的透明度
        Blank()
        Text($r('app.string.slidetohideanddisplace_settings'))
          .opacity(this.userNameOpacity)// 设置的文字透明度与顶部用户名相同
          .onClick(() => {
            // 当组件的不透明度大于阈值时，响应点击事件，显示文本提示框
            if (this.userNameOpacity > HIT_TEST_BLOCK_THRESHOLD) {
              promptAction.showToast({ message: $r('app.string.slidetohideanddisplace_settings') });
            }
          })
        Text($r('app.string.slidetohideanddisplace_customer_service'))
          .margin({
            left: 10,
            right: 10
          })
          .opacity(this.userNameOpacity)// 客服的文字透明度与顶部用户名相同
          .onClick(() => {
            // 当组件的不透明度大于阈值时，响应点击事件，显示文本提示框
            if (this.userNameOpacity > HIT_TEST_BLOCK_THRESHOLD) {
              promptAction.showToast({ message: $r('app.string.slidetohideanddisplace_customer_service') });
            }
          })
      }
      .width($r('app.string.slidetohideanddisplace_size_full'))
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r("app.media.myself"))
          .width(this.userImageHeight)
          .height(this.userImageHeight)// userImageHeight控制头像尺寸
            // userImageMarginTop和userImageMarginLeft控制头像在父容器内的位置
          .margin({ top: this.userImageMarginTop, left: this.userImageMarginLeft })
          .borderRadius(50)

        Column() {
          Text($r("app.string.slidetohideanddisplace_user_name"))
            .fontSize(20)
          Text($r('app.string.slidetohideanddisplace_choose_identity'))

            .fontSize(13)
            .fontColor(Color.Black)
            .margin({ top: 5 })
            .onClick(() => {
              promptAction.showToast({ message: $r('app.string.slidetohideanddisplace_choose_identity') });
            })
        }
        .alignItems(HorizontalAlign.Start)
        .opacity(this.userRowOpacity) // 控制Row组件的透明度
        .padding(10)

        Blank() // 在容器主轴方向上自动填充容器空余部分

        Row() {
          this.iconAndDescription($r("app.media.slidetohideanddisplace_setting"),
            $r('app.string.slidetohideanddisplace_settings'), new Size(SETTING_WIDTH, SETTING_WIDTH), 0, () => {
            })
        }
       // .width($r('app.integer.slidetohideanddisplace_height_eighty'))
        .justifyContent(FlexAlign.SpaceBetween)
        .opacity(this.userRowOpacity)
      }
      .height(80)
      .width($r('app.string.slidetohideanddisplace_size_full'))
      // 当组件的不透明度小于阈值时，阻塞子节点和兄弟节点的触摸测试
      .hitTestBehavior(this.userRowOpacity < HIT_TEST_BLOCK_THRESHOLD ? HitTestMode.Block : HitTestMode.Default)

      // Scroll组件中显示个人信息以外的内容
      //Scroll(this.scroller) {
        Column() {
          // 会员和权益中心栏目
          this.memberBanner()
          // 订单信息栏目
          this.orders()
          // 粉丝/收藏/关注/历史栏目
          this.interaction()



        }
        .width($r('app.string.slidetohideanddisplace_size_full'))
      //}
      .layoutWeight(1)

      .height('100%')


    }
    .width($r('app.string.slidetohideanddisplace_size_full'))
    .height('100%')
    .padding({left:12,right:12})
    .backgroundColor('#F1F3F5')
    .layoutWeight(1)
  }
}

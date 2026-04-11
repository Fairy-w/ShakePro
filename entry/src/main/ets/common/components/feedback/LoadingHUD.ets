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

import lottie from '@ohos/lottie'

/**
 * HUD鍏ㄧОHeads-Up Display锛堟姮澶存樉绀猴級
 */

@Component
export struct LoadingHUD {
  @Link nowProgress: number;
  private politeChickyController: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(); // CanvasRenderingContext2D瀵硅薄
  private politeChicky: string = 'pageLoading'; // 鍔ㄧ敾鍚嶇О
  private politeChickyPath: string = 'common/lottie/pageLoading.json'; // hap鍖呭唴鍔ㄧ敾璧勬簮鏂囦欢璺緞锛屼粎鏀寔json鏍煎紡
  private gradientColor: LinearGradient = new LinearGradient([{ color: Color.Yellow, offset: 0.5 },
    { color: Color.Orange, offset: 1.0 }])

  /**
   * 鍔犺浇鍔ㄧ敾
   * @param autoplay 鎺у埗鍔ㄧ敾鏄惁鑷姩鎾斁鍙傛暟
   */
  initAnimation() {
    // TODO:鐭ヨ瘑鐐?lottie.loadAnimation灏唈son鏁版嵁鐢熸垚鍔ㄧ敾
    lottie.loadAnimation({
      container: this.politeChickyController,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.politeChicky,
      path: this.politeChickyPath,
    })
  }

  build() {
    Column() {
      Stack() {
        Canvas(this.politeChickyController)
          .width(150)
          .height(150)
          .borderRadius(12)
          .onReady(() => {
            // TODO:鐭ヨ瘑鐐?蹇呴』瑕丆anvas缁勪欢鍒濆鍖栦箣鍚庢墠鑳芥墽琛宭ottie.loadAnimation鏂规硶鍘诲姞杞藉姩鐢汇€?            this.initAnimation();
          })
        Row() {
          Progress({ value: this.nowProgress, total: 100, type: ProgressType.Linear })
            .style({ strokeWidth: 10, enableSmoothEffect: true })
            .color(this.gradientColor)
        }
        .width('60%')
        .margin({ top: 100 })
      }.height(150)

      Text(`褰撳墠宸插姞杞?{this.nowProgress}%`)
        .fontSize(16)
        .fontColor(Color.Black)
    }
    .id('loadingHUD')
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.Center)
  }
}
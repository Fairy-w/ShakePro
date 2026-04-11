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
import { LoadingHUD } from '../../common/components/feedback/LoadingHUD';
import { MainPage } from '../../features/home/pages/HomePage';
import taskpool from '@ohos.taskpool';

/**
 * 功能描述：本示例介绍Stack堆叠组件和LoadingProgress加载组件模拟首次进入页面实现页面加载的效果。加载完成后，LoadingProgress组件会消失并显示加载结果页（即商品页）。
 *
 * 推荐场景：应用加载缓慢的页面，如商城页面首页等场景，为了提升用户点击响应的体验。
 *
 * 核心组件：1.LoadingHUD
 *
 * 实现步骤：
 * 1.创建一个Stack组件，LoadingHUD是加载页，内部的GoodsList为商品列表页。
 * 2.进入页面首先展示LoadingHUD加载页，5秒后，LoadingHUD加载页消失并出现GoodsList商品列表页。
 */
const MILLISECONDS: number = 3000; // 姣鏁?
@Component
export struct PageLoadingComponent {
  @State isLoading: boolean = true;
  @State nowProgress: number = 0;
  aboutToAppear(): void {
    // 妯℃嫙缃戠粶璇锋眰鎿嶄綔锛岃姹傜綉缁?绉掑悗寰楀埌鏁版嵁锛岄€氱煡缁勪欢锛屽彉鏇村垪琛ㄦ暟鎹?    // 使用TaskPool模拟异步操作
    // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
    // 模拟进度，开发者可在实际业务中与服务端协调当前进度，自行实现
    
    // 直接设置加载完成状态，避免使用定时器
    this.isLoading = false;
    this.nowProgress = 100;
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 鍔犺浇椤?HUD鍏ㄧОHeads-Up Display锛堟姮澶存樉绀猴級
        LoadingHUD({nowProgress:this.nowProgress});
      } else {
        // 鍟嗗搧椤?        MainPage();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
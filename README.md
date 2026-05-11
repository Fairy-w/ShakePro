# ShakePro

ShakePro 是一款基于 HarmonyOS 与 ArkTS 开发的智能调酒应用，围绕配方推荐、AI 调酒、材料管理、社区分享和个人收藏构建完整的鸡尾酒体验流程。

应用面向课程项目与毕业设计场景实现，当前已经覆盖从账号登录、首页推荐、酒谱浏览，到 AI 生成、扫码录入材料、社区发帖与个人管理的一整套核心流程。

## 项目亮点

- AI 调酒：根据口味描述生成个性化鸡尾酒方案，并支持收藏 AI 配方。
- 配方推荐：提供酒谱库、推荐理由、配方详情和调制步骤展示。
- 材料管理：支持扫码识别与手动录入，维护个人调酒台材料库存。
- 社区互动：支持浏览帖子、查看详情、发布图文笔记。
- 收藏体系：区分系统酒谱收藏与 AI 生成收藏，便于回看与复用。
- HarmonyOS 实践：采用 Stage 模型、ArkTS 与模块化目录组织方式实现。

## 技术栈

- HarmonyOS Stage 模型
- ArkTS
- `@ohos/axios`
- `@ohos/lottie`
- Hvigor

## 项目结构

```text
ShakePro
├─ AppScope                 应用级配置与图标资源
├─ entry                    HarmonyOS 主模块
│  ├─ src/main/ets/app      Ability 入口
│  ├─ src/main/ets/core     路由、环境配置与日志基础设施
│  ├─ src/main/ets/common   公共组件、网络、存储、接口常量与工具
│  ├─ src/main/ets/features 业务功能模块
│  └─ src/main/resources    页面清单、多语言与媒体资源
├─ docs                     项目文档与 README 页面截图
├─ hvigor                   构建配置
└─ build-profile.json5      签名配置模板
```

## 功能模块

### 1. 账户与首页

- 用户登录、注册、会话保持
- 首页推荐入口与模块导航
- 智能调酒工作台总览

| 登录页 | 首页 |
| --- | --- |
| ![登录页](docs/screenshots/login.jpg) | ![首页](docs/screenshots/home.jpg) |

### 2. AI 调酒与配方推荐

- 输入口味偏好生成个性化鸡尾酒
- 查看推荐理由、材料配比与调制步骤
- 支持加入 AI 收藏，便于后续复用

| AI 调酒输入 | AI 调酒结果 |
| --- | --- |
| ![AI 调酒输入](docs/screenshots/ai-cocktail-input.jpg) | ![AI 调酒结果](docs/screenshots/ai-cocktail-result.jpg) |

| 配方库 | 酒谱详情 |
| --- | --- |
| ![配方库](docs/screenshots/recipe-library.jpg) | ![酒谱详情](docs/screenshots/recipe-detail.jpg) |

### 3. 材料库与调酒台

- 扫描条形码快速录入材料
- 手动维护材料信息与库存状态
- 在个人调酒台中集中管理可用材料

| 扫码录入 | 材料库 |
| --- | --- |
| ![扫码录入](docs/screenshots/barcode-scan.jpg) | ![材料库](docs/screenshots/material-library.jpg) |

| 调酒台 |
| --- |
| ![调酒台](docs/screenshots/bartending-station.jpg) |

### 4. 社区与个人中心

- 浏览社区动态与酒友分享
- 发布图文笔记
- 查看个人主页、收藏和设置

| 社区首页 | 发布笔记 |
| --- | --- |
| ![社区首页](docs/screenshots/community-feed.jpg) | ![发布笔记](docs/screenshots/community-editor.jpg) |

| 我的收藏 | 个人中心 | 设置 |
| --- | --- | --- |
| ![我的收藏](docs/screenshots/favorites.jpg) | ![个人中心](docs/screenshots/profile.jpg) | ![设置](docs/screenshots/settings.jpg) |

## 后端配置

后端环境参数位于：

```text
entry/src/main/ets/core/env/AppEnv.ets
```

运行前请将 `API_BASE_URL` 修改为当前可访问的后端服务地址，例如：

```text
http://192.168.x.x:8080
```

接口路径常量位于：

```text
entry/src/main/ets/common/constants/ApiConfig.ets
```

## 签名配置

`build-profile.example.json5` 是脱敏后的签名配置模板。首次运行或打包前，请根据本机 HarmonyOS 签名材料创建并配置 `build-profile.json5`，重点检查以下字段：

- `YOUR_CERT_PATH`
- `YOUR_KEY_ALIAS`
- `YOUR_KEY_PASSWORD`
- `YOUR_PROFILE_PATH`
- `YOUR_STORE_FILE`
- `YOUR_STORE_PASSWORD`

公开上传仓库前，请确认没有提交本机真实证书路径、签名口令或密钥材料。

## 权限说明

- `ohos.permission.INTERNET`：用于访问后端服务与业务接口。
- `ohos.permission.CAMERA`：用于材料条码扫描。

## 运行方式

1. 使用 DevEco Studio 打开项目根目录。
2. 根据本机环境配置 HarmonyOS 签名材料。
3. 修改 `entry/src/main/ets/core/env/AppEnv.ets` 中的 `API_BASE_URL`。
4. 同步依赖并构建 `entry` 模块。
5. 在模拟器或真机上运行应用。

## 打包说明

执行 release 构建前，请确认：

- 签名配置已替换为本机真实可用配置。
- 后端地址可以被目标设备访问。
- 本地缓存与 IDE 配置文件未被误提交。
- `oh_modules`、`.hvigor`、`.idea`、`local.properties` 等文件不进入发布内容。

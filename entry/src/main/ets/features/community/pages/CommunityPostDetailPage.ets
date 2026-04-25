import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { HttpRequestError, toUserFacingMessage } from '../../../common/network/ApiResponse';
import { communityRepository } from '../repository/CommunityRepository';
import {
  CommunityPostDetailModel,
  createEmptyCommunityPostDetailModel,
  toCommunityPostDetailModel
} from '../model/CommunityApiModels';

interface CommunityPostRouteParams {
  postId?: string;
}

@Entry({ routeName: 'CommunityPostDetailPage' })
@Component
export struct CommunityPostDetailPage {
  @State private currentPost: CommunityPostDetailModel = createEmptyCommunityPostDetailModel();
  @State private currentPostId: string = '';
  @State private errorMessage: string = '';
  @State private traceId: string = '';
  @State private detailLoading: boolean = true;

  aboutToAppear(): void {
    this.resolveRoutePost();
    if (this.currentPostId.length > 0) {
      void this.loadPostDetail();
    }
  }

  private normalizeRoutePostId(value?: string): string {
    if (typeof value === 'string') {
      return value.trim();
    }
    return '';
  }

  private resolveRoutePost(): void {
    const routeParams: CommunityPostRouteParams = router.getParams() as CommunityPostRouteParams;
    this.currentPostId = this.normalizeRoutePostId(routeParams.postId);
    if (this.currentPostId.length === 0) {
      this.errorMessage = '未找到帖子';
      this.detailLoading = false;
    }
  }

  private async loadPostDetail(): Promise<void> {
    this.detailLoading = true;
    this.errorMessage = '';
    this.traceId = '';

    try {
      const detail = await communityRepository.getCommunityPostDetail(this.currentPostId);
      this.currentPost = toCommunityPostDetailModel(detail);
    } catch (error) {
      this.currentPost = createEmptyCommunityPostDetailModel();
      this.errorMessage = this.resolveErrorMessage(error as Object, '获取帖子详情失败');
      this.traceId = this.resolveTraceId(error as Object);
    } finally {
      this.detailLoading = false;
    }
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    if (error instanceof HttpRequestError) {
      return toUserFacingMessage(error.message, fallbackMessage);
    }
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private resolveTraceId(error: Object): string {
    if (error instanceof HttpRequestError && typeof error.traceId === 'string') {
      return error.traceId;
    }
    const errorObject = error as Record<string, Object>;
    const traceId = errorObject['traceId'];
    if (typeof traceId === 'string') {
      return traceId;
    }
    return '';
  }

  private hasImages(): boolean {
    return this.currentPost.images.length > 0;
  }


  private hasDetailContent(): boolean {
    return this.currentPost.id.length > 0;
  }

  private resolveAuthorInitial(name: string): string {
    if (name.length === 0) {
      return '酒';
    }
    return name.substring(0, 1);
  }

  @Builder
  private buildTopBar() {
    Row() {
      Row() {
        Text('<')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.surfacePrimary)
      .borderRadius(20)
      .border({ width: 1, color: UiTokens.borderPrimary })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%');
  }

  @Builder
  private buildMediaSection() {
    if (this.hasImages()) {
      Swiper() {
        ForEach(this.currentPost.images, (item: string) => {
          Image(item)
            .width('100%')
            .height(420)
            .borderRadius(26)
            .objectFit(ImageFit.Cover);
        }, (item: string) => item);
      }
      .width('100%')
      .height(420)
      .indicator(this.currentPost.images.length > 1)
      .autoPlay(false)
      .loop(false);
    }
  }

  @Builder
  private buildLoadingState() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(26)
        .height(26)
        .color(UiTokens.textPrimary);

      Text('加载中...')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .margin(16);
  }

  @Builder
  private buildErrorState() {
    Column({ space: 12 }) {
      Text(this.errorMessage)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);

      if (this.traceId.length > 0) {
        Text('问题编号：' + this.traceId)
          .fontSize(11)
          .fontColor(UiTokens.textTertiary)
          .textAlign(TextAlign.Center);
      }

      Button('重试')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.pageAccentMint)
        .borderRadius(16)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          if (this.currentPostId.length > 0) {
            void this.loadPostDetail();
          }
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .margin(16);
  }

  @Builder
  private buildAuthorAvatar() {
    if (this.currentPost.authorAvatar.length > 0) {
      Image(this.currentPost.authorAvatar)
        .width(44)
        .height(44)
        .borderRadius(22)
        .objectFit(ImageFit.Cover);
    } else {
      Row() {
        Text(this.resolveAuthorInitial(this.currentPost.authorName))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.surfaceWarm)
      .borderRadius(22)
      .border({ width: 1, color: UiTokens.borderPrimary });
    }
  }

  @Builder
  private buildMetaRow() {
    Row({ space: 12 }) {
      this.buildAuthorAvatar();

      Column({ space: 4 }) {
        Text(this.currentPost.authorName)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Text(this.currentPost.publishText)
          .fontSize(11)
          .fontColor(UiTokens.textSecondary);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%');
  }

  @Builder
  private buildActionRow() {
    Row({ space: 18 }) {
      Text('赞 ' + this.currentPost.likeCount.toString())
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);

      Text('评 ' + this.currentPost.commentCount.toString())
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);

      Text('藏 ' + this.currentPost.favoriteCount.toString())
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);
    }
    .width('100%');
  }

  @Builder
  private buildContentSection() {
    Column({ space: 16 }) {
      this.buildMetaRow();

      Text(this.currentPost.title)
        .width('100%')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(33);

      Column({ space: 14 }) {
        ForEach(this.currentPost.bodyParagraphs, (item: string) => {
          Text(item)
            .width('100%')
            .fontSize(14)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(24);
        }, (item: string) => item);
      }
      .width('100%');

      this.buildActionRow();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 18, bottom: 32 });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.58], [UiTokens.pageGradientEnd, 1.0]]
        });

      Column({ space: 16 }) {
        this.buildTopBar();

        if (this.detailLoading) {
          Column() {
            this.buildLoadingState();
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start);
        } else if (this.errorMessage.length > 0 && !this.hasDetailContent()) {
          Column() {
            this.buildErrorState();
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start);
        } else {
          Scroll() {
            Column({ space: 16 }) {
              this.buildMediaSection();
              this.buildContentSection();
            }
            .width('100%')
            .constraintSize({ minHeight: '100%' })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off);
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground);
  }
}

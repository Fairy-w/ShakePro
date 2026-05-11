import { RoutePaths } from '../../../core/router/RoutePaths';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UiTokens } from '../../../common/constants/UiTokens';
import { HttpRequestError, toUserFacingMessage } from '../../../common/network/ApiResponse';
import { communityRepository } from '../repository/CommunityRepository';
import {
  CommunityPostCardModel,
  CommunityPostPageDto,
  toCommunityPostCardModel
} from '../model/CommunityApiModels';

@Entry({ routeName: 'CommunityPage' })
@Component
export struct CommunityPage {
  @Prop pageBottomInset: number = 0;

  private readonly pageSize: number = 10;

  @State private posts: CommunityPostCardModel[] = [];
  @State private currentPageNo: number = 1;
  @State private hasMore: boolean = false;
  @State private feedLoading: boolean = true;
  @State private loadMoreBusy: boolean = false;
  @State private errorMessage: string = '';
  @State private traceId: string = '';

  aboutToAppear(): void {
    void this.refreshFeed();
  }

  private resolvePageBottomInset(): number {
    return this.pageBottomInset > 0 ? this.pageBottomInset : 24;
  }

  private showActionToast(message: string): void {
    promptAction.showToast({ message });
  }

  private hasCommunityPosts(): boolean {
    return this.posts.length > 0;
  }

  private openPostDetail(postId: string): void {
    router.pushUrl({
      url: RoutePaths.COMMUNITY_DETAIL,
      params: {
        postId: postId
      }
    }, 3000);
  }

  private openNoteEditor(): void {
    router.pushUrl({
      url: RoutePaths.COMMUNITY_EDITOR
    }, 3000);
  }

  private async refreshFeed(): Promise<void> {
    await this.loadFeed(1, true);
  }

  private async loadMore(): Promise<void> {
    if (!this.hasMore || this.loadMoreBusy) {
      return;
    }
    await this.loadFeed(this.currentPageNo + 1, false);
  }

  private async loadFeed(pageNo: number, reset: boolean): Promise<void> {
    if (reset) {
      this.feedLoading = true;
      this.errorMessage = '';
      this.traceId = '';
    } else {
      this.loadMoreBusy = true;
    }

    try {
      const response: CommunityPostPageDto = await communityRepository.getCommunityPosts({
        pageNo: pageNo,
        pageSize: this.pageSize
      });
      const mappedPosts = this.mapPostCards(response, reset ? 0 : this.posts.length);
      this.posts = reset ? mappedPosts : this.posts.concat(mappedPosts);
      this.currentPageNo = typeof response.pageNo === 'number' && response.pageNo > 0 ? response.pageNo : pageNo;
      this.hasMore = response.hasMore === true;
    } catch (error) {
      if (reset) {
        this.posts = [];
        this.errorMessage = this.resolveErrorMessage(error as Object, '获取社区帖子列表失败');
        this.traceId = this.resolveTraceId(error as Object);
      } else {
        this.showActionToast(this.resolveErrorMessage(error as Object, '加载更多失败'));
      }
    } finally {
      if (reset) {
        this.feedLoading = false;
      }
      this.loadMoreBusy = false;
    }
  }

  private mapPostCards(response: CommunityPostPageDto, startIndex: number): CommunityPostCardModel[] {
    const result: CommunityPostCardModel[] = [];
    const list = Array.isArray(response.list) ? response.list : [];
    for (let index: number = 0; index < list.length; index += 1) {
      result.push(toCommunityPostCardModel(list[index], startIndex + index));
    }
    return result;
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

  private getPostsByParity(parity: number): CommunityPostCardModel[] {
    const result: CommunityPostCardModel[] = [];
    for (let index: number = 0; index < this.posts.length; index += 1) {
      if (index % 2 === parity) {
        result.push(this.posts[index]);
      }
    }
    return result;
  }

  private resolveAuthorInitial(name: string): string {
    if (name.length === 0) {
      return '酒';
    }
    return name.substring(0, 1);
  }

  private canLoadMore(): boolean {
    return this.hasMore && !this.feedLoading;
  }

  @Builder
  private buildHeader() {
    Row() {
      Text('社区')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .lineHeight(36);

      Blank();

      Button('写笔记')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textInverse)
        .backgroundColor(UiTokens.brandStrong)
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.openNoteEditor();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildAuthorAvatar(item: CommunityPostCardModel) {
    if (item.authorAvatar.length > 0) {
      Image(item.authorAvatar)
        .width(28)
        .height(28)
        .borderRadius(14)
        .objectFit(ImageFit.Cover);
    } else {
      Row() {
        Text(this.resolveAuthorInitial(item.authorName))
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.surfaceWarm)
      .borderRadius(14)
      .border({ width: 1, color: UiTokens.borderPrimary });
    }
  }


  @Builder
  private buildPostMedia(item: CommunityPostCardModel) {
    if (item.coverImage.length > 0) {
      Image(item.coverImage)
        .width('100%')
        .height(item.imageHeight)
        .borderRadius(26)
        .objectFit(ImageFit.Cover);
    } else {
      Column()
        .width('100%')
        .height(146)
        .backgroundColor(UiTokens.surfaceWarm)
        .borderRadius(26)
        .border({ width: 1, color: UiTokens.borderPrimary });
    }
  }

  @Builder
  private buildPostCard(item: CommunityPostCardModel) {
    Column({ space: 12 }) {
      this.buildPostMedia(item);

      Column({ space: 10 }) {
        Text(item.title)
          .width('100%')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .lineHeight(23)
          .maxLines(3);

        Text(item.summary)
          .width('100%')
          .fontSize(12)
          .fontColor(UiTokens.textSecondary)
          .lineHeight(19)
          .maxLines(item.excerptLineCount);

        Row({ space: 8 }) {
          this.buildAuthorAvatar(item);

          Column() {
            Text(item.authorName)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiTokens.textPrimary)
              .maxLines(1);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Text(item.publishText)
            .fontSize(11)
            .fontColor(UiTokens.textSecondary);
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 14 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(UiTokens.radiusXl)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .shadow({ radius: 14, color: UiTokens.shadowSoft, offsetX: 0, offsetY: 8 })
    .onClick(() => {
      this.openPostDetail(item.id);
    });
  }

  @Builder
  private buildFeedColumn(parity: number) {
    Column({ space: 14 }) {
      ForEach(this.getPostsByParity(parity), (item: CommunityPostCardModel) => {
        this.buildPostCard(item);
      }, (item: CommunityPostCardModel) => item.id);
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start);
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
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildErrorState() {
    Column({ space: 12 }) {
      Text('社区加载失败')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Text(this.errorMessage)
        .fontSize(13)
        .fontColor(UiTokens.textSecondary)
        .lineHeight(20)
        .textAlign(TextAlign.Center);

      if (this.traceId.length > 0) {
        Text('问题编号：' + this.traceId)
          .fontSize(11)
          .fontColor(UiTokens.textTertiary)
          .textAlign(TextAlign.Center);
      }

      Button('重新加载')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiTokens.textPrimary)
        .backgroundColor(UiTokens.pageAccentMint)
        .borderRadius(16)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          void this.refreshFeed();
        });
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 24, bottom: 24 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 12 }) {
      Text('还没有内容')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor(UiTokens.surfacePrimary)
    .borderRadius(24)
    .border({ width: 1, color: UiTokens.borderPrimary });
  }

  @Builder
  private buildFeedSection() {
    Column({ space: 14 }) {
      if (this.feedLoading && !this.hasCommunityPosts()) {
        this.buildLoadingState();
      } else if (this.errorMessage.length > 0 && !this.hasCommunityPosts()) {
        this.buildErrorState();
      } else if (!this.hasCommunityPosts()) {
        this.buildEmptyState();
      } else {
        Column({ space: 14 }) {
          Row({ space: 14 }) {
            this.buildFeedColumn(0);
            this.buildFeedColumn(1);
          }
          .width('100%')
          .alignItems(VerticalAlign.Top);

          if (this.canLoadMore()) {
            Button(this.loadMoreBusy ? '加载中...' : '加载更多')
              .width('100%')
              .height(46)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiTokens.textPrimary)
              .backgroundColor(UiTokens.surfacePrimary)
              .borderRadius(18)
              .border({ width: 1, color: UiTokens.borderPrimary })
              .onClick(() => {
                void this.loadMore();
              });
          }
        }
        .width('100%');
      }
    }
    .width('100%');
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          repeating: false,
          colors: [[UiTokens.pageGradientStart, 0.0], [UiTokens.pageGradientMiddle, 0.56], [UiTokens.pageGradientEnd, 1.0]]
        });

      Column()
        .width(220)
        .height(220)
        .borderRadius(76)
        .backgroundColor(UiTokens.pageAccentBlue)
        .opacity(0.54)
        .position({ x: -80, y: 68 });

      Column()
        .width(180)
        .height(180)
        .borderRadius(58)
        .backgroundColor(UiTokens.pageAccentMint)
        .opacity(0.7)
        .position({ x: 258, y: 520 });

      Scroll() {
        Column({ space: 18 }) {
          this.buildHeader();
          this.buildFeedSection();
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16, top: 20, bottom: this.resolvePageBottomInset() });
      }
      .height('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%');
  }
}

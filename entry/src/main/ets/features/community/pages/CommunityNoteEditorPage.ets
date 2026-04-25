import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UiTokens } from '../../../common/constants/UiTokens';
import { HttpRequestError, toUserFacingMessage } from '../../../common/network/ApiResponse';
import { sessionStore } from '../../../common/storage/SessionStore';
import { communityRepository } from '../repository/CommunityRepository';
import { CreateCommunityPostRequest } from '../model/CommunityApiModels';

interface SelectedNoteImage {
  id: string;
  previewUri: string;
  uploadedUrl: string;
}

@Entry({ routeName: 'CommunityNoteEditorPage' })
@Component
export struct CommunityNoteEditorPage {
  @State private pageTitle: string = '写笔记';
  @State private noteContent: string = '';
  @State private noteTags: string[] = [];
  @State private selectedImages: SelectedNoteImage[] = [];
  @State private uploadBusy: boolean = false;
  @State private submitBusy: boolean = false;

  private getHostContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private async ensureSessionStore(): Promise<void> {
    if (sessionStore.isInitialized()) {
      return;
    }
    await sessionStore.init(this.getHostContext());
  }

  private getWordCountText(): string {
    return this.noteContent.length === 0 ? '0 字' : this.noteContent.length.toString() + ' 字';
  }

  private canAddMoreImages(): boolean {
    return this.selectedImages.length < 9;
  }

  private getImageCountText(): string {
    return this.selectedImages.length.toString() + '/9';
  }

  private buildPostTitle(): string {
    const normalizedContent = this.noteContent.trim();
    if (normalizedContent.length === 0) {
      return '';
    }
    const firstLine = normalizedContent.split('\n')[0].trim();
    if (firstLine.length === 0) {
      return '';
    }
    return firstLine.length > 24 ? firstLine.slice(0, 24) : firstLine;
  }

  private buildCreatePostRequest(): CreateCommunityPostRequest {
    const payload: CreateCommunityPostRequest = {
      content: this.noteContent.trim(),
      images: this.getUploadedImageUrls()
    };
    const title = this.buildPostTitle();
    if (title.length > 0) {
      payload.title = title;
    }
    if (this.noteTags.length > 0) {
      payload.tags = this.noteTags;
    }
    return payload;
  }

  private getUploadedImageUrls(): string[] {
    const result: string[] = [];
    for (let index: number = 0; index < this.selectedImages.length; index += 1) {
      const uploadedUrl = this.selectedImages[index].uploadedUrl.trim();
      if (uploadedUrl.length > 0) {
        result.push(uploadedUrl);
      }
    }
    return result;
  }

  private resolvePreviewSource(item: SelectedNoteImage): string {
    if (item.previewUri.length > 0) {
      return item.previewUri;
    }
    return item.uploadedUrl;
  }

  private createSelectedImage(localUri: string, uploadedUrl: string): SelectedNoteImage {
    return {
      id: 'img-' + Date.now().toString() + '-' + this.selectedImages.length.toString(),
      previewUri: localUri,
      uploadedUrl: uploadedUrl
    } as SelectedNoteImage;
  }

  private resolveImageFileExtension(uri: string): string {
    const normalizedUri = uri.trim();
    const queryIndex = normalizedUri.indexOf('?');
    const pathValue = queryIndex >= 0 ? normalizedUri.slice(0, queryIndex) : normalizedUri;
    const dotIndex = pathValue.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex >= pathValue.length - 1) {
      return '.jpg';
    }
    const suffix = pathValue.slice(dotIndex);
    return suffix.length > 8 ? '.jpg' : suffix;
  }

  private buildCacheImagePath(originUri: string, index: number): string {
    return this.getHostContext().cacheDir + '/community_upload_' + Date.now().toString() + '_' + index.toString() + this.resolveImageFileExtension(originUri);
  }

  private copyImageToCache(srcUri: string, destPath: string): void {
    const srcFile = fileIo.openSync(srcUri);
    const dstFile = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(srcFile.fd, dstFile.fd);
    fileIo.closeSync(srcFile);
    fileIo.closeSync(dstFile);
  }

  private deleteCacheImage(cachePath: string): void {
    try {
      fileIo.unlinkSync(cachePath);
    } catch (_error) {
    }
  }

  private removeSelectedImage(imageId: string): void {
    const nextImages: SelectedNoteImage[] = [];
    for (let index: number = 0; index < this.selectedImages.length; index += 1) {
      if (this.selectedImages[index].id !== imageId) {
        nextImages.push(this.selectedImages[index]);
      }
    }
    this.selectedImages = nextImages;
  }

  private resolveErrorMessage(error: Object, fallbackMessage: string): string {
    if (error instanceof HttpRequestError) {
      return toUserFacingMessage(error.message, fallbackMessage);
    }
    const errorObject = error as Record<string, Object>;
    const message = errorObject['message'];
    return toUserFacingMessage(typeof message === 'string' ? message : undefined, fallbackMessage);
  }

  private async selectPhotoUris(): Promise<string[]> {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 9 - this.selectedImages.length;
    const result = await picker.select(options);
    if (!result || !Array.isArray(result.photoUris)) {
      return [];
    }
    const uris: string[] = [];
    for (let index: number = 0; index < result.photoUris.length; index += 1) {
      const item = typeof result.photoUris[index] === 'string' ? result.photoUris[index].trim() : '';
      if (item.length > 0) {
        uris.push(item);
      }
    }
    return uris;
  }

  private async handleAddImage(): Promise<void> {
    if (this.uploadBusy || !this.canAddMoreImages()) {
      return;
    }

    try {
      await this.ensureSessionStore();
      const pickedUris = await this.selectPhotoUris();
      if (pickedUris.length === 0) {
        return;
      }

      this.uploadBusy = true;
      const nextImages: SelectedNoteImage[] = [];
      for (let index: number = 0; index < this.selectedImages.length; index += 1) {
        nextImages.push(this.selectedImages[index]);
      }

      for (let index: number = 0; index < pickedUris.length; index += 1) {
        const cachePath = this.buildCacheImagePath(pickedUris[index], index);
        this.copyImageToCache(pickedUris[index], cachePath);
        try {
          const uploadedUrl = await communityRepository.uploadCommunityImage(this.getHostContext(), cachePath);
          nextImages.push(this.createSelectedImage(pickedUris[index], uploadedUrl));
        } finally {
          this.deleteCacheImage(cachePath);
        }
      }

      this.selectedImages = nextImages;
      this.showActionToast('已上传 ' + pickedUris.length.toString() + ' 张');
    } catch (error) {
      this.showActionToast(this.resolveErrorMessage(error as Object, '上传图片失败'));
    } finally {
      this.uploadBusy = false;
    }
  }

  private async submitPost(): Promise<void> {
    if (this.submitBusy) {
      return;
    }

    if (this.noteContent.trim().length === 0) {
      this.showActionToast('请先输入正文');
      return;
    }

    this.submitBusy = true;
    try {
      await this.ensureSessionStore();
      const result = await communityRepository.createCommunityPost(this.buildCreatePostRequest());
      const postId = typeof result.postId === 'string' ? result.postId.trim() : '';
      this.showActionToast('发布成功');
      if (postId.length > 0) {
        router.replaceUrl({
          url: 'features/community/pages/CommunityPostDetailPage',
          params: {
            postId: postId
          }
        }, 3000);
        return;
      }
      router.back();
    } catch (error) {
      this.showActionToast(this.resolveErrorMessage(error as Object, '发布笔记失败'));
    } finally {
      this.submitBusy = false;
    }
  }

  private showActionToast(message: string): void {
    promptAction.showToast({ message });
  }

  @Builder
  private buildHeader() {
    Row() {
      Text('取消')
        .fontSize(14)
        .fontColor(UiTokens.textSecondary)
        .onClick(() => {
          router.back();
        });

      Blank();

      Text(this.pageTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textPrimary);

      Blank();

      Button(this.submitBusy ? '发布中...' : '发布')
        .height(36)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(UiTokens.textInverse)
        .backgroundColor(UiTokens.brandStrong)
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .opacity(this.submitBusy ? 0.7 : 1)
        .onClick(() => {
          void this.submitPost();
        });
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private buildAddImageCard() {
    Column({ space: 8 }) {
      Text('+')
        .fontSize(28)
        .fontWeight(FontWeight.Lighter)
        .fontColor(UiTokens.textSecondary);

      Text(this.uploadBusy ? '上传中...' : '添加图片')
        .fontSize(12)
        .fontColor(UiTokens.textSecondary);
    }
    .width(104)
    .height(132)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(UiTokens.surfaceSecondary)
    .borderRadius(22)
    .border({ width: 1, color: UiTokens.borderPrimary })
    .onClick(() => {
      void this.handleAddImage();
    });
  }

  @Builder
  private buildSelectedImageCard(item: SelectedNoteImage) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.resolvePreviewSource(item))
        .width(104)
        .height(132)
        .borderRadius(22)
        .objectFit(ImageFit.Cover);

      Row() {
        Text('x')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textInverse);
      }
      .width(24)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(UiTokens.overlayMask)
      .borderRadius(12)
      .margin({ top: 8, right: 8 })
      .onClick(() => {
        this.removeSelectedImage(item.id);
      });
    }
    .width(104)
    .height(132);
  }

  @Builder
  private buildImageSection() {
    Column({ space: 12 }) {
      Row() {
        Text('图片')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Blank();

        Text(this.getImageCountText())
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%');

      Scroll() {
        Row({ space: 12 }) {
          if (this.canAddMoreImages()) {
            this.buildAddImageCard();
          }

          ForEach(this.selectedImages, (item: SelectedNoteImage) => {
            this.buildSelectedImageCard(item);
          }, (item: SelectedNoteImage) => item.id);
        }
        .padding({ right: 16 });
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off);
    }
    .width('100%');
  }

  @Builder
  private buildEditorSection() {
    Column({ space: 12 }) {
      Row() {
        Text('正文')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary);

        Blank();

        Text(this.getWordCountText())
          .fontSize(12)
          .fontColor(UiTokens.textSecondary);
      }
      .width('100%');

      TextArea({ placeholder: '写点什么...', text: this.noteContent })
        .width('100%')
        .height(380)
        .fontSize(15)
        .fontColor(UiTokens.textPrimary)
        .placeholderColor(UiTokens.textTertiary)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(24)
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .border({ width: 1, color: UiTokens.borderPrimary })
        .onChange((value: string) => {
          this.noteContent = value;
        });
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

      Scroll() {
        Column({ space: 18 }) {
          this.buildHeader();
          this.buildImageSection();
          this.buildEditorSection();
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16, top: 0, bottom: 42 });
      }
      .height('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiTokens.pageBackground);
  }
}

import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct AICocktailRefineSheet {
  @Prop inputText: string = '';
  @Prop isLoading: boolean = false;
  @Prop promptSamples: string[] = [];
  onClose: () => void = () => {};
  onInputChange: (value: string) => void = () => {};
  onSelectSample: (sample: string) => void = () => {};
  onSubmit: () => void = () => {};

  @Builder
  private buildPromptSamples() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.promptSamples, (sample: string) => {
          Button(sample)
            .fontSize(12)
            .fontColor(UiTokens.textAccent)
            .backgroundColor(UiTokens.surfacePrimary)
            .borderRadius(16)
            .border({ width: 1, color: UiTokens.borderPrimary })
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .onClick(() => {
              this.onSelectSample(sample);
            });
        }, (sample: string) => sample);
      }
      .padding({ right: 16 });
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off);
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Column({ space: 4 }) {
          Text('继续调整')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(UiTokens.textPrimary);

          Text('补充一点新偏好，再看一轮。')
            .fontSize(12)
            .fontColor(UiTokens.textSecondary)
            .lineHeight(18);
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Button('先收起')
          .height(36)
          .fontSize(12)
          .fontColor(UiTokens.textAccent)
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(14)
          .border({ width: 1, color: UiTokens.borderPrimary })
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.onClose();
          });
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      TextInput({ placeholder: '比如：想更清爽、低酒精，或者只用手边现有材料', text: this.inputText })
        .width('100%')
        .height(56)
        .fontSize(14)
        .fontColor(UiTokens.textPrimary)
        .placeholderColor(UiTokens.textTertiary)
        .backgroundColor(UiTokens.surfacePrimary)
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .border({ width: 1, color: UiTokens.borderPrimary })
        .onChange((value: string) => {
          this.onInputChange(value);
        });

      this.buildPromptSamples();

      Button(this.isLoading ? '正在重新配酒...' : '按新想法重新推荐')
        .width('100%')
        .height(52)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .enabled(!this.isLoading)
        .fontColor(UiTokens.textInverse)
        .backgroundColor(UiTokens.aiPrimary)
        .borderRadius(18)
        .onClick(() => {
          this.onSubmit();
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 28 })
    .backgroundColor(UiTokens.surfaceWarm)
    .borderRadius({ topLeft: 28, topRight: 28, bottomLeft: 20, bottomRight: 20 })
    .border({ width: 1, color: UiTokens.borderWarm })
    .shadow({ radius: 24, color: UiTokens.shadowStrong, offsetX: 0, offsetY: -8 });
  }
}

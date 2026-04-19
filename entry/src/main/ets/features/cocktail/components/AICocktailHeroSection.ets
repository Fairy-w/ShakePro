import { UiTokens } from '../../../common/constants/UiTokens';

@Component
export struct AICocktailHeroSection {
  @Prop title: string = '';
  @Prop description: string = '';
  @Prop inputText: string = '';
  @Prop isLoading: boolean = false;
  @Prop promptSamples: string[] = [];
  onInputChange: (value: string) => void = () => {};
  onSubmit: () => void = () => {};
  onSelectSample: (sample: string) => void = () => {};

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
    Column({ space: 16 }) {
      Column({ space: 8 }) {
        Text(this.title)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(UiTokens.textPrimary)
          .textAlign(TextAlign.Center)
          .lineHeight(40);

        Text(this.description)
          .fontSize(13)
          .fontColor(UiTokens.textSecondary)
          .textAlign(TextAlign.Center)
          .lineHeight(20);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);

      Column({ space: 10 }) {
        TextInput({ placeholder: '比如：清爽一点，适合聚会，家里有金酒和柠檬', text: this.inputText })
          .width('100%')
          .height(56)
          .fontSize(14)
          .fontColor(UiTokens.textPrimary)
          .placeholderColor(UiTokens.textTertiary)
          .backgroundColor(UiTokens.surfacePrimary)
          .borderRadius(22)
          .padding({ left: 18, right: 18 })
          .border({ width: 1, color: UiTokens.borderPrimary })
          .onChange((value: string) => {
            this.onInputChange(value);
          });

        Button(this.isLoading ? '正在为你配酒...' : '开始推荐')
          .width('46%')
          .height(54)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .enabled(!this.isLoading)
          .fontColor(UiTokens.textInverse)
          .backgroundColor(UiTokens.aiPrimary)
          .borderRadius(20)
          .onClick(() => {
            this.onSubmit();
          });
      }
      .width('92%')
      .constraintSize({ maxWidth: 680 });

      this.buildPromptSamples();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}

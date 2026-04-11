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
            .fontColor('#E9D8BD')
            .backgroundColor('#141715')
            .borderRadius(16)
            .border({ width: 1, color: '#2A2F2A' })
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .onClick(() => {
              this.onSelectSample(sample);
            });
        }, (sample: string) => sample);
      }
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off);
  }

  build() {
    Column({ space: 16 }) {
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F8F1E5')
          .textAlign(TextAlign.Center)
          .lineHeight(42);

        Text(this.description)
          .fontSize(13)
          .fontColor('#A69A88')
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
          .fontColor('#F7EEE0')
          .placeholderColor('#7F786F')
          .backgroundColor('#161917')
          .borderRadius(22)
          .padding({ left: 18, right: 18 })
          .border({ width: 1, color: '#2D322D' })
          .onChange((value: string) => {
            this.onInputChange(value);
          });

        Button(this.isLoading ? '正在为你配酒...' : '开始推荐')
          .width('40%')
          .height(54)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .enabled(!this.isLoading)
          .fontColor('#241A10')
          .backgroundColor('#D4B181')
          .borderRadius(20)
          .onClick(() => {
            this.onSubmit();
          });
      }
      .width('88%')
      .constraintSize({ maxWidth: 680 });

      this.buildPromptSamples();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}

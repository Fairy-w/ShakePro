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
    Column({ space: 18 }) {
      Row() {
        Column({ space: 4 }) {
          Text('继续调整')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F7F0E4');

          Text('补充一点新偏好，再看一轮。')
            .fontSize(12)
            .fontColor('#A79984')
            .lineHeight(18);
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Button('先收起')
          .height(36)
          .fontSize(12)
          .fontColor('#D9C8AD')
          .backgroundColor('#151816')
          .borderRadius(14)
          .border({ width: 1, color: '#292D28' })
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
        .fontColor('#F7EEE0')
        .placeholderColor('#7F786F')
        .backgroundColor('#161917')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .border({ width: 1, color: '#2D322D' })
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
        .fontColor('#241A10')
        .backgroundColor('#D4B181')
        .borderRadius(18)
        .onClick(() => {
          this.onSubmit();
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 28 })
    .backgroundColor('#0F1210')
    .borderRadius({ topLeft: 28, topRight: 28, bottomLeft: 20, bottomRight: 20 })
    .border({ width: 1, color: '#232823' })
    .shadow({ radius: 24, color: '#00000055', offsetX: 0, offsetY: -8 });
  }
}

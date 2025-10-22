import promptAction from '@ohos.promptAction'

import router from '@ohos.router';

@Entry ({ routeName: 'Index' })
@Component
export struct LoginPage {
  //@Consume('pageStack') pageStack : NavPathStack
  @State account : string = '';
  @State password : string ='';
  @State isShowProgress: boolean = false;
  private timeOutId: number = -1;
  @State title: string = ''



  login() : void {
    if(this.account === '' || this.password === '') {
      promptAction.showToast({
        message: $r('app.string.input_empty_error')

      })
      return;
    }
    this.isShowProgress = true;
    if (this.timeOutId === -1) {
      this.timeOutId = setTimeout(()=>{
        this.isShowProgress = false;
        this.timeOutId = -1;
        router.replaceUrl({url:'pages/NavigationPage'});
      },3000);
    }

  }

  build() {

    Column() {

      Image($r('app.media.logo'))
        .width(150)
        .interpolation(ImageInterpolation.High)
      Text($r('app.string.login_screen'))
        .fontSize(30)
      Text($r('app.string.login_prompt'))
        .fontSize(15)
        .fontColor(Color.Gray)
      TextInput({ placeholder: $r('app.string.account') })
        .width('80%')
        .height(50)
        .onChange((value: string) => {
          this.account = value;
        })
      TextInput({ placeholder: $r('app.string.password') })
        .width('80%')
        .height(50)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })
      Row() {
        Text($r('app.string.sms_login'))
          .fontColor(Color.Blue)
          .fontSize(15)
          .padding(15)
        Text($r('app.string.forgot_password'))
          .fontColor(Color.Blue)
          .fontSize(15)
          .padding(15)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Button($r('app.string.login'))
        .width('70%')
        .margin({ top: 70 })
        .onClick(() => {
          this.login()
        })

      Text($r('app.string.register_account'))
        .fontColor(Color.Blue)
        .margin(10)

      // Row(){
      //   Button('方式一',{type:ButtonType.Circle})
      //     .backgroundColor('#B8B8B8')
      //     .fontSize(8)
      //     .borderRadius(30)
      //   Button('方式二',{type:ButtonType.Circle})
      //     .backgroundColor('#B8B8B8')
      //     .fontSize(8)
      //     .borderRadius(30)
      //   Button('方式三',{type:ButtonType.Circle})
      //     .backgroundColor('#B8B8B8')
      //     .fontSize(8)
      //     .borderRadius(30)
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.SpaceEvenly)
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)

    // }
    // // .onReady((callback) => {
    // //   this.title = callback.pathInfo.param as string
    // // })
  }
}





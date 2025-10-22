import { TransitionAnimationPage } from '../components/pages/TransitionAnimationPage';


@Entry ({ routeName: 'MyCocktail' })
@Component
struct MyCocktail {
  @State message: string = 'Hello World';

  build() {
    Column() {

      TransitionAnimationPage()

    }
    //.justifyContent(FlexAlign.End)
    .height('100%')
    .width('100%')
  }
}



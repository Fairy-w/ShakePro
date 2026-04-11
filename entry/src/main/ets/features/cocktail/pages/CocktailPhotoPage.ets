interface GoodItem{
  goods_name : string,
  goods_price : number,
  goods_img : Resource,
  goods_count : number,
  id : number
}


@Entry ({ routeName: 'PhotoPage' })
@Component
struct PhotoPage {
  @State message : string = '实现一个相册';
  @State List : GoodItem[] = [
    {
    goods_name : '白朗姆',
    goods_price: 80,
    goods_img:$r('app.media.choice_1'),
    goods_count:30,
    id:1
  },
    {
    goods_name : '伏特加',
    goods_price: 90,
    goods_img:$r('app.media.choice_2'),
    goods_count:30,
    id:2
    },
    {
      goods_name : '蓝橙力娇酒',
      goods_price: 80,
      goods_img:$r('app.media.choice_3'),
      goods_count:30,
      id:3
    },
    {
      goods_name : '白兰地',
      goods_price: 80,
      goods_img:$r('app.media.choice_4'),
      goods_count:30,
      id:4
    }
  ]
  @State isShowPhotoCom : boolean = false
  @State maxSelectNum : number =4
  @State showSelectImgs : GoodItem[] = []
  @State selectImage : ResourceStr | string = ''
  @State setlectIndex : number = 0
  preview: CustomDialogController = new CustomDialogController({
    builder: PreviewDilog({ url : this.showSelectImgs,selectIndex:this.setlectIndex}),
    customStyle:true
  })

  @Builder
  sheetBuilder(){
    Column(){
      PhotoCom({
        List:this.List,
        isShowPhotoCom:this.isShowPhotoCom,
        maxSelectNum:this.maxSelectNum,
        showSelectImgs:this.showSelectImgs
      })
    }

  }

  build() {
    Column(){
      Button('选择材料')
        .onClick(()=>{
          this.isShowPhotoCom=true
        })
      Grid(){
        ForEach(this.showSelectImgs,(item : GoodItem,index)=>{
          GridItem(){
            Image(item.goods_img)
              .aspectRatio(1)
              .onClick(()=>{
                this.selectImage=item.goods_img
                this.preview.open()
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(4)
      .rowsGap(4)

      // if(this.isShowPhotoCom){
      //   PhotoCom({
      //     List:this.List,
      //     isShowPhotoCom:this.isShowPhotoCom,
      //     maxSelectNum:this.maxSelectNum,
      //     showSelectImgs:this.showSelectImgs
      //   })
      //
      // }
    }
    .height('100%')
    .width('100%')
    .bindSheet(this.isShowPhotoCom,this.sheetBuilder,{
      showClose:false
    })

  }
}


@Component
struct PhotoCom {
  @Prop List : GoodItem[] = []
  @Link isShowPhotoCom : boolean
  @State selectList : GoodItem[] = []
  @Prop maxSelectNum : number
  @Link showSelectImgs : GoodItem[]

  //选择图片逻辑
  selectFn(item: GoodItem) {
    //查找是否存在与传入item具有相同id的元素，并将结果保存在Index中
    let Index = this.selectList.findIndex(obj => obj.id == item.id)
    //console打印出index的值，将其转换成JSON字符串格式
    console.log(JSON.stringify(Index))
    //判断是否存在
    if(Index > -1)//'> -1'即为有相同的元素，移除该元素
      this.selectList.slice(Index,1)
    else
      this.selectList.push(item)//否则将item添加到数组末尾
  }

  build() {
    Column(){
      Grid(){
        ForEach(this.List,(item : GoodItem,index)=>{
          GridItem(){
            Stack(){
              Image(item.goods_img)
                .aspectRatio(1)//设置组建的宽高比
              if(this.selectList.some(obj=> obj.id == item.id)) {
                Image($r('app.media.select'))
                  .width(60)
                  .width(60)
                  .fillColor(Color.Red)
              }
            }
            .onClick(()=>{
              this.selectFn(item)
            })

          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .layoutWeight(1)

      Row() {
        Button('取消')
          .onClick(()=>{
            this.isShowPhotoCom = false
          })
        Text(`已选${this.selectList.length}张/最多选${this.maxSelectNum}张`)
        Button('确认')
          .onClick(()=>{
            this.showSelectImgs = this.selectList
            this.isShowPhotoCom = false
          })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceAround)
    }
    //.position({x:0,y:0})
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)

  }

}

@CustomDialog
struct PreviewDilog {
  controller:CustomDialogController = new CustomDialogController({builder : CustomDialogController})
  url : GoodItem[] = []
  @Link selectIndex : number
  build() {
    Column(){
      Swiper(){
        ForEach(this.url,(item : GoodItem)=>{
          Image(item.goods_img)
            .width('100%')
        })
      }
      .loop(true)
      .index($$this.selectIndex)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    .onClick(()=>{
      this.controller.close()
    })
  }
}





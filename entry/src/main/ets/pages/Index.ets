import router from '@ohos.router'
import { InfoDialog } from '../view/InfoDialog'
@Entry
@Component
struct Index {
  dialog1: CustomDialogController = new CustomDialogController({
    builder: InfoDialog({})
  })

  build() {
    Column() {
      Blank()
      Blank()
      Blank()

      Column(){  // 按钮
        Button('双人对局', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(25)
          .fontColor('#ff000000')
          .borderRadius(12)
          .backgroundColor('#ffec9f28')
          .width(140)
          .height(50)
          .margin({bottom:20})
          .onClick(()=> {
            router.pushUrl({
              url: 'pages/local'
            }, router.RouterMode.Single, (err) => {
              if (err) {
                console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke pushUrl succeeded.');
            })
          })

        Button('人机对战', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(25)
          .fontColor('#ff000000')
          .borderRadius(12)
          .backgroundColor('#ffec9f28')
          .width(140)
          .height(50)
          .margin({bottom:20})
          .onClick(()=> {
            router.pushUrl({
              url: 'pages/AI'
            }, router.RouterMode.Single, (err) => {
              if (err) {
                console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke pushUrl succeeded.');
            })
          })

        Button('小游戏', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(25)
          .fontColor('#ff000000')
          .borderRadius(12)
          .backgroundColor('#ffec9f28')
          .width(140)
          .height(50)
          .margin({bottom:20})
          .onClick(()=> {
            router.pushUrl({
              url: 'pages/LittleGame'
            }, router.RouterMode.Single, (err) => {
              if (err) {
                console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke pushUrl succeeded.');
            })
          })

        Button('关于作者', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(25)
          .fontColor('#ff000000')
          .borderRadius(12)
          .backgroundColor('#ffec9f28')
          .width(140)
          .height(50)
          .margin({bottom:20})
          .onClick(()=>{
            this.dialog1.open()
          })
      }

      Blank()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImageSize({width:'100%',height:'100%'})
    .backgroundImage($rawfile('bg0.png'))
    // .backgroundImage($r('app.media.bg'))
    .width('100%')
    .height('100%')
  }
}
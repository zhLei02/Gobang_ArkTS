import { GameController } from '../data/GameController'
import { GameDataSource } from '../data/GameDataSource'
import { ColorUtil } from '../view/Color'
@Entry
@Component
struct LittleGame {
  @State flatCellArr: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State @Watch('stronger') score:number = 0
  @State maxScore:number = 0
  private gameController: GameController = new GameController()
  private data:GameDataSource = new GameDataSource(this.flatCellArr)
  private colorUtil: ColorUtil = new ColorUtil()
  @State @Watch("onGameOver") isGameOver: boolean = false
  Timer: TextTimerController = new TextTimerController()
  @State format: string = 'HH:mm:ss'
  gameOverDialogController: CustomDialogController = new CustomDialogController({
    builder: GameOverView({
      startGame: this.startGame.bind(this),
      score:this.score
    }),
    autoCancel: false
  })

  stronger(){
    if(this.maxScore<this.score){
      this.maxScore=this.score
    }
  }

  onGameOver() {
    this.Timer.pause()
    if (this.isGameOver === true) {
      this.gameOverDialogController.open()
    }
  }

  startGame() {
    this.Timer.reset()
    this.Timer.start()
    this.flatCellArr = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    this.gameController.init(this.flatCellArr)
    this.flatCellArr = this.gameController.getFlatCellArr()
    this.score = this.gameController.getSum()
    this.data.update(this.flatCellArr)
    this.isGameOver = false
  }

  moveUp() {
    this.gameController.moveUp()
    this.updateCells()
  }

  moveDown() {
    this.gameController.moveDown()
    this.updateCells()
  }

  moveLeft() {
    this.gameController.moveLeft()
    this.updateCells()
  }

  moveRight() {
    this.gameController.moveRight()
    this.updateCells()
  }

  updateCells() {
    this.flatCellArr = this.gameController.getFlatCellArr()
    this.score = this.gameController.getSum()
    this.isGameOver = this.gameController.isGameOver
  }

  aboutToAppear() {
    this.startGame()
  }



  build() {
    Column() {
      Blank()
      Row(){
        Blank()
        Column(){
          Text('总用时')
            .textAlign(TextAlign.Center)
            .fontSize(28)
            .fontColor('#fff8f8f8')
          TextTimer({ isCountDown: false, count: 0, controller: this.Timer })
            .format(this.format)
            .fontColor(Color.White)
            .fontSize(35)
        }
        Blank()
      }
      .width('100%')
      .margin({bottom:30})
      Row(){
        Text('总得分：'+this.score)
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor('#ee030101')
          .borderRadius(10)
          .padding({left:10,right:10,top:5,bottom:5})
          .backgroundColor('#ff17f7ff')
        Blank()
        Text('历史最高：'+this.maxScore)
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor('#ee030101')
          .borderRadius(10)
          .padding({left:10,right:10,top:5,bottom:5})
          .backgroundColor('#ff01fdcb')
      }
      .width('90%')
      .margin({bottom:30})
      Row() {
        Grid() {
          LazyForEach(this.data, (item) => {
            GridItem() {
              Text(`${item === 0 ? '' : item}`)
                .fontSize('85px')
                .fontColor(item <= 4 ? '#000' : '#fcf8f5')
                .fontWeight(FontWeight.Bolder)
                .backgroundColor('#f0fff0')
                .width('100%')
                .height('100%')
                .textAlign(TextAlign.Center)
                .borderRadius(10)
                .backgroundColor(this.colorUtil.getCellBackgroundColor(item))
            }
          },item=>item+this.data.totalCount()+Math.random())
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width(px2vp(1080))
        .padding(10)
        .backgroundColor('rgba(139, 222, 147, 0.26)') //rgba(80,69,46,0.26)
        .height(px2vp(1080))
        .borderRadius(10)
        .onAppear(()=>{
          this.Timer.start()
        })
        .gesture(GestureGroup(GestureMode.Exclusive,
          PanGesture({ direction: PanDirection.Left }).onActionEnd(() => {
            this.moveLeft()
            this.data.update(this.flatCellArr)
            // console.log('测试',this.score)
          }),
          PanGesture({ direction: PanDirection.Right }).onActionEnd(() => {
            this.moveRight()
            this.data.update(this.flatCellArr)
            // console.log('测试',this.score)
          }),
          PanGesture({ direction: PanDirection.Up }).onActionEnd(() => {
            this.moveUp()
            this.data.update(this.flatCellArr)
            // console.log('测试',this.score)
          }),
          PanGesture({ direction: PanDirection.Down }).onActionEnd(() => {
            this.moveDown()
            this.data.update(this.flatCellArr)
            // console.log('测试',this.score)
          })
        ))
      }
      .justifyContent(FlexAlign.Center)
      .height('50%')
      .width('100%')
      Button('重新开始', { type: ButtonType.Normal, stateEffect: true })
        .fontSize(25)
        .fontColor('#ff000000')
        .borderRadius(12)
        .backgroundColor('#ff10fcb1')
        .width(140)
        .height(50)
        .margin({top:20})
        .onClick(()=> {
          this.startGame()
        })
      Blank()
    }
    .backgroundImage($rawfile('bg2.png'))
    .backgroundImageSize({width:'100%',height:'100%'})
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }
}

@CustomDialog
@Preview
struct GameOverView {
  controller: CustomDialogController
  startGame: () => void
  @Prop score: number
  build() {
    Column() {
      Text('游戏结束')
        .fontSize(30)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10 })
      Text('最终得分为:' + this.score + ' !!')
        .fontSize(30)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Red)
        .margin({ top: 10 })

      Row() {
        Button('重新开始', { type: ButtonType.Normal })
          .borderRadius(5)
          .margin({ top: 10,left:10,right:10 })
          .width(200)
          .onClick(() => {
            this.startGame()
            this.controller.close()
          })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 10, bottom: 10 })
    }
    .width(300)
    .borderRadius(25)
  }
}
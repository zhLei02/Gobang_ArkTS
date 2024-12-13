import router from '@ohos.router';
import { Chess } from '../view/Chess';
import { ChessController } from '../view/ChessController';
import { ConfirmDialog } from '../view/ConfirmDialog';
@Entry
@Component
struct Local {
  private states :string[]= ['游戏未开始','黑棋','白棋','游戏已结束'];
  @State @Watch('moving') now: number = 0 // 现在移动的棋子类型
  @State state: string = this.states[this.now]
  @State type: number[][] = []
  @State cellSize: number = 22
  @State boardSize: number = 15
  @State dirty: number = 0
  Black_Timer: TextTimerController = new TextTimerController()
  White_Timer: TextTimerController = new TextTimerController()
  @State format: string = 'mm:ss.SS'
  private ChessController: ChessController = new ChessController()
  dialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      cancel: ()=>{},
      confirm: ()=>{
        this.ChessController.clearChess()
        this.ChessController.clearChessHis()
        this.dirty = 0
        this.now = 3
        this.state = this.states[this.now]
        this.Black_Timer.reset()
        this.White_Timer.reset()
      },
      // stop:()=>{
      //   this.Black_Timer.pause()
      //   this.White_Timer.pause()
      // }
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })

  private moving(){
    if(this.now==1){
      this.Black_Timer.start()
      this.White_Timer.pause()
    } else if(this.now == 2){
      this.Black_Timer.pause()
      this.White_Timer.start()
    } else if(this.now==3){
      this.Black_Timer.pause()
      this.White_Timer.pause()
    } else{
      this.Black_Timer.reset()
      this.White_Timer.reset()
    }
  }

  build() {
    Column() {
      Blank()
      Row(){
        Column(){
          Text('黑棋用时')
            .textAlign(TextAlign.Center)
            .fontSize(28)
            .fontColor('#fff8f8f8')
          TextTimer({ isCountDown: false, count: 0, controller: this.Black_Timer })
            .format(this.format)
            .fontColor(Color.White)
            .fontSize(35)
        }.width('50%')
        Column(){
          Text('白棋用时')
            .textAlign(TextAlign.Center)
            .fontSize(28)
            .fontColor('#fff8f8f8')
          TextTimer({ isCountDown: false, count: 0, controller: this.White_Timer })
            .format(this.format)
            .fontColor(Color.White)
            .fontSize(35)
        }.width('50%')
      }
      .width('100%')
      .margin({bottom:30})
      Row(){
        Text('正在行动：'+this.state)
          .width('90%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor('#ee030101')
          .borderRadius(10)
          .padding({left:10,right:10,top:5,bottom:5})
          .backgroundColor('#ffeca44b')
      }

      Chess({controller:this.ChessController,cellSize:$cellSize,boardSize:$boardSize,
        now:$now,state:$state,dirty:$dirty}) // 棋盘
        .margin({top:10,bottom:10})

      Row(){
        Button(this.dirty==1?'清空棋盘':this.now==0||this.now==3?'开始游戏':'结束游戏',
          { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#ffeca44b')
          .fontColor('#ee030101')
          .width(120)
          .height(40)
          .fontSize(20)
          .margin({right:16})
          .onClick(()=>{
            if(this.dirty == 0){
              if(this.now == 0 || this.now == 3){
                this.now=1
                this.state = this.states[this.now]
              } else{
                this.dialog.open()
              }
            } else {
              this.dialog.open()
            }
          })
        Button('悔棋', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#ffeca44b')
          .fontColor('#ee030101')
          .width(80)
          .height(40)
          .fontSize(20)
          .margin({right:16})
          .onClick(()=>{
            this.ChessController.undoMove()
            this.dirty = 0
          })
        Button('返回', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#ffeca44b')
          .fontColor('#ee030101')
          .width(80)
          .height(40)
          .fontSize(20)
          .onClick(()=>{
            router.back()
          })
      }.margin({left:10,right:10})
      Blank()
    }
    .backgroundImage($rawfile('bg.png'))
    .backgroundImageSize({ width:'100%',height:'100%' })
    .width('100%')
    .height('100%')
  }
}
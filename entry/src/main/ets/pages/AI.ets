import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Chess } from '../view/Chess';
import { ChessController } from '../view/ChessController';
import { ChooseDialog } from '../view/ChooseDialog';
import { ConfirmDialog } from '../view/ConfirmDialog';
@Entry
@Component
struct AI {
  private states :string[]= ['游戏未开始','黑棋','白棋','游戏已结束'];
  private chessType: string[]= ['尚未选择','黑棋','白棋']
  @State now: number = 0 // 现在移动的棋子类型
  @State state: string = this.states[this.now]
  @State type: number[][] = []
  @State cellSize: number = 22
  @State boardSize: number = 15
  @State You: number = 0 // 玩家棋子类型
  @State yourChess: string = this.chessType[this.You]
  @State dirty: number = 0
  private Ai:number = 0
  private ChessController: ChessController = new ChessController()
  dialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      cancel: ()=>{},
      confirm: ()=>{
        this.ChessController.clearChess()
        this.ChessController.clearChessHis()
        this.now = 3
        this.dirty = 0
        this.state = this.states[this.now]
      },
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  }) // 弹窗选择是否结束游戏并清空棋盘
  dialogChoose: CustomDialogController = new CustomDialogController({
    builder: ChooseDialog({
      white: ()=>{
        this.Ai = 1 // 人选择白棋，则ai为黑棋
        this.You = 2
        this.yourChess = this.chessType[this.You]
        this.ChessController.AiChoose(this.Ai)
      },
      black: ()=>{
        this.Ai = 2
        this.You = 1
        this.yourChess = this.chessType[this.You]
        this.ChessController.AiChoose(this.Ai)
      },
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  }) // 弹窗选择棋子类型

  build() {
    Column() {
      Blank()
      Row(){
        Text('您的棋子类型为：'+ this.yourChess)
          .width('90%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor('#ee030101')
          .borderRadius(10)
          .padding({left:10,right:10,top:5,bottom:5})
          .backgroundColor('#ffeca44b')
      }

      Row(){
        Text('正在行动：'+this.state)
          .width('90%')
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor('#ee030101')
          .borderRadius(10)
          .padding({left:10,right:10,top:5,bottom:5})
          .backgroundColor('#ffeca44b')
      }.margin({top:10})

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
            if(this.Ai == 0){
              // 弹窗提示选择棋子类型
              promptAction.showToast({
                message: '请先选择您的棋子类型!',
                duration: 2000,
              });
            } else{
              // 询问是否结束游戏，清空棋盘，并将ai置0
              if(this.dirty == 0){
                if(this.now == 0 || this.now == 3){ // 开始游戏
                  this.now=1
                  this.state = this.states[this.now]
                  if(this.now==this.Ai){
                    this.ChessController.AiMove()
                  }
                } else{ // 结束游戏
                  this.dialog.open()
                }
              } else{
                this.dialog.open()
              }
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
            this.dirty = 0
            this.ChessController.undoMove()
            // ai模式悔棋需做两次undo
            this.ChessController.undoMove(1)
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
      Row(){
        Button('选棋', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#ffeca44b')
          .fontColor('#ee030101')
          .width(120)
          .height(40)
          .fontSize(20)
          .margin({right:16})
          .onClick(()=>{
            if(this.now==1||this.now==2||this.dirty==1){
              // 弹窗提示请先结束游戏
              promptAction.showToast({
                message: '请先结束游戏!',
                duration: 2000,
              });
            } else{
              // 弹窗选择棋子类型
              this.dialogChoose.open()
            }
          })
      } // 选择棋子按钮
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({left:10,right:10,top:10})
      Blank()
    }
    .backgroundImage($rawfile('bg.png'))
    .backgroundImageSize(ImageSize.Cover)
    .width('100%')
    .height('100%')
  }
}
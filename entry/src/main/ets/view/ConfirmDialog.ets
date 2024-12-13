@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void
  over: number
  // stop:()=>void
  //
  // aboutToAppear(){
  //   this.stop()
  // }

  build() {
    Column() {
      if(this.over == 1){
        Text('游戏结束！！黑棋胜利！！').fontSize(20).margin({ top: 10, bottom: 10 })
        Text('您需要清空棋盘吗?').fontSize(20).margin({ top: 10, bottom: 10 })
      } else if(this.over ==2){
        Text('游戏结束！！白棋胜利！！').fontSize(20).margin({ top: 10, bottom: 10 })
        Text('您需要清空棋盘吗?').fontSize(20).margin({ top: 10, bottom: 10 })
      } else{
        Text('您确定要结束游戏吗?').fontSize(20).margin({ top: 10, bottom: 10 })
      }
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确定')
          .onClick(() => {
            this.controller.close()
            this.confirm()
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }
  }
}
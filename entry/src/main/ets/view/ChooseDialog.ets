@CustomDialog
export struct ChooseDialog {
  controller: CustomDialogController
  white: () => void
  black: () => void
  build() {
    Column() {
      Text('请选择你的棋子类型：').fontSize(20).margin({ top: 10, bottom: 10 })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('白棋')
          .onClick(() => {
            this.controller.close()
            this.white()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('黑棋')
          .onClick(() => {
            this.controller.close()
            this.black()
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }
  }
}
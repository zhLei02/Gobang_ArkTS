

@CustomDialog
@Preview
export struct InfoDialog {
  controller: CustomDialogController
  build() {
    Column() {
      Text('关于作者').fontSize(30).margin({ top: 10, bottom: 10 })

      Text('作者：20215164 雷子豪').fontSize(20).margin({ bottom: 5 })

      Text('邮箱：2306162178@qq.com').fontSize(20).margin({ bottom: 5 })

      Text('如有问题请通过邮箱联系作者').fontSize(20).margin({ bottom: 10 })

      Button('关闭')
        .onClick(() => {
          this.controller.close()
        })
        .backgroundColor(0xffffff)
        .fontColor(Color.Black)
        .width('80%')
    }
    .alignItems(HorizontalAlign.Center)
    .width(400)
  }
}
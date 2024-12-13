import MinMaxNode from '../data/MinmaxNode';
import { ChessController } from './ChessController';
import { ConfirmDialog } from './ConfirmDialog';
@Component
export struct Chess {
  controller: ChessController = null
  @Link cellSize: number; // 格子大小
  @Link boardSize: number; // 行列数
  @Link now: number; // 现在到谁
  @Link state: string;
  @Link dirty: number; // 结束后棋盘是否还有棋子未清理
  private ai:number = 0; // ai的棋子类型
  private You: number = 0; // 玩家棋子类型
  private states :string[]= ['游戏未开始','黑棋','白棋','游戏已结束'];
  private chessBoard: number[][] = [] // 记录棋盘对应位置的棋子
  private posHis: number[][] = [] // 记录下棋历史
  private openList: number[][] = [] // 记录ai可以下的位置集合（仅遍历已经下过棋子的周围选择最佳棋子放置位置）
  private downPos: number[] = [] // 按下的位置（行，列）
  private downX: number; // 按下位置的横坐标
  private downY: number; // 按下位置的纵坐标

  // 用于ai
  private AttackMap: Map<string, number> = new Map();
  private DefendMap: Map<string, number> = new Map();
  // private shape_score:number[] = [0,1,20,600,4000,1000000]
  // private tuples: { [index: number]: number[] } = {}; // 存储包含每个位置的五元组的索引

  // 用于绘制棋盘背景
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  // 用于绘制棋子
  private settingsChess: RenderingContextSettings = new RenderingContextSettings(true);
  private contextChess: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settingsChess);
  // 弹窗
  dialogBlack: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      cancel: ()=>{
        this.dirty = 1
        this.now = 3
        this.state = this.states[this.now]
      },
      confirm: ()=>{
        this.clear()
        this.clearHis()
        this.now = 0
        this.state = this.states[this.now]
      },
      over: 1,
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
    autoCancel:false
  }) // 黑棋胜利
  dialogWhite: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      cancel: ()=>{
        this.dirty = 1
        this.now = 3
        this.state = this.states[this.now]
      },
      confirm: ()=>{
        this.clear()
        this.clearHis()
        this.now = 0
        this.state = this.states[this.now]
      },
      over: 2,
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
    autoCancel:false
  }) // 白棋胜利

  aboutToAppear(){
    if(this.controller){
      this.controller.attach(this)
    }
    this.initValue(this.AttackMap,this.DefendMap)
    // this.initAllTuples()
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .margin({left:6,top:6})
        .onReady(() => {
          this.initChessBoard();
          // 绘制五子棋棋盘
          this.drawChessboard();
          // 绘制特殊点
          this.drawSpecialPoints();
        })
      Canvas(this.contextChess)
        .margin({left:6,top:6})
        .width('100%')
        .height('100%')
        .onTouch((event)=>{
          if(this.now!=0&&this.now!=3){ // 游戏已开始
            switch (event.type){
              case TouchType.Down:
                this.downX = event.touches[0].x - this.cellSize/2
                this.downY = event.touches[0].y - this.cellSize/2
                let row:number = Math.round(this.downX/this.cellSize)
                let col:number = Math.round(this.downY/this.cellSize)
                if (row<0||row>=15||col<0||col>=15){
                  break
                }
                if(this.ai==0||(this.ai!=0&&this.now!=this.ai)){ // 没有设置ai或者设置了ai但是现在到人下
                  if(this.chessBoard[row][col]==0) {
                    this.downPos = [row,col]
                    this.drawChess(row, col, this.now, 1)
                  }
                }
                break
              case TouchType.Up:
                let offsetX = this.downX - event.touches[0].x
                let offsetY = this.downY - event.touches[0].y
                if(Math.abs(offsetX)<=this.cellSize*2&&Math.abs(offsetY)<=this.cellSize*2){ // 在范围内，下棋子
                  let row:number = Math.round(this.downX/this.cellSize)
                  let col:number = Math.round(this.downY/this.cellSize)
                  if (row<0||row>=15||col<0||col>=15){
                    return
                  }
                  if(this.ai==0||(this.ai!=0&&this.now!=this.ai)){ // 没有设置ai或者设置了ai但是现在到人下
                    if(this.chessBoard[row][col]==0){
                      // console.log('测试','需要落子,落子点位为'+row+', '+col)
                      this.chessBoard[row][col] = this.now // 更新棋盘
                      // this.extend_openList(this.chessBoard,this.openList,row,col)
                      this.posHis.push([row,col]) // 记录下棋历史
                      this.drawChess(row,col,this.now) // 画棋子
                      let end = this.check(row,col,this.now) // 检查是否结束
                      if (end!=0){
                        // console.log('测试','游戏结束!'+this.states[end]+'赢了!')
                        if(end == 1){
                          this.dialogBlack.open()
                        } else{
                          this.dialogWhite.open()
                        }
                      } // 游戏结束，打开对应弹窗
                      this.now = this.now==1?2:1 // 更换下棋选手
                      this.state = this.states[this.now]
                      if(end!=0){
                        break
                      } // 游戏结束，不用判断ai动不动了
                      if(this.ai == this.now){
                        this.aiMove()
                      } // 到 ai 动了，调用函数 this.aiMove()
                    }
                  }
                }
                else{ // 超出范围，将临时棋子擦掉
                  this.noDo()
                }
                break
            }
          }
        })
    }
    .backgroundColor('#F5DC62')
    .borderRadius(5)
    .width('95%')
    .height('50%')
  }

  private initChessBoard(){
    // 初始化棋盘数组
    for (let i = 0; i < this.boardSize; i++) {
      this.chessBoard[i] = [];
      for (let j = 0; j < this.boardSize; j++) {
        this.chessBoard[i][j] = 0;
      }
    }
  } // 初始化棋盘

  private drawChessboard() {
    const cellSize = this.cellSize; // 每个格子的大小
    const boardSize = this.boardSize; // 棋盘的大小

    // // 绘制棋盘背景
    // this.context.fillStyle = '#F5DC62';
    // this.context.fillRect(0, 0, cellSize * boardSize, cellSize * boardSize);

    // 绘制棋盘线条
    this.context.strokeStyle = '#000000';
    this.context.lineWidth = 1.5;

    for (let i = 0; i < boardSize; i++) {
      // 绘制横线
      this.context.beginPath();
      this.context.moveTo(cellSize/2, i * cellSize+cellSize/2);
      this.context.lineTo(cellSize * (boardSize - 1) + cellSize/2, i * cellSize+cellSize/2);
      this.context.stroke();

      // 绘制竖线
      this.context.beginPath();
      this.context.moveTo(i * cellSize+cellSize/2, cellSize/2);
      this.context.lineTo(i * cellSize+cellSize/2, cellSize * (boardSize - 1) + cellSize/2);
      this.context.stroke();
    }
  } // 画棋盘

  private drawSpecialPoints() {
    const cellSize = this.cellSize; // 每个格子的大小

    // 绘制特殊点
    this.context.fillStyle = '#000000';

    // 绘制四个星位
    const starPoints = [
      [3, 3],
      [3, 11],
      [11, 3],
      [11, 11]
    ];

    for (const [x, y] of starPoints) {
      const centerX = x * cellSize + cellSize/2;
      const centerY = y * cellSize + cellSize/2;
      const radius = 5;

      this.context.beginPath();
      this.context.arc(centerX, centerY, radius, 0, 2 * Math.PI);
      this.context.fill();
    }

    // 绘制天元点
    {
      const centerPoint = [7, 7];
      const centerX = centerPoint[0] * cellSize + cellSize/2;
      const centerY = centerPoint[1] * cellSize + cellSize/2;
      const radius = 4;

      this.context.beginPath();
      this.context.arc(centerX, centerY, radius, 0, 2 * Math.PI);
      this.context.fill();
    }
  } // 画特殊点

  private drawChess(row,col,type,tmp=0){
    // 绘制棋子
    // 位置
    const centerX = row * this.cellSize + this.cellSize/2;
    const centerY = col * this.cellSize + this.cellSize/2;
    // 大小
    const radius = this.cellSize / 2;
    // 颜色
    this.contextChess.fillStyle = type==1 ? '#ff000000' : '#ffffffff';
    if(tmp){ // 临时棋子 半透明显示
      this.contextChess.fillStyle = type==1 ? '#7a000000' : '#7affffff'
    }
    this.contextChess.beginPath();
    this.contextChess.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    this.contextChess.fill();
  } // 画棋子

  private check(row,col,type){
    // 记录原位置
    let rowN = row
    let colN = col

    // 判断竖直方向是否有
    {
      let cnt = 1
      row = rowN-1
      col = colN
      while(row>=0&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        row--
      }
      row = rowN+1
      while(row<=14&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        row++
      }
    }

    // 判断水平方向是否有
    {
      let cnt = 1
      col = colN-1
      row = rowN
      while(col>=0&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col--
      }
      col = colN+1
      while(col<=14&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col++
      }
    }

    // 判断左上到右下
    {
      let cnt = 1
      col = colN-1
      row = rowN-1
      while(col>=0&&row>=0&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col--
        row--
      }
      col = colN+1
      row = rowN+1
      while(row<=14&&col<=14&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col++
        row++
      }
    }

    // 判断左下到右上
    {
      let cnt = 1
      col = colN-1
      row = rowN+1
      while(col>=0&&row<=14&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col--
        row++
      }
      col = colN+1
      row = rowN-1
      while(row>=0&&col<=14&&this.chessBoard[row][col]==type){
        cnt++
        if(cnt == 5){
          return type
        }
        col++
        row--
      }
    }

    return 0
  } // 检测是否游戏结束

  public clear(){
    // 清空棋盘
    for (let i = 0; i < this.boardSize; i++) {
      for (let j = 0; j < this.boardSize; j++) {
        this.chessBoard[i][j] = 0;
      }
    }

    // 清空画布
    this.contextChess.clearRect(0, 0,
      this.cellSize * (this.boardSize - 1) + this.cellSize,
      this.cellSize * (this.boardSize - 1) + this.cellSize);
  } // 清空棋盘

  public clearHis(){
    this.posHis=[]
    this.openList = []
    if(this.ai == 1){
      // ai为黑棋
      this.openList.push([7,7]) // 将最中间的点加入选择范围
    }
  } // 清空下棋历史

  public undo(type = 0) {
    /*     type变量用于区别第一次还是第二次。
     当人机对战时，悔棋需连续两次，第二次赋为1（用于解决ai为黑棋时清空棋盘黑棋不下的问题）
     */
    if (this.posHis.length > 0) {
      const [row, col] = this.posHis.pop();
      // this.extend_openList(row,col)
      this.chessBoard[row][col] = 0;
      this.contextChess.clearRect(
        row * this.cellSize,
        col * this.cellSize,
        this.cellSize,
        this.cellSize
      );
      if(this.now == 3){
        this.now = this.posHis.length%2 == 0 ? 1:2 // 剩余棋子为偶数，则到黑棋下
      } else{
        this.now = this.now === 1 ? 2 : 1;
      }
      this.state = this.states[this.now];
    }
    if(type&&this.now==this.ai){
      this.aiMove()
    }
  } // 悔棋

  private noDo(){
    const [row, col] = this.downPos;
    this.contextChess.clearRect(
      row * this.cellSize,
      col * this.cellSize,
      this.cellSize,
      this.cellSize
    );
    this.downPos = []
  } // 删除临时下的棋子

  public aiUpdate(player:number){
    this.ai = player
    this.You = this.ai == 1 ? 2:1
    this.openList = []
    if(this.ai == 1){
      // ai为黑棋
      this.openList.push([7,7]) // 将最中间的点加入选择范围
    }
  } // 更新ai棋子类型

  // 获取ai应走的位置，并下棋，检测是否结束等相关操作
  public aiMove(){ // ai移动

    // let [oRow,oCol]=[7,7]
    // if(this.posHis.length>1){
    //   [oRow,oCol] = this.posHis[this.posHis.length-1]
    // }
    // const pos = this.makeMove(oRow,oCol);
    // let row = Math.floor(pos/this.boardSize)
    // let col = pos%this.boardSize
    let [row,col] = this.getNextMove(this.chessBoard,this.AttackMap,this.DefendMap)
    this.chessBoard[row][col] = this.now // 更新棋盘
    // this.extend_openList(this.chessBoard,this.openList,row,col)
    this.posHis.push([row,col]) // 记录下棋历史
    this.drawChess(row,col,this.now) // 画棋子
    let end = this.check(row,col,this.now) // 检查是否结束
    if (end!=0){
      console.log('测试','游戏结束!'+this.states[end]+'赢了!')
      if(end == 1){
        this.dialogBlack.open()
      } else{
        this.dialogWhite.open()
      }
    }
    this.now = this.now==1?2:1
    this.state = this.states[this.now]
  }

  // 以下为ai算法  待优化
  // private extend_openList(board:number[][],openList:number[][],row:number, col:number):number[][]  {
  //   // 查看可放置点中是否存在该点，若存在，则将该点删除
  //   let index = openList.indexOf([row,col])
  //   if(index!=-1){
  //     openList.splice(index,1)
  //   }
  //   // 将该点的邻居节点加入list中
  //   let dRow = [-1,-1,-1,0,0,0,1,1,1]
  //   let dCol = [-1,0,1,-1,0,1,-1,0,1]
  //   for(let i = 0;i<9;i++){
  //     let nRow = row + dRow[i]
  //     let nCol = col + dCol[i]
  //     // 邻点坐标为 (nRow,nCol) 其中包含了自己，用于在悔棋时调用，将该棋子仍纳入考虑范围
  //     if(nRow>=0&&nRow<this.boardSize&&nCol>=0&&nCol<this.boardSize){ // 在范围内
  //       if(board[nRow][nCol]==0){ // 没有棋子
  //         openList.push([nRow,nCol])
  //       }
  //     }
  //   }
  //   return openList
  // } // 扩展可下旗位置
  //
  // private initPos(){
  //   for(let i =0;i<this.openList.length;i++){
  //     let move = this.openList[i]
  //     if(this.chessBoard[move[0]][move[1]]==0){
  //       return move
  //     }
  //   }
  // } // 找到一个可下的位置
  //
  // private makeMove(row:number,col:number){
  //   const Node = new MinMaxNode(this.ai, row*this.boardSize+col);
  //   this.MinMax_v1(3,Node,-Infinity,Infinity)
  //   return Node.next_best
  // }
  //
  // private oppositeChessType(chessType:number){
  //   if(chessType==1){
  //     return 2
  //   } else{
  //     return 1
  //   }
  // }
  //
  // private tupleEvaluate(chessType: number, tuple: number[],board:number[][]=this.chessBoard): number {
  //   let n = 0;
  //   for (let i = 0; i < 5; i++) {
  //     const [row, col] = [Math.floor(tuple[i] / this.boardSize), tuple[i] % this.boardSize];
  //     if (board[row][col] === chessType) {
  //       n++;
  //     } else if (board[row][col] === this.oppositeChessType(chessType)) {
  //       n = 0;
  //       break;
  //     }
  //   }
  //   return this.shape_score[n];
  // }
  //
  // private evaluatePosition(chessType: number, row: number, col: number): number { // 评估该点的评分
  //   let score = 0;
  //   let boardSize = this.boardSize
  //   // 水平线
  //   const horizontalTuple = [row * boardSize + col - 2, row * boardSize + col - 1, row * boardSize + col, row * boardSize + col + 1, row * boardSize + col + 2];
  //   score += this.tupleEvaluate(chessType, horizontalTuple);
  //
  //   // 垂直线
  //   const verticalTuple = [(row - 2) * boardSize + col, (row - 1) * boardSize + col, row * boardSize + col, (row + 1) * boardSize + col, (row + 2) * boardSize + col];
  //   score += this.tupleEvaluate(chessType, verticalTuple);
  //
  //   // 主对角线
  //   const mainDiagonalTuple = [(row - 2) * boardSize + col - 2, (row - 1) * boardSize + col - 1, row * boardSize + col, (row + 1) * boardSize + col + 1, (row + 2) * boardSize + col + 2];
  //   score += this.tupleEvaluate(chessType, mainDiagonalTuple);
  //
  //   // 副对角线
  //   const subDiagonalTuple = [(row - 2) * boardSize + col + 2, (row - 1) * boardSize + col + 1, row * boardSize + col, (row + 1) * boardSize + col - 1, (row + 2) * boardSize + col - 2];
  //   score += this.tupleEvaluate(chessType, subDiagonalTuple);
  //
  //   return score;
  // }
  //
  // private initAllTuples() {
  //   let boardSize = this.boardSize
  //   // 遍历棋盘，构建五元组索引
  //   for (let row = 0; row < boardSize; row++) {
  //     for (let col = 0; col < boardSize; col++) {
  //       if (!this.tuples[row * boardSize + col]) {
  //         this.tuples[row * boardSize + col] = [];
  //       }
  //
  //       // 水平线
  //       if (col + 4 < boardSize) {
  //         const horizontalTuple = [row * boardSize + col, row * boardSize + col + 1, row * boardSize + col + 2, row * boardSize + col + 3, row * boardSize + col + 4];
  //         const index = this.fiveTupleIndex(horizontalTuple);
  //         this.tuples[row * boardSize + col].push(index);
  //         this.tuples[(row * boardSize + col + 4)].push(index);
  //       }
  //
  //       // 垂直线
  //       if (row + 4 < boardSize) {
  //         const verticalTuple = [row * boardSize + col, (row + 1) * boardSize + col, (row + 2) * boardSize + col, (row + 3) * boardSize + col, (row + 4) * boardSize + col];
  //         const index = this.fiveTupleIndex(verticalTuple);
  //         this.tuples[row * boardSize + col].push(index);
  //         this.tuples[((row + 4) * boardSize + col)].push(index);
  //       }
  //
  //       // 主对角线
  //       if (row + 4 < boardSize && col + 4 < boardSize) {
  //         const mainDiagonalTuple = [row * boardSize + col, (row + 1) * boardSize + col + 1, (row + 2) * boardSize + col + 2, (row + 3) * boardSize + col + 3, (row + 4) * boardSize + col + 4];
  //         const index = this.fiveTupleIndex(mainDiagonalTuple);
  //         this.tuples[row * boardSize + col].push(index);
  //         this.tuples[((row + 4) * boardSize + col + 4)].push(index);
  //       }
  //
  //       // 副对角线
  //       if (row + 4 < boardSize && col - 4 >= 0) {
  //         const subDiagonalTuple = [row * boardSize + col, (row + 1) * boardSize + col - 1, (row + 2) * boardSize + col - 2, (row + 3) * boardSize + col - 3, (row + 4) * boardSize + col - 4];
  //         const index = this.fiveTupleIndex(subDiagonalTuple);
  //         this.tuples[row * boardSize + col].push(index);
  //         this.tuples[((row + 4) * boardSize + col - 4)].push(index);
  //       }
  //     }
  //   }
  // }
  //
  // private fiveTupleIndex(fiveTuple): number {
  //   return (fiveTuple[0] << 8) + fiveTuple[4];
  // }
  //
  // private total_evaluate(chessType:number){
  //   let selfScore = 0;
  //   let opponentScore = 0;
  //   let boardSize = this.boardSize
  //   // 遍历五元组索引，计算评分
  //   for (const position in this.tuples) {
  //     const row = Math.floor(Number(position) / boardSize);
  //     const col = Number(position) % boardSize;
  //
  //     for (const index of this.tuples[position]) {
  //       const fiveTuple = this.fiveTupleFromIndex(index);
  //       const score = this.tupleEvaluate(chessType, fiveTuple);
  //
  //       if (chessType === this.ai) {
  //         selfScore += score;
  //       } else {
  //         opponentScore += score;
  //       }
  //     }
  //   }
  //   return selfScore-opponentScore
  // }
  //
  // private fiveTupleFromIndex(index: number) {
  //   let boardSize = this.boardSize
  //   const row = Math.floor(index / boardSize);
  //   const col = index % boardSize;
  //   return [row * boardSize + col, row * boardSize + col + 1, row * boardSize + col + 2, row * boardSize + col + 3, row * boardSize + col + 4];
  // }
  //
  // private MinMax_v1(depth: number, node: MinMaxNode, alpha: number, beta: number): void {
  //   let row = this.xPos(node.pos)
  //   let col = this.yPos(node.pos)
  //   if (depth === 0 || this.check(row,col,node.type)) {
  //     // node.value = this.total_evaluate(this.ai) - this.total_evaluate(this.You);
  //     node.value = this.evaluatePosition(node.type,
  //       Math.floor(node.pos/this.boardSize),node.pos%this.boardSize)
  //     return;
  //   }
  //
  //   let list = this.openList;
  //
  //   if (node.type === this.You) {
  //     // MIN
  //     node.value = Infinity;
  //     for (const [nRow,nCol] of list) {
  //       this.chessBoard[nRow][nCol] = node.type // 下棋
  //       this.extend_openList(this.chessBoard,this.openList,nRow,nCol)
  //
  //       const sNode = new MinMaxNode(this.oppositeChessType(node.type), nRow*this.boardSize+nCol);
  //       // the next node is MAX
  //       // for MAX, beta equals parent's beta
  //       this.MinMax_v1(depth - 1, sNode, -Infinity, beta);
  //       // traceback
  //       this.chessBoard[nRow][nCol] = 0 // 取消该步棋
  //       this.openList = list
  //
  //       if (node.value > sNode.value) {
  //         node.value = sNode.value;
  //         node.next_best = sNode.pos;
  //       }
  //       beta = Math.min(beta, node.value);
  //       if (beta < alpha) {
  //         break;
  //       }
  //     }
  //   } else if (node.type === this.ai) {
  //     // MAX
  //     node.value = -Infinity;
  //     for (const [nRow,nCol] of list) {
  //       this.chessBoard[nRow][nCol] = node.type // 下棋
  //       this.extend_openList(this.chessBoard,this.openList,nRow,nCol)
  //       const sNode = new MinMaxNode(this.oppositeChessType(node.type), nRow*this.boardSize+nCol);
  //       // the next node is MIN
  //       // for MAX, alpha equals parent's alpha
  //       this.MinMax_v1(depth - 1, sNode, alpha, Infinity);
  //       // traceback
  //       this.chessBoard[nRow][nCol] = 0 // 取消该步棋
  //       this.openList = list
  //       if (node.value < sNode.value) {
  //         node.value = sNode.value;
  //         node.next_best = sNode.pos;
  //       }
  //       alpha = Math.max(alpha, node.value);
  //       if (alpha > beta) {
  //         break;
  //       }
  //     }
  //   }
  // }
  //
  // private xPos(pos:number):number{
  //   return Math.floor(pos/this.boardSize)
  // } // 根据位置获取横坐标
  //
  // private yPos(pos:number):number{
  //   return pos%this.boardSize
  // } // 根据位置获取纵坐标

  // 初始化棋链权值表
  private initValue(AttackMap: Map<string, number>,DefendMap: Map<string, number>){
    // 设置不同连接方式的权值并进行存储
    {
      AttackMap.set("*****", 100000);
      // 连五
      /*                                 */DefendMap.set("ooooo", 30000);
      AttackMap.set("-****-", 5000);
      // 活四
      /*                                 */DefendMap.set("-oooo-", 3000);
      AttackMap.set("*-***", 700);
      // 冲四 1
      /*                                 */DefendMap.set("o-ooo", 150);
      AttackMap.set("***-*", 700);
      // 冲四 1 反向
      /*                                 */DefendMap.set("ooo-o", 150);
      AttackMap.set("-****o", 1000);
      // 冲四 2
      /*                                 */DefendMap.set("-oooo*", 200);
      AttackMap.set("o****-", 1000);
      // 冲四 2 反向
      /*                                 */DefendMap.set("*oooo-", 200);
      AttackMap.set("**-**", 700);
      // 冲四 3
      /*                                 */DefendMap.set("oo-oo", 200);
      AttackMap.set("-***-", 500);
      // 活三 1
      /*                                 */DefendMap.set("-ooo-", 100);
      AttackMap.set("*-**", 150);
      // 活三 2
      /*                                 */DefendMap.set("o-oo", 50);
      AttackMap.set("**-*", 150);
      // 活三 2 反向
      /*                                 */DefendMap.set("oo-o", 50);
      AttackMap.set("--***o", 100);
      // 眠三 1
      /*                                 */DefendMap.set("--ooo*", 20);
      AttackMap.set("o***--", 100);
      // 眠三 1 反向
      /*        set                      */DefendMap.set("*ooo--", 20);
      AttackMap.set("-*-**o", 80);
      // 眠三 2
      /*        set                      */DefendMap.set("-o-oo*", 15);
      AttackMap.set("o**-*-", 80);
      // 眠三 2 反向
      /*        set                      */DefendMap.set("*oo-o-", 15);
      AttackMap.set("-**-*o", 60);
      // 眠三 3
      /*        set                      */DefendMap.set("-oo-o*", 10);
      AttackMap.set("o*-**-", 60);
      // 眠三 3 反向
      /*        set                      */DefendMap.set("*o-oo-", 10);
      AttackMap.set("*--**", 60);
      // 眠三 4
      /*        set                      */DefendMap.set("o--oo", 10);
      AttackMap.set("**--*", 60);
      // 眠三 4 反向
      /*        set                      */DefendMap.set("oo--o", 10);
      AttackMap.set("*-*-*", 60);
      // 眠三 5
      /*        set                      */DefendMap.set("o-o-o", 10);
      AttackMap.set("o-***-o", 60);
      // 眠三 6
      /*        set                      */DefendMap.set("*-ooo-*", 2);
      AttackMap.set("--**--", 50);
      // 活二 1
      /*        set                      */DefendMap.set("--oo--", 2);
      AttackMap.set("-*-*-", 20);
      // 活二 2
      /*        set                      */DefendMap.set("-o-o-", 2);
      AttackMap.set("*--*", 20);
      // 活二 3
      /*        set                      */DefendMap.set("o--o", 2);
      AttackMap.set("---**o", 10);
      // 眠二 1
      /*        set                      */DefendMap.set("---oo*", 1);
      AttackMap.set("o**---", 10);
      // 眠二 1 反向
      /*        set                      */DefendMap.set("*oo---", 1);
      AttackMap.set("--*-*o", 10);
      // 眠二 2
      /*        set                      */DefendMap.set("--o-o*", 1);
      AttackMap.set("o*-*--", 10);
      // 眠二 2 反向
      /*        set                      */DefendMap.set("*o-o--", 1);
      AttackMap.set("-*--*o", 10);
      // 眠二 3
      /*        set                      */DefendMap.set("-o--o*", 1);
      AttackMap.set("o*--*-", 10);
      // 眠二 3 反向
      /*        set                      */DefendMap.set("*o--o-", 1);
      AttackMap.set("*---*", 10);
      // 眠二 4
      /*                                 */DefendMap.set("o---o", 1);
    }
  }

  // 获取ai的下一步位置 [x,y]
  private getNextMove(board: number[][],AttackMap: Map<string, number>,DefendMap: Map<string, number>): number[] {
    const size = board.length;

    // 遍历表格计算权值
    let maxWeight = 0;
    let bestMove: number[] = [0,0];

    // for(let i=0;i<this.openList.length;i++){
    //   let move = this.openList[i]
    //   const weight = this.calculateValue(move, board, AttackMap, DefendMap);
    //   if (weight > maxWeight) {
    //     maxWeight = weight;
    //     bestMove = move;
    //   }
    // }

    let moves: number[][] = [];

    for (let i = 0; i < size; i++) {
      for (let j = 0; j < size; j++) {
        if (board[i][j] === 0) {
          moves.push([i,j])
          if(Math.abs(i-7)+Math.abs(j-7)<Math.abs(bestMove[0]-7)+Math.abs(bestMove[1]-7)){
            bestMove = [i,j]
          }
        }
      }
    } // 找到所有可以下的点位并优先选择更靠近中间的位置

    if(this.You==1){ // ai拿白棋 将棋盘上的黑棋转化为白棋，白棋转化为黑棋
      board = this.reverseBoth(board)
    }

    let weights = [] // 记录各点的权值

    for(let i =0;i<moves.length;i++){ // 遍历这些点位找到最大权值的点
      let move = moves[i]
      const weight = this.calculateValue(move, board, AttackMap, DefendMap);
      weights[i] = weight
      if (weight > maxWeight) {
        maxWeight = weight;
        bestMove = move;
      }
    }

    if(maxWeight>1000+Math.random()*100){
      for(let i =moves.length-1;i>=0;i--){ // 将小于最大权值的点移除 从后往前遍历防止出错
        if (weights[i] < maxWeight) {
          moves.splice(i,1)
        }
      }
      return moves[Math.floor(Math.random()*moves.length)]
    }

    return bestMove;
  }

  // 将数组中黑棋白棋互换
  private reverseBoth(board:number[][]){
    let tmp : number[][] = []
    for(let i =0;i<board.length;i++){
      tmp[i] = []
      for(let j =0;j<board.length;j++){
        if(board[i][j]==1){
          tmp[i][j]=2
        } else if(board[i][j]==2){
          tmp[i][j]=1
        } else{
          tmp[i][j]=0
        }
      }
    }
    return tmp
  }

  // 计算某点的权值
  private calculateValue(
    position: number[],
    board: number[][],
    AttackMap: Map<string, number>,
    DefendMap: Map<string, number>,
  ): number {
    const List = this.getPositionChessLink(position, board);

    let attackValue = 0;
    let defendValue = 0;

    for (const s of List) {
      if (AttackMap.has(s)) {
        attackValue += AttackMap.get(s)!;
      } else if(DefendMap.has(s)){
        defendValue += DefendMap.get(s)!;
      }
    }

    return Math.abs(attackValue - defendValue);
  }

  // 获取某点的所有棋链
  private getPositionChessLink(position: number[], board: number[][]): string[] {
    const size = board.length;
    const [x, y] = position;
    const resultList: string[] = [];

    // 竖直方向上的棋链
    for (let i = 4; i <= 7; i++) {
      for(let j = 0;j<i;j++){
        let s = "";
        let start = x-j
        let end = start+i-1
        if(start<0||end>=size){
          continue
        }
        for(;start<=end;start++){
          const chess = board[start][y];
          s += chess === 0 ? "-" : chess === 1 ? "*" : "o";
        }
        resultList.push(s)
      }
    }

    // 水平方向上的棋链
    for (let i = 4; i <= 7; i++) {
      for(let j = 0;j<i;j++){
        let s = "";
        let start = y-j
        let end = start+i-1
        if(start<0||end>=size){
          continue
        }
        for(;start<=end;start++){
          const chess = board[x][start];
          s += chess === 0 ? "-" : chess === 1 ? "*" : "o";
        }
        resultList.push(s)
      }
    }

    // 斜向方向上的棋链 从左下往右上
    for (let i = 4; i <= 7; i++) {
      for(let j = 0;j<i;j++){
        let s = "";
        let startR = x+j
        let startC = y-j
        let endR = startR-i+1
        let endC = startC+i-1

        if(!((startR >= 0 && startR < size && startC >= 0 && startC < size)
						&& (endR >= 0 && endR < size && endC >= 0 && endC < size))){
          continue
        }
        for(let row=startR,col=startC;row>=endR && col<=endC; row--,col++){
          const chess = board[row][col];
          s += chess === 0 ? "-" : chess === 1 ? "*" : "o";
        }
        resultList.push(s)
      }
    }

    // 反斜向方向上的棋链 从左上往右下
    for (let i = 4; i <= 7; i++) {
      for(let j = 0;j<i;j++){
        let s = "";
        let startR = x-j
        let startC = y-j
        let endR = startR+i-1
        let endC = startC+i-1

        if(!((startR >= 0 && startR < size && startC >= 0 && startC < size)
        && (endR >= 0 && endR < size && endC >= 0 && endC < size))){
          continue
        }
        for(let row=startR,col=startC;row<=endR && col<=endC; row++,col++){
          const chess = board[row][col];
          s += chess === 0 ? "-" : chess === 1 ? "*" : "o";
        }
        resultList.push(s)
      }
    }

    return resultList;
  }
}
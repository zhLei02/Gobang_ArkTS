import { Chess } from './Chess';
export class ChessController {
  private chessComponent: Chess = null;

  attach(component: Chess) {
    this.chessComponent = component;
  }

  public clearChess() { // 清空棋盘
    if (this.chessComponent) {
      this.chessComponent.clear();
    }
  }

  public clearChessHis(){
    if (this.chessComponent) {
      this.chessComponent.clearHis();
    }
  }

  public undoMove(type = 0) { // 悔棋
    if (this.chessComponent){
      this.chessComponent.undo(type);
    }
  }

  public AiChoose(ai:number){ // 选择ai的棋子类型
    if (this.chessComponent){
      this.chessComponent.aiUpdate(ai);
    }
  }

  public AiMove(){ // ai移动
    if (this.chessComponent){
      this.chessComponent.aiMove();
    }
  }
}
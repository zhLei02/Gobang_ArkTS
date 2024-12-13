export default class MinMaxNode{
  type: number;
  pos: number;
  value: number;
  next_best: number;

  constructor(type: number, pos: number) {
    this.type = type;
    this.pos = pos;
    this.value = 0;
    this.next_best = 0;
  }

}
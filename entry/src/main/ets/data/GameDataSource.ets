export class GameDataSource implements IDataSource {
  public dataArray: string[][] = []
  private listeners: DataChangeListener[] = [];

  constructor(ele) {
    for (var index = 0;index < ele.length; index++) {
      this.dataArray.push(ele[index])
    }
  }

  public update(ele){
    let data = []
    for (var index = 0;index < ele.length; index++) {
      data.push(ele[index])
    }
    this.dataArray = data
    this.notifyDataReload()
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): any {
    return this.dataArray[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

}
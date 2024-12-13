export class ColorUtil {
  public getCellBackgroundColor(cellValue: number) {
    switch (cellValue) {
      case 2:
        return "#EEE4DA";
      case 4:
        return "#EDE0C8";
      case 8:
        return "#F26179";
      case 16:
        return "#F59563";
      case 32:
        return "#F67C5F";
      case 64:
        return "#F65E36";
      case 128:
        return "#EDCF72";
      case 256:
        return "#EDCC61";
      case 512:
        return "#90C000";
      case 1024:
        return "#3365A5";
      case 2048:
        return "#90C000";
      case 4096:
        return "#60B0C0";
      case 8192:
        return "#9030C0";
      default:
        return "#CDC1B4";
    }
  }
}
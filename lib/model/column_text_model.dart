import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

class ColumnTextModel {
  String text;
  int width;
  SunmiPrintAlign align;
  ColumnTextModel({
    this.text = '',
    this.width = 2,
    this.align = SunmiPrintAlign.LEFT,
  });
  Map<String, String> toJson() {
    int value = 0;
    switch (align) {
      case SunmiPrintAlign.LEFT:
        value = 0;
        break;
      case SunmiPrintAlign.CENTER:
        value = 1;
        break;
      case SunmiPrintAlign.RIGHT:
        value = 2;
        break;
      default:
        value = 0;
    }
    return {
      "text": text,
      "width": width.toString(),
      "align": value.toString(),
    };
  }
}

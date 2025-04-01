import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

class SunmiTextStyle {
  SunmiFontSize fontSize;
  SunmiPrintAlign align;
  FontType fontType;
  bool bold;
  EncodeType encodeType;

  SunmiTextStyle(
      {this.fontSize = SunmiFontSize.XS,
      this.align = SunmiPrintAlign.CENTER,
      this.fontType = FontType.OTHER,
      this.bold = false,
      this.encodeType = EncodeType.UTF_8});
}

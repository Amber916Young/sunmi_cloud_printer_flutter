import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

class SunmiPrintDefaults {
  static const fontSize = SunmiFontSize.XS;
  static const align = SunmiPrintAlign.CENTER;
  static const fontType = FontType.OTHER;
  static const encodeType = EncodeType.UTF_8;
  static const bold = false;
}

class SunmiTextStyle {
  final SunmiFontSize? fontSize;
  final SunmiPrintAlign? align;
  final FontType? fontType;
  final bool? bold;
  final EncodeType? encodeType;

  const SunmiTextStyle({
    this.fontSize,
    this.align,
    this.fontType,
    this.bold,
    this.encodeType,
  });
}

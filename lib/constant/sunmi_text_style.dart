import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

class SunmiPrintDefaults {
  static const fontSize = SunmiFontSize.XXS;
  static const fontCharacterScale = SunmiCharacterScale.XXS;
  static const align = SunmiPrintAlign.CENTER;
  static const fontType = SunmiFontType.OTHER;
  static const encodeType = EncodeType.UTF_8;
  static const bold = false;
}

class SunmiTextStyle {
  final SunmiFontSize? fontSize;
  final SunmiPrintAlign? align;
  final SunmiFontType? fontType;
  final SunmiCharacterScale? fontCharacterScale;
  final bool? bold;
  final EncodeType? encodeType;

  const SunmiTextStyle({
    this.fontSize,
    this.fontCharacterScale,
    this.align,
    this.fontType,
    this.bold,
    this.encodeType,
  });
}

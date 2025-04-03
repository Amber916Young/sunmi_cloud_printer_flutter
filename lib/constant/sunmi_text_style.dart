import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

abstract class SunmiFontScale {
  const SunmiFontScale();

  factory SunmiFontScale.vector(int pixelSize) = VectorFontScale;
  factory SunmiFontScale.escPos({required int width, required int height}) = EscPosFontScale;
}

class VectorFontScale extends SunmiFontScale {
  final int pixelSize;
  const VectorFontScale(this.pixelSize);
}

class EscPosFontScale extends SunmiFontScale {
  final int width;
  final int height;
  const EscPosFontScale({required this.width, required this.height});
}

class SunmiPrintDefaults {
  static const fontSize = SunmiFontSize.MD;
  static const fontCharacterScale = SunmiCharacterScale.NORMAL;
  static const align = SunmiPrintAlign.CENTER;
  static const bold = false;
}

class SunmiTextStyle {
  final SunmiFontSize? fontSize;
  final SunmiPrintAlign? align;
  final SunmiCharacterScale? fontCharacterScale;
  final bool? bold;

  const SunmiTextStyle({
    this.fontSize,
    this.fontCharacterScale,
    this.align,
    this.bold,
  });
}

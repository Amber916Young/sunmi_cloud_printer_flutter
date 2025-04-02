import 'package:sunmi_printer_cloud_inner/constant/enums.dart';

class TextUtils {
  /// Detects if the text contains CJK (Chinese, Japanese, Korean) characters
  static bool containsChinese(String text) {
    return RegExp(r'[\u4E00-\u9FFF]').hasMatch(text);
  }

  /// Detects if the text is pure ASCII (A–Z, a–z, 0–9, punctuation)
  static bool isAscii(String text) {
    return RegExp(r'^[\x00-\x7F]+$').hasMatch(text);
  }

  /// Determines the correct font type value for a given string
  /// 10 = ASCII, 11 = CJK, 12 = Other
  static SunmiFontType getFontTypeFor(String text) {
    if (containsChinese(text)) return SunmiFontType.CJK;
    if (isAscii(text)) return SunmiFontType.LATIN;
    return SunmiFontType.OTHER;
  }
}

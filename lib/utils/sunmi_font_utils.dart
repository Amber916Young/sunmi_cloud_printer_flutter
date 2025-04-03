import 'package:flutter/material.dart';
import 'package:sunmi_printer_cloud_inner/constant/enums.dart';
import 'package:sunmi_printer_cloud_inner/constant/sunmi_text_style.dart';
import 'package:sunmi_printer_cloud_inner/model/column_text_model.dart';

class SunmiFontUtils {
  static SunmiPrinterPaper printerPaper = SunmiPrinterPaper.PAPER80;

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
    // if (containsChinese(text)) return SunmiFontType.CJK;
    // if (isAscii(text)) return SunmiFontType.LATIN;
    return SunmiFontType.OTHER;
  }

  static String generateDivider({String char = '-', int length = 36}) {
    return char * length;
  }

  static String generateSoliderDivider({String char = '━', int length = 24}) {
    return char * length;
  }

  static List<ColumnTextModel> create3Row({
    required String left,
    required String center,
    required String right,
    int rightWidth = 6,
    int centerWidth = 18,
  }) {
    int totalWidth = 32;
    return [
      ColumnTextModel(
        text: left,
        width: rightWidth,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnTextModel(
        text: center,
        width: centerWidth,
        align: SunmiPrintAlign.CENTER,
      ),
      ColumnTextModel(
        text: right,
        width: totalWidth - centerWidth - rightWidth,
        align: SunmiPrintAlign.RIGHT,
      ),
    ];
  }

  static int getMaxColsForScale(SunmiCharacterScale scale) {
    const int baseCols80mm = 48;
    final (width, _) = fontScale[scale]!;
    return (baseCols80mm ~/ width).clamp(8, 48); // clamp to avoid 0 or huge
  }

  static List<ColumnTextModel> create2Row({
    required String left,
    required String right,
    int rightWidthRatio = 12,
    SunmiCharacterScale scale = SunmiCharacterScale.NORMAL,
  }) {
    final totalWidth = getMaxColsForScale(scale);
    final leftWidth = totalWidth - rightWidthRatio;

    final List<String> leftLines = [];

    // Wrap left into multiple lines
    for (int i = 0; i < left.length; i += leftWidth) {
      leftLines.add(left.substring(i, (i + leftWidth).clamp(0, left.length)));
    }

    final List<ColumnTextModel> result = [];

    for (int i = 0; i < leftLines.length; i++) {
      result.addAll([
        ColumnTextModel(
          text: leftLines[i],
          width: leftWidth,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnTextModel(
          text: i == leftLines.length - 1 ? right : '',
          width: rightWidthRatio,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
    }

    return result;
  }

  static List<String> buildWrappedTextRows({
    required String left,
    required String right,
    required SunmiFontSize fontSize,
    int fixedLeftWidth = 26,
  }) {
    final totalCols = fontSizeToCols[fontSize]!;
    final leftWidth = fixedLeftWidth;
    final rightText = right.padLeft(totalCols - leftWidth);

    final lines = <String>[];
    final words = left.split(' ');
    var currentLine = '';

    for (final word in words) {
      if ((currentLine + (currentLine.isEmpty ? '' : ' ') + word).length <= leftWidth) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (lines.isEmpty) {
          lines.add(currentLine + rightText);
        } else {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      if (lines.isEmpty) {
        lines.add(currentLine + rightText);
      } else {
        lines.add(currentLine);
      }
    }

    return lines;
  }

  static List<List<ColumnTextModel>> buildWrappedVectorRows({
    required String left,
    required String right,
    SunmiFontSize fontSize = SunmiFontSize.MD,
    int minRightChars = 10,
  }) {
    final totalCols = fontSizeToCols[fontSize]!;
    final rightWidth = minRightChars;
    final leftWidth = totalCols - rightWidth;

    final rows = <List<ColumnTextModel>>[];
    final words = left.split(' ');
    var currentLine = '';
    final leftLines = <String>[];

    for (final word in words) {
      if ((currentLine + (currentLine.isEmpty ? '' : ' ') + word).length <= leftWidth) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        leftLines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      leftLines.add(currentLine);
    }

    for (var i = 0; i < leftLines.length; i++) {
      if (i == 0) {
        rows.add([
          ColumnTextModel(
            text: leftLines[i],
            width: leftWidth,
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnTextModel(
            text: right,
            width: rightWidth,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
      } else {
        rows.add([
          ColumnTextModel(
            text: leftLines[i],
            width: totalCols,
            align: SunmiPrintAlign.LEFT,
          ),
        ]);
      }
    }

    return rows;
  }

  static List<ColumnTextModel> createVector2Row(
      {required String left, required String right, int rightWidthRatio = 12, size = SunmiFontSize.MD}) {
    final totalWidth = fontSizeToCols[size] ?? 32;
    final leftWidth = totalWidth - rightWidthRatio;

    return [
      ColumnTextModel(
        text: left,
        width: leftWidth,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnTextModel(
        text: right,
        width: rightWidthRatio,
        align: SunmiPrintAlign.RIGHT,
      ),
    ];
  }
}

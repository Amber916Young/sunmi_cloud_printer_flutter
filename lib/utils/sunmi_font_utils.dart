import 'package:flutter/material.dart';
import 'package:sunmi_printer_cloud_inner/constant/enums.dart';
import 'package:sunmi_printer_cloud_inner/constant/sunmi_text_style.dart';
import 'package:sunmi_printer_cloud_inner/model/column_text_model.dart';

class SunmiFontUtils {
  static SunmiPrinterPaper printerPaper = SunmiPrinterPaper.PAPER80;

  static String generateBitmapDivider({String char = '-', int length = 48}) {
    return char * length;
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

  static List<List<ColumnTextModel>> buildWrappedBitmapTextRows({
    required String left,
    required String right,
    SunmiCharacterScale scale = SunmiCharacterScale.NORMAL,
    int minRightChars = 10,
  }) {
    final totalCols = bitmapCols[scale] ?? 0;
    if (totalCols == 0) return [];
    final actualRightWidth = right.length > minRightChars ? right.length : minRightChars;
    final rightWidth = actualRightWidth >= totalCols ? totalCols ~/ 2 : actualRightWidth;
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

  static List<List<ColumnTextModel>> build2ColumnWrappedVectorRows({
    required String left,
    required String right,
    SunmiFontSize fontSize = SunmiFontSize.MD,
    int minRightChars = 10,
  }) {
    final totalCols = fontSizeToCols[fontSize]!;
    final actualRightWidth = right.length > minRightChars ? right.length : minRightChars;
    final rightWidth = actualRightWidth >= totalCols ? totalCols ~/ 2 : actualRightWidth;
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
            align: SunmiPrintAlign.RIGHT,
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

  static int visualWidth(String text) {
    return text.runes.fold(0, (int acc, int rune) {
      final String char = String.fromCharCode(rune);
      final isFullWidth = RegExp(
        r'[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE10-\uFE6F\uFF00-\uFF60\uFFE0-\uFFE6]',
      ).hasMatch(char);
      return acc + (isFullWidth ? 2 : 1);
    });
  }

  /// Builds a 3-column wrapped layout with fixed left/right columns and wrapped center
  static List<List<ColumnTextModel>> build3ColumnWrappedVectorRows({
    required String left,
    required String center,
    required String right,
    SunmiFontSize fontSize = SunmiFontSize.MD,
    int minLeftChars = 4,
    int minRightChars = 6,
  }) {
    final totalCols = fontSizeToCols[fontSize]!;

    // Calculate consistent left and right width based on input lengths
    final leftWidth = left.length >= minLeftChars ? left.length : minLeftChars;
    final rightWidth = right.length >= minRightChars ? right.length : minRightChars;
    final centerWidth = totalCols - leftWidth - rightWidth;

    // Wrap center text by visual character width
    final centerWords = center.split(' ');
    final centerLines = <String>[];
    String currentLine = '';

    for (final word in centerWords) {
      final candidate = currentLine.isEmpty ? word : '$currentLine $word';
      if (visualWidth(candidate) <= centerWidth) {
        currentLine = candidate;
      } else {
        if (currentLine.isNotEmpty) centerLines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      centerLines.add(currentLine);
    }

    // Construct row output
    final rows = <List<ColumnTextModel>>[];
    for (int i = 0; i < centerLines.length; i++) {
      final isFirst = i == 0;
      rows.add([
        ColumnTextModel(
          text: isFirst ? left : ''.padRight(leftWidth),
          width: leftWidth,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnTextModel(
          text: centerLines[i],
          width: centerWidth,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnTextModel(
          text: isFirst ? right : ''.padRight(rightWidth),
          width: rightWidth,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
    }

    return rows;
  }
}

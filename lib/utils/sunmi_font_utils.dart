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

  static List<List<ColumnTextModel>> buildWrappedVectorRows({
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

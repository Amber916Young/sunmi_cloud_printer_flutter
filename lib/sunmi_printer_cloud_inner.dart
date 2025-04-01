import 'dart:convert';
import 'package:sunmi_printer_cloud_inner/constant/enums.dart';
import 'package:sunmi_printer_cloud_inner/constant/sunmi_text_style.dart';
import 'package:sunmi_printer_cloud_inner/model/cloud_device_model.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_cloud_inner/model/column_text_model.dart';
import 'package:sunmi_printer_cloud_inner/model/router_model.dart';

class SunmiPrinterCloudInner {
  static final Map _printerStatus = {
    'ERROR': 'Something went wrong.',
    'NORMAL': 'Works normally',
    'ABNORMAL_COMMUNICATION': 'Abnormal communication',
    'OUT_OF_PAPER': 'Out of paper',
    'PREPARING': 'Preparing printer',
    'OVERHEATED': 'Overheated',
    'OPEN_THE_LID': 'Open the lid',
    'PAPER_CUTTER_ABNORMAL': 'The paper cutter is abnormal',
    'PAPER_CUTTER_RECOVERED': 'The paper cutter has been recovered',
    'NO_BLACK_MARK': 'No black mark had been detected',
    'NO_PRINTER_DETECTED': 'No printer had been detected',
    'FAILED_TO_UPGRADE_FIRMWARE': 'Failed to upgrade firmware',
    'EXCEPTION': 'Unknown Error code',
  };

  ///A list to make human read the paper size
  static final List<int> _paperize = [80, 58];

  ///*sunmi_printer_plus
  ///
  //A callable method to start the comunitation with the native code!
  static const MethodChannel _channel = MethodChannel('sunmi_printer_cloud_inner');
  static const EventChannel _wifiEventChannel = EventChannel('sunmi_printer_cloud_inner/SEARCH_WIFI');
  static Stream wifiEventStream = _wifiEventChannel.receiveBroadcastStream();

  // TODO==============TEXT PRINT======================

  static Future<void> printText(String text, {SunmiTextStyle? style}) async {
    final SunmiTextStyle s = style ?? const SunmiTextStyle();
    await setEncodeMode(s.encodeType ?? SunmiPrintDefaults.encodeType);
    await setAlignment(s.align ?? SunmiPrintDefaults.align);
    await setFontSize(s.fontSize ?? SunmiPrintDefaults.fontSize);
    await setFontTypeSize(s.fontType ?? SunmiPrintDefaults.fontType);
    await setBold(s.bold ?? SunmiPrintDefaults.bold);

    Map<String, dynamic> arguments = <String, dynamic>{"text": text};
    await _channel.invokeMethod('PRINT_TEXT', arguments);
  }

  static Future<void> appendText(String text, {SunmiTextStyle? style}) async {
    final SunmiTextStyle s = style ?? const SunmiTextStyle();
    await setEncodeMode(s.encodeType ?? SunmiPrintDefaults.encodeType);
    await setAlignment(s.align ?? SunmiPrintDefaults.align);
    await setFontSize(s.fontSize ?? SunmiPrintDefaults.fontSize);
    await setFontTypeSize(s.fontType ?? SunmiPrintDefaults.fontType);
    await setBold(s.bold ?? SunmiPrintDefaults.bold);

    Map<String, dynamic> arguments = <String, dynamic>{"text": text};
    await _channel.invokeMethod('APPEND_TEXT', arguments);
  }

  static Future<void> moveToNLine(int n) async {
    Map<String, dynamic> arguments = <String, dynamic>{"lines": n};
    await _channel.invokeMethod('MOVE_N_LINE', arguments);
  }

  /**
   *  example:
   *  printColumnsText(new String[]{"c1", "c2", "c3"}, new int[]{6,10,8},
      new AlignStyle[]{AlignStyle.LEFT, AlignStyle.LEFT, AlignStyle.RIGHT});
   */

  static Future<void> printRow({required List<ColumnTextModel> cols}) async {
    final _jsonCols =
        List<Map<String, String>>.from(cols.map<Map<String, String>>((ColumnTextModel col) => col.toJson()));
    Map<String, dynamic> arguments = <String, dynamic>{
      "cols": json.encode(
        _jsonCols,
      ),
    };
    await _channel.invokeMethod('PRINT_ROW', arguments);
  }

  static Future<void> printImage(Uint8List img, {ImageAlgorithm? imageAlgorithm}) async {
    Map<String, dynamic> arguments = <String, dynamic>{};
    late int value = 0;
    switch (imageAlgorithm) {
      case ImageAlgorithm.BINARIZATION:
        value = 0;
        break;
      case ImageAlgorithm.DITHERING:
        value = 1;
        break;

      default:
        value = 0;
    }
    arguments.putIfAbsent("bitmap", () => img);
    arguments.putIfAbsent("mode", () => value);
    await _channel.invokeMethod("PRINT_IMAGE", arguments);
  }

  static Future<void> printBarcode(String data,
      {SunmiCloudPrinterBarcodeType barcodeType = SunmiCloudPrinterBarcodeType.CODE128,
      int height = 162,
      int size = 2,
      SunmiHriStyle textPosition = SunmiHriStyle.ABOVE}) async {
    int codeType = 8;
    int textPosition0 = 8;
    switch (barcodeType) {
      case SunmiCloudPrinterBarcodeType.UPCA:
        codeType = 0;
        break;
      case SunmiCloudPrinterBarcodeType.UPCE:
        codeType = 1;
        break;
      case SunmiCloudPrinterBarcodeType.EAN13:
        codeType = 2;
        break;
      case SunmiCloudPrinterBarcodeType.EAN8:
        codeType = 3;
        break;
      case SunmiCloudPrinterBarcodeType.CODE39:
        codeType = 4;
        break;
      case SunmiCloudPrinterBarcodeType.ITF:
        codeType = 5;
        break;
      case SunmiCloudPrinterBarcodeType.CODABAR:
        codeType = 6;
        break;
      case SunmiCloudPrinterBarcodeType.CODE93:
        codeType = 7;
        break;
      case SunmiCloudPrinterBarcodeType.CODE128:
        codeType = 8;
        break;
    }

    switch (textPosition) {
      case SunmiHriStyle.HIDE:
        textPosition0 = 0;
        break;
      case SunmiHriStyle.ABOVE:
        textPosition0 = 1;
        break;
      case SunmiHriStyle.BELOW:
        textPosition0 = 2;
        break;
      case SunmiHriStyle.BOTH:
        textPosition0 = 3;
        break;
    }
    Map<String, dynamic> arguments = <String, dynamic>{
      "data": data,
      'barcodeType': codeType,
      'textPosition': textPosition0,
      'size': size,
      'height': height
    };
    await _channel.invokeMethod("PRINT_BARCODE", arguments);
  }

  static Future<void> printQRCode(String data,
      {int size = 5, SunmiQrcodeLevel errorLevel = SunmiQrcodeLevel.LEVEL_H}) async {
    int errorlevel = 3;
    switch (errorLevel) {
      case SunmiQrcodeLevel.LEVEL_L:
        errorlevel = 0;
        break;
      case SunmiQrcodeLevel.LEVEL_M:
        errorlevel = 1;
        break;
      case SunmiQrcodeLevel.LEVEL_Q:
        errorlevel = 2;
        break;
      case SunmiQrcodeLevel.LEVEL_H:
        errorlevel = 3;
        break;
    }
    Map<String, dynamic> arguments = <String, dynamic>{"data": data, 'modulesize': size, 'errorlevel': errorlevel};
    await _channel.invokeMethod("PRINT_QRCODE", arguments);
  }

  Future<void> appendRawData(Uint8List data) async {
    Map<String, dynamic> arguments = <String, dynamic>{"data": data};
    await _channel.invokeMethod("PRINT_RAW_DATA", arguments);
  }

  // TODO==============TEXT PRINT===== END=================

  // TODO==============Layout======================
  static Future<void> setPrintWidth(int printWidth) async {
    Map<String, dynamic> arguments = <String, dynamic>{"width": printWidth};
    await _channel.invokeMethod("SET_PRINT_WIDTH", arguments);
  }

  static Future<void> setBlackWhiteReverseMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"reverse": true};
    await _channel.invokeMethod("SET_BLACK_WHITE_REVERSE", arguments);
  }

  // normal print
  static Future<void> resetBlackWhiteReverseMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"reverse": false};
    await _channel.invokeMethod("SET_BLACK_WHITE_REVERSE", arguments);
  }

  static Future<void> setUpsideDownMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"enable": true};
    await _channel.invokeMethod("SET_SIDE_DOWN", arguments);
  }

  // normal
  static Future<void> resetUpsideDownMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"enable": false};
    await _channel.invokeMethod("SET_SIDE_DOWN", arguments);
  }

  // 1-8
  static Future<void> setCharacterSize(int characterWidth, int characterHeight) async {
    Map<String, dynamic> arguments = <String, dynamic>{"width": characterWidth, "height": characterHeight};
    await _channel.invokeMethod("SET_CHARACTER_SIZE", arguments);
  }

  static Future<void> dotsFeed(int dots) async {
    Map<String, dynamic> arguments = <String, dynamic>{"dots": dots};
    await _channel.invokeMethod("SET_DOTS_FEED", arguments);
  }

  static Future<void> lineFeed(int lines) async {
    Map<String, dynamic> arguments = <String, dynamic>{"lines": lines};
    await _channel.invokeMethod("SET_LINE_FEED", arguments);
  }

  static Future<void> horizontalTab(int n) async {
    Map<String, dynamic> arguments = <String, dynamic>{"tab": n};
    await _channel.invokeMethod("SET_HORIZONTAL_TAB", arguments);
  }

  static Future<void> setAbsolutePrintPosition(int position) async {
    Map<String, dynamic> arguments = <String, dynamic>{"position": position};
    await _channel.invokeMethod("SET_ABS_POSITION", arguments);
  }

  static Future<void> setRelativePrintPosition(int position) async {
    Map<String, dynamic> arguments = <String, dynamic>{"position": position};
    await _channel.invokeMethod("SET_RELATIVE_POSITION", arguments);
  }

  static Future<void> setUnderline(SunmiUnderline underline) async {
    late int value;
    switch (underline) {
      case SunmiUnderline.EMPTY:
        value = 0;
        break;
      case SunmiUnderline.ONE:
        value = 1;
        break;
      case SunmiUnderline.TWO:
        value = 2;
        break;
      default:
        value = 0;
    }
    Map<String, dynamic> arguments = <String, dynamic>{"underline": value};
    await _channel.invokeMethod("SET_UNDERLINE", arguments);
  }

  static Future<void> setAlignment(SunmiPrintAlign alignment) async {
    final int value = switch (alignment) {
      SunmiPrintAlign.LEFT => 0,
      SunmiPrintAlign.CENTER => 1,
      SunmiPrintAlign.RIGHT => 2,
    };

    final arguments = {"alignment": value};
    await _channel.invokeMethod("SET_ALIGNMENT", arguments);
  }

  static Future<void> resetStyle() async {
    await _channel.invokeMethod("INIT_STYLE");
  }

  static Future<void> setBold(bool bold) async {
    Map<String, dynamic> arguments = <String, dynamic>{"bold": bold};
    await _channel.invokeMethod("SET_BOLD", arguments);
  }

  static Future<void> setLeftSpace(int space) async {
    Map<String, dynamic> arguments = <String, dynamic>{"space": space};
    await _channel.invokeMethod("SET_LEFT_SPACE", arguments);
  }

  static Future<void> setLineSpace(int space) async {
    Map<String, dynamic> arguments = <String, dynamic>{"space": space};
    await _channel.invokeMethod("SET_LINE_SPACE", arguments);
  }

  static Future<void> resetBold() async {
    Map<String, dynamic> arguments = <String, dynamic>{"bold": false};
    await _channel.invokeMethod("SET_BOLD", arguments);
  }

  static Future<void> setFontTypeSize(FontType type) async {
    late int value = 0;
    switch (type) {
      case FontType.LATIN:
        value = 1;
        break;
      case FontType.CJK:
        value = 2;
        break;
      case FontType.OTHER:
        value = 0;
        break;
    }

    Map<String, dynamic> arguments = <String, dynamic>{"size": 12, "font_type": value};

    await _channel.invokeMethod("SET_FONT_TYPE_SIZE", arguments);
  }

  static Future<void> setFontSize(SunmiFontSize size) async {
    final int width = switch (size) {
      SunmiFontSize.XS => 1,
      SunmiFontSize.SM => 2,
      SunmiFontSize.MD => 4,
      SunmiFontSize.LG => 6,
      SunmiFontSize.XL => 8,
    };

    await setCharacterSize(width, width);
  }

  static Future<void> resetFontSize(FontType type) async {
    late int value = 0;
    switch (type) {
      case FontType.LATIN:
        value = 1;
        break;
      case FontType.CJK:
        value = 2;
        break;
      case FontType.OTHER:
        value = 0;
        break;
    }
    Map<String, dynamic> arguments = <String, dynamic>{"size": 24, "font_type": value};
    await _channel.invokeMethod("SET_FONT_TYPE_SIZE", arguments);
  }

  // TODO==============end=====================
  // TODO==============Machine======================
  ///These two paper-cutting methods (half cut and full cut) are all influenced by the setPrintCutter method.
  static Future<void> cut({SunmiCutPaper cut = SunmiCutPaper.FULL}) async {
    Map<String, dynamic> arguments = <String, dynamic>{"cut_type": cut == SunmiCutPaper.FULL ? true : false};
    await _channel.invokeMethod("CUT_PAPER", arguments);
  }

  /// {dis} The distance that the printer continues to feed the paper from the current position, and paper cut is performed later.
  static Future<void> cutPost(int dis, {SunmiCutPaper cut = SunmiCutPaper.FULL}) async {
    Map<String, dynamic> arguments = <String, dynamic>{
      "cut_type": cut == SunmiCutPaper.FULL ? true : false,
      "dis": dis
    };
    await _channel.invokeMethod("CUT_POST_PAPER", arguments);
  }

  // TODO==============Machine======end================

  // TODO==============Basic======================
  ///70-130
  ///default 100
  static Future<void> setPrintDensity(int density) async {
    Map<String, dynamic> arguments = <String, dynamic>{"density": density};
    await _channel.invokeMethod("SET_PRINTER_DENSITY", arguments);
  }

  ///in 0-250
  static Future<void> setPrintSpeed(int speed) async {
    Map<String, dynamic> arguments = <String, dynamic>{"speed": speed};
    await _channel.invokeMethod("SET_PRINTER_SPEED", arguments);
  }

  static Future<void> setPrintCutter(SunmiCutMode cutMode) async {
    int value = 0;
    switch (cutMode) {
      case SunmiCutMode.NORMAL:
        value = 1;
        break;
      case SunmiCutMode.HALF:
        value = 2;
        break;
      case SunmiCutMode.FULL:
        value = 3;
        break;
      default:
        value = 0;
        break;
    }
    Map<String, dynamic> arguments = <String, dynamic>{"cut_model": value};
    await _channel.invokeMethod("SET_PRINTER_CUT", arguments);
  }

  static Future<void> selectCharFont(FontType type, int select) async {}

  /// rawData
  static Future<void> setEncodeMode(EncodeType type) async {
    int value = switch (type) {
      EncodeType.ASCII => 1,
      EncodeType.GB18030 => 2,
      EncodeType.BIG5 => 3,
      EncodeType.SHIFT_JIS => 4,
      EncodeType.JIS_0208 => 5,
      EncodeType.KSC_5601 => 6,
      EncodeType.UTF_8 => 0,
    };
    Map<String, dynamic> arguments = <String, dynamic>{"encode_mode": value};
    await _channel.invokeMethod("SET_ENCODE_MODE", arguments);
  }

  static Future<void> restoreDefaultSettings() async {
    await _channel.invokeMethod("RESTORE_DEFAULT_SETTING");
  }

  static Future<String> getDeviceSN() async {
    return await _channel.invokeMethod('GET_DEVICE_SN');
  }

  static Future<CloudPrinterStatus> getDeviceState() async {
    final String? status = await _channel.invokeMethod('GET_STATE_STATE');
    switch (status) {
      case 'OFFLINE':
        return CloudPrinterStatus.OFFLINE;
      case 'RUNNING':
        return CloudPrinterStatus.RUNNING;
      case 'NEAR_OUT_PAPER':
        return CloudPrinterStatus.NEAR_OUT_PAPER;
      case 'OUT_PAPER':
        return CloudPrinterStatus.OUT_PAPER;
      case 'JAM_PAPER':
        return CloudPrinterStatus.JAM_PAPER;
      case 'PICK_PAPER':
        return CloudPrinterStatus.PICK_PAPER;
      case 'COVER':
        return CloudPrinterStatus.COVER;
      case 'OVER_HOT':
        return CloudPrinterStatus.OVER_HOT;
      case 'MOTOR_HOT':
        return CloudPrinterStatus.MOTOR_HOT;
      default:
        return CloudPrinterStatus.UNKNOWN;
    }
  }

  static Future<PrinterMode> getDeviceMode() async {
    final String mode = await _channel.invokeMethod('GET_DEVICE_MODE');
    switch (mode) {
      case 'NORMAL_MODE':
        return PrinterMode.NORMAL_MODE;
      case 'BLACK_LABEL_MODE':
        return PrinterMode.BLACK_LABEL_MODE;
      case 'LABEL_MODE':
        return PrinterMode.LABEL_MODE;
      default:
        return PrinterMode.UNKNOWN;
    }
  }

  static Future<void> commit() async {
    await _channel.invokeMethod('COMMIT_PRINTER_BUFFER');
  }

  static Future<void> clear() async {
    await _channel.invokeMethod('CLEAR_BUFFER');
  }

  // TODO==============Basic======end================
  static Future<CloudPrinter?> getCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('GET_PRINTER_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  static Future<CloudPrinter?> setCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('SET_PRINTER_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  static Future<CloudPrinter?> connectCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('CONNECT_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  static Future<CloudPrinter?> createCloudPrinterAndConnect(String ip, int port) async {
    Map<String, dynamic> arguments = <String, dynamic>{"ip": ip, "port": port};
    dynamic printer = await _channel.invokeMethod('CONNECT_BY_IP_PORT', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  static Future<CloudPrinter?> getCurrentPrinter() async {
    dynamic printer = await _channel.invokeMethod('GET_CURRENT_PRINTER');
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  static Future<List<CloudPrinter>> searchPrinters(int searchMethod) async {
    Map<String, dynamic> arguments = <String, dynamic>{"searchMethod": searchMethod};
    dynamic printers = await _channel.invokeMethod('SEARCH_PRINTER', arguments);
    if (printers == null || printers.isEmpty) {
      return [];
    }
    return (printers as List<dynamic>)
        .map((printer) => CloudPrinter.fromJson(Map<String, dynamic>.from(printer)))
        .toList();
  }

  static Future<void> startWifiSearch() async {
    try {
      await _channel.invokeMethod('SEARCH_WIFI');
    } catch (e) {
      print('Error starting Wi-Fi search: $e');
    }
  }

  static Future<void> setPrinterSN(String name, String sn) async {
    try {
      Map<String, dynamic> arguments = <String, dynamic>{"name": name, "sn": sn};
      await _channel.invokeMethod('CONNECT_WIFI_BY_SN', arguments);
    } catch (e) {
      print('setPrinterSN error: $e');
    }
  }

  static Stream<RouterModel> fetchWifiUpdates() {
    return wifiEventStream.map((event) {
      return RouterModel.fromMap(Map<String, dynamic>.from(event));
    });
  }

  static Stream<RouterModel> fetchWifiList() {
    _channel.invokeMethod('SEARCH_WIFI');
    return _wifiEventChannel.receiveBroadcastStream().map((event) {
      return RouterModel.fromMap(Map<String, dynamic>.from(event));
    });
  }

  static Future<bool?> deleteWifi() async {
    return await _channel.invokeMethod('DELETE_WIFI_CONFIG');
  }

  static Future<bool?> existWifiConfig() async {
    return await _channel.invokeMethod('EXIST_WIFI_CONFIG');
  }

  static Future<bool> connectToWifi(String name, String printerName, String pwd) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name, "printer_name": printerName, "pwd": pwd};

    dynamic result = await _channel.invokeMethod('CONNECT_WIFI', arguments);
    return result;
  }

  static Future<bool?> stopSearch(int searchMethod) async {
    Map<String, dynamic> arguments = <String, dynamic>{"searchMethod": searchMethod};
    return await _channel.invokeMethod('STOP_SEARCH_PRINTER', arguments);
  }

  static Future<bool?> release() async {
    return await _channel.invokeMethod('DISCOUNT');
  }
}

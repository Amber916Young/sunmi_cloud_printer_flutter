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
  final wifiEventStream = _wifiEventChannel.receiveBroadcastStream();

  // TODO==============TEXT PRINT======================

  Future<void> printText(String text, {SunmiTextStyle? style}) async {
    if (style != null) {
      if (style.align != null) {
        await setAlignment(style.align!);
      }

      if (style.fontSize != null && style.fontType != null) {
        await setFontTypeSize(style.fontType!, size: style.fontSize!);
      }

      if (style.bold != null) {
        if (style.bold == true) {
          await setBold();
        }
      }
    }
    Map<String, dynamic> arguments = <String, dynamic>{"text": '$text\n'};
    await _channel.invokeMethod('PRINT_TEXT', arguments);
  }

  Future<void> appendText(String text, {SunmiTextStyle? style}) async {
    if (style != null) {
      if (style.align != null) {
        await setAlignment(style.align!);
      }

      if (style.fontSize != null && style.fontType != null) {
        await setFontTypeSize(style.fontType!, size: style.fontSize!);
      }

      if (style.bold != null) {
        if (style.bold == true) {
          await setBold();
        }
      }
    }
    Map<String, dynamic> arguments = <String, dynamic>{"text": text};
    await _channel.invokeMethod('APPEND_TEXT', arguments);
  }

  Future<void> moveToNLine(int n) async {
    Map<String, dynamic> arguments = <String, dynamic>{"lines": n};
    await _channel.invokeMethod('MOVE_N_LINE', arguments);
  }

  /**
   *  example:
   *  printColumnsText(new String[]{"c1", "c2", "c3"}, new int[]{6,10,8},
      new AlignStyle[]{AlignStyle.LEFT, AlignStyle.LEFT, AlignStyle.RIGHT});
   */

  Future<void> printRow({required List<ColumnTextModel> cols}) async {
    final _jsonCols =
        List<Map<String, String>>.from(cols.map<Map<String, String>>((ColumnTextModel col) => col.toJson()));
    Map<String, dynamic> arguments = <String, dynamic>{
      "cols": json.encode(
        _jsonCols,
      ),
    };
    await _channel.invokeMethod('PRINT_ROW', arguments);
  }

  Future<void> printImage(Uint8List img, {ImageAlgorithm? imageAlgorithm}) async {
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

  Future<void> printBarcode(String data,
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

  Future<void> printQRCode(String data, {int size = 5, SunmiQrcodeLevel errorLevel = SunmiQrcodeLevel.LEVEL_H}) async {
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
  Future<void> setPrintWidth(int printWidth) async {
    Map<String, dynamic> arguments = <String, dynamic>{"width": printWidth};
    await _channel.invokeMethod("SET_PRINT_WIDTH", arguments);
  }

  Future<void> setBlackWhiteReverseMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"reverse": true};
    await _channel.invokeMethod("SET_BLACK_WHITE_REVERSE", arguments);
  }

  // normal print
  Future<void> resetBlackWhiteReverseMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"reverse": false};
    await _channel.invokeMethod("SET_BLACK_WHITE_REVERSE", arguments);
  }

  Future<void> setUpsideDownMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"enable": true};
    await _channel.invokeMethod("SET_SIDE_DOWN", arguments);
  }

  // normal
  Future<void> resetUpsideDownMode() async {
    Map<String, dynamic> arguments = <String, dynamic>{"enable": false};
    await _channel.invokeMethod("SET_SIDE_DOWN", arguments);
  }

  // 1-8
  Future<void> setCharacterSize(int characterWidth, int characterHeight) async {
    Map<String, dynamic> arguments = <String, dynamic>{"width": characterWidth, "height": characterHeight};
    await _channel.invokeMethod("SET_CHARACTER_SIZE", arguments);
  }

  Future<void> dotsFeed(int dots) async {
    Map<String, dynamic> arguments = <String, dynamic>{"dots": dots};
    await _channel.invokeMethod("SET_DOTS_FEED", arguments);
  }

  Future<void> lineFeed(int lines) async {
    Map<String, dynamic> arguments = <String, dynamic>{"lines": lines};
    await _channel.invokeMethod("SET_LINE_FEED", arguments);
  }

  Future<void> horizontalTab(int n) async {
    Map<String, dynamic> arguments = <String, dynamic>{"tab": n};
    await _channel.invokeMethod("SET_HORIZONTAL_TAB", arguments);
  }

  Future<void> setAbsolutePrintPosition(int position) async {
    Map<String, dynamic> arguments = <String, dynamic>{"position": position};
    await _channel.invokeMethod("SET_ABS_POSITION", arguments);
  }

  Future<void> setRelativePrintPosition(int position) async {
    Map<String, dynamic> arguments = <String, dynamic>{"position": position};
    await _channel.invokeMethod("SET_RELATIVE_POSITION", arguments);
  }

  Future<void> setUnderline(SunmiUnderline underline) async {
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

  Future<void> setAlignment(SunmiPrintAlign alignment) async {
    late int value;
    switch (alignment) {
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
    Map<String, dynamic> arguments = <String, dynamic>{"alignment": value};
    await _channel.invokeMethod("SET_ALIGNMENT", arguments);
  }

  Future<void> setBold() async {
    Map<String, dynamic> arguments = <String, dynamic>{"bold": true};
    await _channel.invokeMethod("SET_BOLD", arguments);
  }

  Future<void> setLeftSpace(int space) async {
    Map<String, dynamic> arguments = <String, dynamic>{"space": space};
    await _channel.invokeMethod("SET_LEFT_SPACE", arguments);
  }

  Future<void> setLineSpace(int space) async {
    Map<String, dynamic> arguments = <String, dynamic>{"space": space};
    await _channel.invokeMethod("SET_LINE_SPACE", arguments);
  }

  Future<void> resetBold() async {
    Map<String, dynamic> arguments = <String, dynamic>{"bold": false};
    await _channel.invokeMethod("SET_BOLD", arguments);
  }

  Future<void> setFontTypeSize(FontType type, {SunmiFontSize? size, int? customSize}) async {
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
    int fontSize = customSize ?? 24;

    if (size != null) {
      switch (size) {
        case SunmiFontSize.XS:
          fontSize = 14;
          break;
        case SunmiFontSize.SM:
          fontSize = 18;
          break;
        case SunmiFontSize.MD:
          fontSize = 24;
          break;
        case SunmiFontSize.LG:
          fontSize = 36;
          break;
        case SunmiFontSize.XL:
          fontSize = 42;
          break;
      }
    }

    Map<String, dynamic> arguments = <String, dynamic>{"size": fontSize, "font_type": value};

    await _channel.invokeMethod("SET_FONT_TYPE_SIZE", arguments);
  }

  Future<void> resetFontSize(FontType type) async {
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
  Future<void> cut({SunmiCutPaper cut = SunmiCutPaper.FULL}) async {
    Map<String, dynamic> arguments = <String, dynamic>{"cut_type": cut == SunmiCutPaper.FULL ? true : false};
    await _channel.invokeMethod("CUT_PAPER", arguments);
  }

  /// {dis} The distance that the printer continues to feed the paper from the current position, and paper cut is performed later.
  Future<void> cutPost(int dis, {SunmiCutPaper cut = SunmiCutPaper.FULL}) async {
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
  Future<void> setPrintDensity(int density) async {
    Map<String, dynamic> arguments = <String, dynamic>{"density": density};
    await _channel.invokeMethod("SET_PRINTER_DENSITY", arguments);
  }

  ///in 0-250
  Future<void> setPrintSpeed(int speed) async {
    Map<String, dynamic> arguments = <String, dynamic>{"speed": speed};
    await _channel.invokeMethod("SET_PRINTER_SPEED", arguments);
  }

  Future<void> setPrintCutter(SunmiCutMode cutMode) async {
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

  Future<void> selectCharFont(FontType type, int select) async {}

  /// rawData
  Future<void> setEncodeMode(EncodeType type) async {
    int value = 0;
    switch (type) {
      case EncodeType.ASCII:
        value = 1;
        break;
      case EncodeType.GB18030:
        value = 2;
        break;
      case EncodeType.BIG5:
        value = 3;
        break;
      case EncodeType.SHIFT_JIS:
        value = 4;
        break;
      case EncodeType.JIS_0208:
        value = 5;
        break;
      case EncodeType.KSC_5601:
        value = 6;
        break;
      case EncodeType.UTF_8:
        value = 0;
        break;
      default:
        value = 0;
        break;
    }
    Map<String, dynamic> arguments = <String, dynamic>{"encode_mode": value};
    await _channel.invokeMethod("SET_ENCODE_MODE", arguments);
  }

  Future<void> restoreDefaultSettings() async {
    await _channel.invokeMethod("RESTORE_DEFAULT_SETTING");
  }

  Future<String> getDeviceSN() async {
    return await _channel.invokeMethod('GET_DEVICE_SN');
  }

  Future<CloudPrinterStatus> getDeviceState() async {
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

  Future<PrinterMode> getDeviceMode() async {
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

  Future<void> commit() async {
    await _channel.invokeMethod('COMMIT_PRINTER_BUFFER');
  }

  Future<void> clear() async {
    await _channel.invokeMethod('CLEAR_BUFFER');
  }

  // TODO==============Basic======end================
  Future<CloudPrinter?> getCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('GET_PRINTER_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  Future<CloudPrinter?> setCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('SET_PRINTER_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  Future<CloudPrinter?> connectCloudPrinterByName(String name) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name};
    dynamic printer = await _channel.invokeMethod('CONNECT_BY_NAME', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  Future<CloudPrinter?> createCloudPrinterAndConnect(String ip, int port) async {
    Map<String, dynamic> arguments = <String, dynamic>{"ip": ip, "port": port};
    dynamic printer = await _channel.invokeMethod('CONNECT_BY_IP_PORT', arguments);
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  Future<CloudPrinter?> getCurrentPrinter() async {
    dynamic printer = await _channel.invokeMethod('GET_CURRENT_PRINTER');
    if (printer == null || (printer is Map && printer.isEmpty)) {
      return null;
    }
    return CloudPrinter.fromJson(Map<String, dynamic>.from(printer));
  }

  Future<List<CloudPrinter>> searchPrinters(int searchMethod) async {
    Map<String, dynamic> arguments = <String, dynamic>{"searchMethod": searchMethod};
    dynamic printers = await _channel.invokeMethod('SEARCH_PRINTER', arguments);
    if (printers == null || printers.isEmpty) {
      return [];
    }
    return (printers as List<dynamic>)
        .map((printer) => CloudPrinter.fromJson(Map<String, dynamic>.from(printer)))
        .toList();
  }

  Future<void> startWifiSearch() async {
    try {
      await _channel.invokeMethod('SEARCH_WIFI');
    } catch (e) {
      print('Error starting Wi-Fi search: $e');
    }
  }

  Future<void> setPrinterSN(String name, String sn) async {
    try {
      Map<String, dynamic> arguments = <String, dynamic>{"name": name, "sn": sn};
      await _channel.invokeMethod('CONNECT_WIFI_BY_SN', arguments);
    } catch (e) {
      print('setPrinterSN error: $e');
    }
  }

  Stream<Map<String, dynamic>> fetchWifiUpdates() {
    return wifiEventStream.map((event) {
      print('fetchWifiUpdates: $event');
      return Map<String, dynamic>.from(event); // Parse the event
    });
  }

  // StreamSubscription fetchWifiUpdates() {
  //   return wifiEventStream.listen((event) {
  //     print('fetchWifiUpdates $event');
  //     return Map<String, dynamic>.from(event);
  //   });
  // }

  Stream<RouterModel> fetchWifiList() {
    _channel.invokeMethod('SEARCH_WIFI');
    return _wifiEventChannel.receiveBroadcastStream().map((event) {
      print("fetchWifiList $event ");
      return RouterModel.fromMap(Map<String, dynamic>.from(event));
    });
  }

  Future<bool?> deleteWifi() async {
    return await _channel.invokeMethod('DELETE_WIFI_CONFIG');
  }

  Future<bool?> existWifiConfig() async {
    return await _channel.invokeMethod('EXIST_WIFI_CONFIG');
  }

  // Future<List<RouterModel>> fetchWifiList() async {
  //   dynamic routers = await _channel.invokeMethod('SEARCH_WIFI');
  //   if (routers == null || routers.isEmpty) {
  //     return [];
  //   }
  //   return routers.map((e) => RouterModel.fromMap(Map<String, dynamic>.from(e))).toList();
  // }

  Future<bool> connectToWifi(String name, String printerName, String pwd) async {
    Map<String, dynamic> arguments = <String, dynamic>{"name": name, "printer_name": printerName, "pwd": pwd};

    dynamic result = await _channel.invokeMethod('CONNECT_WIFI', arguments);
    return result;
  }

  Future<bool?> stopSearch(int searchMethod) async {
    Map<String, dynamic> arguments = <String, dynamic>{"searchMethod": searchMethod};
    return await _channel.invokeMethod('STOP_SEARCH_PRINTER', arguments);
  }
}

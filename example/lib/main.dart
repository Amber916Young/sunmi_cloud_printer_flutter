import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sunmi_printer_cloud_inner/constant/enums.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:sunmi_printer_cloud_inner/constant/search_method.dart';
import 'package:sunmi_printer_cloud_inner/constant/sunmi_text_style.dart';
import 'package:sunmi_printer_cloud_inner/model/cloud_device_model.dart';
import 'package:sunmi_printer_cloud_inner/model/column_text_model.dart';
import 'package:sunmi_printer_cloud_inner/model/router_model.dart';
import 'package:sunmi_printer_cloud_inner/sunmi_printer_cloud_inner.dart';
import 'package:sunmi_printer_cloud_inner/utils/sunmi_font_utils.dart';
import 'package:sunmi_printer_cloud_inner/widget/dialog_utils.dart';
import 'package:sunmi_printer_cloud_inner/utils/permission_utils.dart';
import 'package:image/image.dart' as img;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeRight]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CloudPrinter> printers = [];
  List<RouterModel> routers = [];
  CloudPrinter? c_printer;
  late Stream<RouterModel> _wifiStream;
  CloudPrinterStatus? state;

  @override
  void initState() {
    super.initState();
    permissionCheck();
  }

  void permissionCheck() async {
    bool permissionsGranted = await PermissionUtils.checkBluetoothPermissions();
    if (permissionsGranted) {
      print("Permissions permissionsGranted");
    } else {
      print("Permissions are required to perform Bluetooth search.");
    }
  }

  int method = SearchMethod.bt;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> search() async {
    try {
      printers = await SunmiPrinterCloudInner.searchPrinters(method);
    } on PlatformException {}

    if (!mounted) return;

    setState(() {
      printers;
    });
  }

  Future<void> stopSearch() async {
    await SunmiPrinterCloudInner.stopSearch(method);
  }

  Future<void> connect() async {
    try {
      CloudPrinter? res = await SunmiPrinterCloudInner.createCloudPrinterAndConnect("192.168.68.134", 9100);
      print("${res?.name} ${res?.ipAddress}  ${res?.isConnected}");
    } on PlatformException {}
  }

  Future<Uint8List?> printLogoWithSize({int width = 100, int height = 100}) async {
    final ByteData data = await rootBundle.load("assets/image/logo.png");
    final Uint8List originalBytes = data.buffer.asUint8List();

    final img.Image? originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) return null;

    final img.Image resized = img.copyResize(
      originalImage,
      width: width,
      height: height, // Will distort if not same aspect ratio
    );

    return Uint8List.fromList(img.encodePng(resized));
  }

  void startSearch() {
    SunmiPrinterCloudInner.startWifiSearch();
    SunmiPrinterCloudInner.fetchWifiUpdates().listen((router) {
      print('Router received: $router');
      routers.add(router);
      setState(() {});
    }, onError: (error) {
      print('Error receiving router data: $error');
    });
  }

  void startSearchBySN(String sn) {
    SunmiPrinterCloudInner.setPrinterSN("${c_printer?.name}", sn);
    SunmiPrinterCloudInner.fetchWifiUpdates().listen((router) {
      print('Router received: $router');
      routers.add(router);
      setState(() {});
    }, onError: (error) {
      print('Error receiving router data: $error');
    });
  }

  Future<void> printRightTextBlock(
    List<String> lines, {
    int leftPadding = 12, // adjust based on logo width
    SunmiTextStyle? style,
  }) async {
    final pad = ' ' * leftPadding;
    for (final line in lines) {
      await SunmiPrinterCloudInner.printBitmapText(
        "$pad$line",
        style: style,
      );
    }
  }

  Future<Uint8List> generateHeaderLayoutImage({
    required ByteData logoBytes,
    required List<String> lines,
    double imageHeight = 150,
    double padding = 10,
  }) async {
    // Decode logo
    final codec = await ui.instantiateImageCodec(
      logoBytes.buffer.asUint8List(),
      targetHeight: imageHeight.toInt(),
    );
    final frame = await codec.getNextFrame();
    final ui.Image logoImage = frame.image;

    // Text style
    final textStyle = ui.TextStyle(
      color: const Color(0xFF000000),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    );
    final int gapBetweenLogoAndText = 30;

    // Create text paragraphs
    final List<ui.Paragraph> paragraphs = lines.map((line) {
      final builder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(line);
      return builder.build()..layout(ui.ParagraphConstraints(width: 300));
    }).toList();

    final totalTextHeight = paragraphs.fold<double>(0, (sum, p) => sum + p.height + padding);
    final int canvasHeight = totalTextHeight > logoImage.height ? totalTextHeight.toInt() : logoImage.height;
    final int canvasWidth = logoImage.width + gapBetweenLogoAndText + 300;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()));
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()), paint);

    // Draw logo
    canvas.drawImage(logoImage, Offset(0, (canvasHeight - logoImage.height) / 2), Paint());

    // Draw text
    double textY = (canvasHeight - totalTextHeight) / 2;
    for (final paragraph in paragraphs) {
      canvas.drawParagraph(paragraph, Offset(logoImage.width + gapBetweenLogoAndText.toDouble(), textY));
      textY += paragraph.height + padding;
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(canvasWidth, canvasHeight);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> printHeaderWithLogo() async {
    final logoBytes = await rootBundle.load('assets/image/logo.png');
    final headerImage = await generateHeaderLayoutImage(
      logoBytes: logoBytes,
      lines: ['Collection', 'PAID', '#100242'],
    );
    await SunmiPrinterCloudInner.printImage(headerImage);
  }

  /// Pads left and right strings to fit a totalWidth using monospace assumption.
  String padRow(String left, String right, {int totalWidth = 32}) {
    final leftTrimmed = left.trim();
    final rightTrimmed = right.trim();
    final space = totalWidth - leftTrimmed.length - rightTrimmed.length;
    return leftTrimmed + (space > 0 ? ' ' * space : ' ') + rightTrimmed;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Cloud Plugin example app'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await stopSearch();
                        setState(() {
                          method = SearchMethod.bt;
                        });
                        await search();
                      },
                      child: Text("Search By BLE"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await stopSearch();
                        setState(() {
                          method = SearchMethod.lan;
                        });
                        await search();
                      },
                      child: Text("Search By LAN"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await stopSearch();
                        setState(() {
                          method = SearchMethod.usb;
                        });
                        await search();
                      },
                      child: Text("Search By USB"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await stopSearch();
                      },
                      child: Text("Stop Search"),
                    ),
                  ],
                ),
                Text("current Printer ${c_printer?.isConnected} ${c_printer?.name}  ${c_printer?.ipAddress}"),
                ListView.builder(
                  itemCount: printers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    return ListTile(
                      leading: Icon(Icons.print),
                      title: Text(printer.name),
                      subtitle: Text('IP: ${printer.ipAddress}\nMAC: ${printer.macAddress}'),
                      trailing: printer.isConnected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.cancel, color: Colors.red),
                      onTap: () async {
                        // Handle printer selection
                        await SunmiPrinterCloudInner.stopSearch(SearchMethod.bt);
                        c_printer = printer;
                        c_printer = await SunmiPrinterCloudInner.connectCloudPrinterByName("${printer.name}");
                        setState(() {});
                      },
                    );
                  },
                ),
                Text("state ${state?.name}"),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        state = await SunmiPrinterCloudInner.getDeviceState();
                        setState(() {});
                      },
                      child: Text("Get state"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        startSearch();
                      },
                      child: Text("Search Printer WIFI"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // String? sn = await DialogUtils.showPasswordDialog(context, c_printer?.name ?? "");
                        // if (sn != null && sn.isNotEmpty) {
                        //   startSearchBySN(sn);
                        // }

                        startSearchBySN("");
                      },
                      child: Text("Search Printer WIFI By passing SN"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SunmiPrinterCloudInner.deleteWifi();
                      },
                      child: Text("deletePrinterWifi"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SunmiPrinterCloudInner.existWifiConfig();
                      },
                      child: Text("exitPrinterWifi"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        c_printer = await SunmiPrinterCloudInner.getCurrentPrinter();
                        print(c_printer?.ipAddress);
                        setState(() {});
                      },
                      child: Text("getCurrentPrinter"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        c_printer = await SunmiPrinterCloudInner.connectCloudPrinterByName("${c_printer?.name}");
                        print(c_printer?.ipAddress);
                        setState(() {});
                      },
                      child: Text("Connect by name"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // String? ip = await DialogUtils.showIpInputDialog(context, c_printer?.name ?? "");
                        String ip = "192.168.68.134";
                        int port = 9100;
                        if (ip != null && ip.isNotEmpty) {
                          c_printer = await SunmiPrinterCloudInner.createCloudPrinterAndConnect(ip, port);
                          setState(() {});
                        }
                      },
                      child: Text("connect By IP"),
                    ),
                  ],
                ),
                Text("current Printer's WIFI list"),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: routers.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final router = routers[index];
                      return ListTile(
                        leading: const Icon(Icons.wifi),
                        title: Text(router.name),
                        subtitle: Text('pwd: ${router.pwd}\n rssi: ${router.rssi}'),
                        trailing: router.hasPwd ? const Icon(Icons.lock) : const Icon(Icons.lock_open),
                        onTap: () async {
                          // need password should input password Ac3Un1tC2!
                          if (router.hasPwd) {
                            String? password = await DialogUtils.showPasswordDialog(context, router.name);
                            password = "Ac3Un1tC2";
                            if (password != null && password.isNotEmpty) {
                              bool res = await SunmiPrinterCloudInner.connectToWifi(
                                  router.name, "${c_printer?.name}", password);
                              print("Password for ${router.name}: $password $res");
                            }
                          } else {
                            print("No password required for ${router.name}");
                          }
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await SunmiPrinterCloudInner.printVectorText("Test 欢迎",
                            style: SunmiTextStyle(fontSize: SunmiFontSize.XS));
                        await SunmiPrinterCloudInner.printVectorText("Test 欢迎",
                            style: SunmiTextStyle(
                                fontSize: SunmiFontSize.MD)); // await SunmiPrinterCloudInner.selectVectorFont();
                        // for (final size in SunmiFontSize.values) {
                        //   await SunmiPrinterCloudInner.printVectorText("Test 欢迎 😀",
                        //       style: SunmiTextStyle(fontSize: size));
                        // }
                        await SunmiPrinterCloudInner.moveToNLine(5);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print differnt Size vector"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await SunmiPrinterCloudInner.selectBitMapFont();
                        // for (final scale in SunmiCharacterScale.values) {
                        //   await SunmiPrinterCloudInner.printBitmapText("This is a test",
                        //       style: SunmiTextStyle(fontCharacterScale: scale));
                        // }

                        await SunmiPrinterCloudInner.printBitmapText("This is a test",
                            style: SunmiTextStyle(fontCharacterScale: SunmiCharacterScale.NORMAL));
                        await SunmiPrinterCloudInner.moveToNLine(5);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print differnt Bitmap vector"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await SunmiPrinterCloudInner.printDivider(SunmiFontUtils.generateDivider());
                        await SunmiPrinterCloudInner.printDivider(SunmiFontUtils.generateSoliderDivider());
                        await SunmiPrinterCloudInner.printDivider(SunmiFontUtils.generateDivider(char: "*"));
                        await SunmiPrinterCloudInner.moveToNLine(5);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print  Divider"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final divider = SunmiFontUtils.generateDivider();
                        await SunmiPrinterCloudInner.moveToNLine(5);
                        await SunmiPrinterCloudInner.printVectorText("Koshiba(Leixlip)-Staging",
                            style: SunmiTextStyle(fontCharacterScale: SunmiCharacterScale.SM, bold: true));
                        await SunmiPrinterCloudInner.printVectorText("Leixlip, Ireland",
                            style: SunmiTextStyle(fontCharacterScale: SunmiCharacterScale.NORMAL, bold: true));
                        await SunmiPrinterCloudInner.printVectorText("0123456");
                        await SunmiPrinterCloudInner.printDivider(divider);

                        await printHeaderWithLogo();

                        await SunmiPrinterCloudInner.printVectorText("Placed at 12:10 01/04/25",
                            style: SunmiTextStyle(fontSize: SunmiFontSize.SM));
                        await SunmiPrinterCloudInner.printVectorText("Accepted for 13:53 01/04/25",
                            style: SunmiTextStyle(bold: true));
                        await SunmiPrinterCloudInner.moveToNLine(1);
                        await SunmiPrinterCloudInner.printDivider(divider);

                        await SunmiPrinterCloudInner.setBold(true);
                        await SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        await SunmiPrinterCloudInner.setVectorFontSizeFromLevel(SunmiFontSize.LG);
                        SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        final List<(String, String)> items = [
                          ("1 x Drinks 饮料", "€ 7.00"),
                          ("  + Coke", "€ 0.00"),
                          ("1 x Chicken Noodle Soup （鸡肉汤面）", "€ 4.50"),
                          ("1 x Hot & Sour Soup", "€ 4.50"),
                          ("1 x Chicken & House Special", "€ 15.60"),
                          ("1 x Friend rice", "€ 0.00"),
                          ("1 x Soft Drinks", "€ 0.00"),
                        ];

                        for (final (left, right) in items) {
                          final lines = SunmiFontUtils.buildWrappedVectorRows(
                            left: left,
                            right: right,
                            fontSize: SunmiFontSize.LG,
                          );
                          for (final row in lines) {
                            await SunmiPrinterCloudInner.printRow(cols: row);
                          }
                        }

                        await SunmiPrinterCloudInner.printDivider(divider);
                        await SunmiPrinterCloudInner.printVectorText("Items: 6",
                            style: SunmiTextStyle(fontSize: SunmiFontSize.LG, bold: true, align: SunmiPrintAlign.LEFT));

                        await SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        await SunmiPrinterCloudInner.printVectorText(padRow("Total", "€ 0.60"),
                            style: SunmiTextStyle(fontSize: SunmiFontSize.LG, bold: true));
                        await SunmiPrinterCloudInner.printDivider(divider);
                        await SunmiPrinterCloudInner.printVectorText("Customer Detail",
                            style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.LEFT));
                        await SunmiPrinterCloudInner.printVectorText("Username (27 orders)",
                            style: SunmiTextStyle(bold: false, align: SunmiPrintAlign.LEFT));
                        await SunmiPrinterCloudInner.moveToNLine(1);

                        await SunmiPrinterCloudInner.printVectorText("+353 8828291921",
                            style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.LEFT));

                        await SunmiPrinterCloudInner.moveToNLine(10);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print Bitmap Sample"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final divider = SunmiFontUtils.generateDivider();
                        await SunmiPrinterCloudInner.moveToNLine(5);
                        await SunmiPrinterCloudInner.printVectorText("Koshiba(Leixlip)-Staging",
                            style: SunmiTextStyle(fontCharacterScale: SunmiCharacterScale.SM, bold: true));
                        await SunmiPrinterCloudInner.printVectorText("Leixlip, Ireland",
                            style: SunmiTextStyle(fontCharacterScale: SunmiCharacterScale.NORMAL, bold: true));
                        await SunmiPrinterCloudInner.printVectorText("0123456");
                        await SunmiPrinterCloudInner.printDivider(divider);

                        await printHeaderWithLogo();

                        await SunmiPrinterCloudInner.printVectorText("Placed at 12:10 01/04/25",
                            style: SunmiTextStyle(fontSize: SunmiFontSize.SM));
                        await SunmiPrinterCloudInner.printVectorText("Accepted for 13:53 01/04/25",
                            style: SunmiTextStyle(bold: true));
                        await SunmiPrinterCloudInner.moveToNLine(1);
                        await SunmiPrinterCloudInner.printDivider(divider);

                        await SunmiPrinterCloudInner.setBold(true);
                        await SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        await SunmiPrinterCloudInner.setVectorFontSizeFromLevel(SunmiFontSize.LG);
                        SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        final List<(String, String)> items = [
                          ("1 x Drinks 饮料", "€ 7.00"),
                          ("  + Coke", "€ 0.00"),
                          ("1 x Chicken Noodle Soup （鸡肉汤面）", "€ 4.50"),
                          ("1 x Hot & Sour Soup", "€ 4.50"),
                          ("1 x Chicken & House Special", "€ 15.60"),
                          ("1 x Friend rice", "€ 0.00"),
                          ("1 x Soft Drinks", "€ 0.00"),
                        ];

                        for (final (left, right) in items) {
                          final lines = SunmiFontUtils.buildWrappedVectorRows(
                            left: left,
                            right: right,
                            fontSize: SunmiFontSize.LG,
                          );
                          for (final row in lines) {
                            await SunmiPrinterCloudInner.printRow(cols: row);
                          }
                        }

                        await SunmiPrinterCloudInner.printDivider(divider);
                        await SunmiPrinterCloudInner.printVectorText("Items: 6",
                            style: SunmiTextStyle(fontSize: SunmiFontSize.LG, bold: true, align: SunmiPrintAlign.LEFT));

                        await SunmiPrinterCloudInner.setEncodeMode(EncodeType.UTF_8);
                        await SunmiPrinterCloudInner.printVectorText(padRow("Total", "€ 0.60"),
                            style: SunmiTextStyle(fontSize: SunmiFontSize.LG, bold: true));
                        await SunmiPrinterCloudInner.printDivider(divider);
                        await SunmiPrinterCloudInner.printVectorText("Customer Detail",
                            style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.LEFT));
                        await SunmiPrinterCloudInner.printVectorText("Username (27 orders)",
                            style: SunmiTextStyle(bold: false, align: SunmiPrintAlign.LEFT));
                        await SunmiPrinterCloudInner.moveToNLine(1);

                        await SunmiPrinterCloudInner.printVectorText("+353 8828291921",
                            style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.LEFT));

                        await SunmiPrinterCloudInner.moveToNLine(10);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print vector Sample"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await SunmiPrinterCloudInner.clear();
                      },
                      child: Text("Stop print and clean buffer"),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

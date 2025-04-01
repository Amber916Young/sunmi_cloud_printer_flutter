import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sunmi_printer_cloud_inner/constant/enums.dart';
import 'package:sunmi_printer_cloud_inner/constant/search_method.dart';
import 'package:sunmi_printer_cloud_inner/model/cloud_device_model.dart';
import 'package:sunmi_printer_cloud_inner/model/router_model.dart';
import 'package:sunmi_printer_cloud_inner/sunmi_printer_cloud_inner.dart';
import 'package:sunmi_printer_cloud_inner/widget/dialog_utils.dart';
import 'package:sunmi_printer_cloud_inner/utils/permission_utils.dart';

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

  Future<void> printText() async {
    try {
      await SunmiPrinterCloudInner.printText("hello");
    } on PlatformException {}
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
                        String ip = '192.168.68.134';
                        if (ip != null && ip.isNotEmpty) {
                          c_printer = await SunmiPrinterCloudInner.createCloudPrinterAndConnect(ip, 9100);
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
                        await SunmiPrinterCloudInner.printText("hellohellohellohellohellohellohellohello");
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print hello text"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await SunmiPrinterCloudInner.printText("hellohellohellohellohellohellohellohello");
                        await SunmiPrinterCloudInner.moveToNLine(10);
                        await SunmiPrinterCloudInner.appendText("dsdsd");
                        await SunmiPrinterCloudInner.moveToNLine(10);
                        await SunmiPrinterCloudInner.cut();
                        await SunmiPrinterCloudInner.commit();
                      },
                      child: Text("print test text"),
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

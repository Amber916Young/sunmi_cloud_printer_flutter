// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
//
// import 'sunmi_printer_cloud_inner_platform_interface.dart';
//
// /// An implementation of [SunmiPrinterCloudInnerPlatform] that uses method channels.
// class MethodChannelSunmiPrinterCloudInner extends SunmiPrinterCloudInnerPlatform {
//   /// The method channel used to interact with the native platform.
//   @visibleForTesting
//   final methodChannel = const MethodChannel('sunmi_printer_cloud_inner');
//
//   @override
//   Future<String?> getPlatformVersion() async {
//     final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
//     return version;
//   }
// }

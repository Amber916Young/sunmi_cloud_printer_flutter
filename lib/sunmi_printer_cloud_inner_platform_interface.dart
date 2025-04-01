import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sunmi_printer_cloud_inner_method_channel.dart';

abstract class SunmiPrinterCloudInnerPlatform extends PlatformInterface {
  /// Constructs a SunmiPrinterCloudInnerPlatform.
  SunmiPrinterCloudInnerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SunmiPrinterCloudInnerPlatform _instance = MethodChannelSunmiPrinterCloudInner();

  /// The default instance of [SunmiPrinterCloudInnerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSunmiPrinterCloudInner].
  static SunmiPrinterCloudInnerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SunmiPrinterCloudInnerPlatform] when
  /// they register themselves.
  static set instance(SunmiPrinterCloudInnerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

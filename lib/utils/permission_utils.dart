import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkBluetoothPermissions() async {
    if (await Permission.location.isGranted &&
        await Permission.bluetooth.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothScan.isGranted) {
      return true;
    }

    final status = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    return status.values.every((permission) => permission.isGranted);
  }
}

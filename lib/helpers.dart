import 'package:platform_device_id/platform_device_id.dart';

Future<String?> getDeviceID() async {
  return await PlatformDeviceId.getDeviceId;
}

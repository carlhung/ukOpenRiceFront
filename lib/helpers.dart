import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter/material.dart';

Future<String?> getDeviceID() async {
  return await PlatformDeviceId.getDeviceId;
}

void showErrorOnSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: Duration(seconds: 5), content: Text(error.toString())),
  );
}

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

extension StringCasingExtension on String {
  String get toCapitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized).join(' ');
}

List<String> createPriceRangeList() {
  List<String> arr = List.generate(9, (index) {
    int value = (index + 1) * 10;
    return '$value-${value + 10}';
  });

  return ["1-10"] + arr + ["100+"];
}

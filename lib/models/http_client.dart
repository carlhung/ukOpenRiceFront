import 'package:http/http.dart' as http;
import '../helpers.dart';
import 'dart:convert';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        //add your certificate verification logic here
        return true;
      };
  }
}

class Httpclient {
  static final shared = Httpclient();

  final isInternal = false;
  String username = '';
  String token = '';
  String deviceID = '';
  bool isAdmin = false;

  Httpclient() {
    HttpOverrides.global = MyHttpOverrides();
  }

  String get hostEndPoint {
    return isInternal ? "192.168.1.9" : "carlhung.asuscomm.com";
  }

  Uri getUri(String path) {
    return Uri(scheme: 'https', host: hostEndPoint, port: 8000, path: path);
  }

  Future<void> signIn(String name, String password) async {
    final uri = getUri('/token');

    final id = await getDeviceID();

    final String deviceID;
    if (id != null && id.isNotEmpty) {
      deviceID = '&client_id=$id';
    } else {
      deviceID = '';
    }

    final response = await http.post(
      uri,
      headers: {
        "accept": 'application/json',
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: 'username=$name&password=$password$deviceID',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      token = data['access_token'] ?? '';
      username = name;
      isAdmin = data['is_admin'] ?? false;
      this.deviceID = id ?? '';
    } else {
      token = "";
      username = "";
      this.deviceID = "";
      isAdmin = false;
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }
}

import 'package:http/http.dart' as http;
import '../helpers.dart';
import 'dart:convert';
import 'dart:io';
import './resturant_info.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

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
  String username = ''; //'admin';
  String token = '';
  String deviceID = '';
  bool isAdmin = false;
  String password = ''; //'eatRice123abc!';

  Httpclient() {
    HttpOverrides.global = MyHttpOverrides();
  }

  String get hostEndPoint {
    return isInternal ? "192.168.1.9" : "carlhung.asuscomm.com";
  }

  Uri getUri(String path) {
    return Uri(scheme: 'https', host: hostEndPoint, port: 8000, path: path);
  }

  Future<void> logIn(String name, String password) async {
    if (name.isEmpty && password.isEmpty) {
      throw Exception("empty username and password");
    }

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
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      token = data['access_token'] ?? '';
      username = name;
      isAdmin = data['is_admin'] ?? false;
      this.deviceID = id ?? '';
      this.password = password;
    } else {
      token = "";
      username = "";
      this.deviceID = "";
      isAdmin = false;
      this.password = '';
      throw handlerFailure(data);
    }
  }

  Exception handlerFailure(Map<String, dynamic> data) {
    final serverError = ServerError.fromJson(data);
    if (serverError != null) {
      throw serverError;
    }
    throw Exception(data.toString());
  }

  Future<void> submitRestaurantInformation(ResturantInfo info) async {
    await reloginWrapper(() async {
      final uri = getUri('/submitrestaurantinformation');

      final body = jsonEncode(info.toJson());

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final String? result = data["result"];
        if (result == "successful") {
        } else {
          throw handlerFailure(data);
        }
      } else if (response.statusCode == 401) {
        throw Unauthorized401Exception();
      } else {
        throw handlerFailure(data);
      }
    });
  }

  // true means login successful.
  Future<bool> _relogIn() async {
    if (username.isNotEmpty && password.isNotEmpty) {
      await logIn(username, password);
      return true;
    } else {
      return false;
    }
  }

  Future<void> reloginWrapper(Future<void> Function() execute) async {
    while (true) {
      try {
        await execute();
        return;
      } on Unauthorized401Exception {
        final isSuccessful = await _relogIn();
        if (isSuccessful) {
          continue;
        } else {
          throw Exception("Failed to login");
        }
      }
    }
  }

  Uint8List? createBodyWithParameters<T>(
    List<BodyPair<T>> parameters, {
    String name = "files",
  }) {
    final boundary = "Boundary-${Uuid().v4()}";
    final body = BytesBuilder();

    for (var bodyPair in parameters) {
      final value = bodyPair.value;
      if (value is EncodableBodyValue<T>) {
        final encodedData = utf8.encode(
          value.encodable.toString(),
        ); // Replace with actual encoding
        final prefix = fileBodyPrefix(
          boundary,
          name,
          "metaData.txt",
          "text/plain",
        );
        body.add(prefix);
        body.add(encodedData);
        body.add(fileBodySuffix);
      } else if (value is ImagesBodyValue<T>) {
        for (var i = 0; i < value.images.length; i++) {
          final filename = "image$i.jpg";
          final data = convertToData(value.images[i]);
          if (data == null) return null;
          final mimetype = mimeType(data) ?? "application/octet-stream";
          final prefix = fileBodyPrefix(boundary, name, filename, mimetype);
          body.add(prefix);
          body.add(data);
          body.add(fileBodySuffix);
        }
      }
    }

    final endOfBoundary = utf8.encode("--$boundary--\r\n");
    body.add(endOfBoundary);

    return body.takeBytes();
  }

  Uint8List fileBodyPrefix(
    String boundary,
    String name,
    String filename,
    String mimetype,
  ) {
    final prefix =
        "--$boundary\r\n"
        "Content-Disposition: form-data; name=\"$name\"; filename=\"$filename\"\r\n"
        "Content-Type: $mimetype\r\n\r\n";
    // return utf8.encode(prefix) as Uint8List;
    return utf8.encode(prefix);
  }

  // final fileBodySuffix = utf8.encode("\r\n") as Uint8List;
  final fileBodySuffix = utf8.encode("\r\n");

  Uint8List? convertToData(Uint8List image, {double compressionQuality = 0.9}) {
    // TODO: Implement image to bytes conversion here
    return null;
  }

  String? mimeType(Uint8List data) {
    if (data.isEmpty) return null;
    switch (data[0]) {
      case 0xFF:
        return "image/jpeg";
      case 0x89:
        return "image/png";
      case 0x47:
        return "image/gif";
      case 0x49:
      case 0x4D:
        return "image/tiff";
      default:
        return null;
    }
  }
}

class Unauthorized401Exception implements Exception {}

final class ServerError implements Exception {
  final String detail;
  // final int statusCode;
  // final Map<String, String> headers;

  ServerError({
    required this.detail,
    // required this.statusCode,
    // this.headers = const {},
  });

  static ServerError? fromJson(Map<String, dynamic> json) {
    if (json['detail'] is! String) {
      return null;
    }

    final String detail = json['detail'];

    return ServerError(detail: detail);
  }

  Map<String, dynamic> toJson() {
    return {'detail': detail};
  }

  @override
  String toString() {
    return detail;
  }
}

class BodyPair<T> {
  final String key;
  final BodyValue<T> value;

  BodyPair({required this.key, required this.value});
}

abstract class BodyValue<T> {}

class ImagesBodyValue<T> extends BodyValue<T> {
  final List<Uint8List> images; // Replace dynamic with your image type
  ImagesBodyValue(this.images);
}

class EncodableBodyValue<T> extends BodyValue<T> {
  final T encodable;
  EncodableBodyValue(this.encodable);
}

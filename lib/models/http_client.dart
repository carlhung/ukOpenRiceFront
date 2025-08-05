import 'package:http/http.dart' as http;
import '../helpers.dart';
import 'dart:convert';
import 'dart:io';
import './resturant_info.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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

  final isInternal = true;
  String username = '';
  String token = '';
  String deviceID = '';
  bool isAdmin = false;
  String password = '';

  Httpclient() {
    HttpOverrides.global = MyHttpOverrides();
  }

  String get hostEndPoint {
    return isInternal ? "192.168.1.9" : "carlhung.asuscomm.com";
  }

  int get port {
    return 8000;
  }

  Uri getUri(String path, {Map<String, String> queryParameters = const {}}) {
    return Uri(
      scheme: 'https',
      host: hostEndPoint,
      port: 8000,
      path: path,
      queryParameters: queryParameters,
    );
  }

  String getCityURL(String city) {
    String encodedString = Uri.encodeComponent(
      city.toLowerCase(),
    ); // String decodedString = Uri.decodeComponent(encodedString);
    return 'https://$hostEndPoint:$port/static/city_icons/$encodedString.jpg';
  }

  Future<void> removeRestaurant(String name) async {
    reloginWrapper(() async {
      final uri = getUri(
        '/deleterestaurant',
        queryParameters: {"restaurantName": name},
      );
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final String? result = data["result"];
        if (result == "successful") {
          return;
        } else {
          throw handlerFailure(data);
        }
      } else if (statusCode == 401) {
        throw Unauthorized401Exception();
      } else {
        throw handlerFailure(data);
      }
    });
  }

  Future<List<String>> getListOfRestaurants() async {
    return await reloginWrapper(() async {
      final uri = getUri('/removerestaurantinfo');

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final String? result = data["result"];
        if (result == "successful") {
          final List<String> restaurantNames = List<String>.from(
            data["restaurant names"],
          );
          return restaurantNames;
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

  Future<(List<String>, List<String>)> filterData() {
    return reloginWrapper(() async {
      final uri = getUri('/filterdata');

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // final String? result = data["result"];
        final List<String> cities = List<String>.from(data["cities"]);
        final List<String> cuisines = List<String>.from(data["cuisines"]);
        if (cities.isNotEmpty && cuisines.isNotEmpty) {
          return (cities, cuisines);
        } else {
          throw Exception("No data found");
        }
      } else if (response.statusCode == 401) {
        throw Unauthorized401Exception();
      } else {
        throw handlerFailure(data);
      }
    });
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

  Future<void> postReview(Map<String, dynamic> review) async {
    await reloginWrapper(() async {
      final uri = getUri("/post_review");
      final body = jsonEncode(review);
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

  Future<void> uploadRestaurantImages(List<BodyPair> parameters) async {
    final boundary = generateBoundaryString();
    await reloginWrapper(() async {
      final uri = getUri('/uploadrestaurantimages');
      final body = await createBodyWithParameters(boundary, parameters);
      if (body != null) {
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "multipart/form-data; boundary=$boundary",
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

  Future<T> reloginWrapper<T>(Future<T> Function() execute) async {
    while (true) {
      try {
        final result = await execute();
        return result;
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

  String generateBoundaryString() {
    return "Boundary-${Uuid().v4()}";
  }

  Future<Uint8List?> createBodyWithParameters<T>(
    String boundary,
    List<BodyPair> parameters, {
    String name = "files",
  }) async {
    final body = BytesBuilder();

    for (var bodyPair in parameters) {
      final value = bodyPair.value;
      if (value is EncodableBodyValue) {
        final jsonString = jsonEncode(value.encodable.toJson());
        final encodedData = utf8.encode(jsonString);
        final prefix = fileBodyPrefix(
          boundary,
          name,
          "metaData.txt",
          "text/plain",
        );
        body.add(prefix);
        body.add(encodedData);
        body.add(fileBodySuffix);
      } else if (value is ImagesBodyValue) {
        for (var i = 0; i < value.images.length; i++) {
          final filename = "image$i.jpg";
          final data = await convertToJpgBytes(value.images[i]);
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

  Future<Uint8List> convertToJpgBytes(XFile xfile, {int quality = 90}) async {
    // Read the original image as bytes
    final originalBytes = await xfile.readAsBytes();

    // Decode the image (handles PNG, JPG, etc.)
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) {
      throw Exception("Unable to decode image.");
    }

    // Encode it as JPEG with specified quality
    final jpgBytes = img.encodeJpg(decodedImage, quality: quality);

    return Uint8List.fromList(jpgBytes);
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

  ServerError({required this.detail});

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

abstract class Encodable {
  Map<String, dynamic> toJson();
}

class BodyValue {}

class BodyPair {
  final String key;
  final BodyValue value;

  BodyPair({required this.key, required this.value});
}

final class ImagesBodyValue extends BodyValue {
  final List<XFile> images;
  ImagesBodyValue(this.images);
}

class EncodableBodyValue<T extends Encodable> extends BodyValue {
  final T encodable;
  EncodableBodyValue(this.encodable);
}

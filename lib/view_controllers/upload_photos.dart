import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';

class UploadPhotosVC extends StatefulWidget {
  const UploadPhotosVC({super.key});

  @override
  State<UploadPhotosVC> createState() => _UploadPhotosVCState();
}

final class _UploadPhotosVCState extends State<UploadPhotosVC> {
  final httpClient = Httpclient.shared;
  final ImagePicker picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    final restaurantEnglishName =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _selectedImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1, // Makes cells square
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final selectedImage = await picker.pickMultiImage();
                    setState(() {
                      _selectedImages = selectedImage;
                    });
                  },
                  child: Text("Select Image"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await httpClient.uploadRestaurantImages([
                        BodyPair(value: ImagesBodyValue(_selectedImages)),
                        BodyPair(
                          value: EncodableBodyValue(
                            RestaurantName(name: restaurantEnglishName),
                          ),
                        ),
                      ]);
                      if (context.mounted) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(Routes.restaurantInputMode),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showErrorOnSnackBar(context, e);
                      }
                    }
                  },
                  child: Text("Upload"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class RestaurantName extends Encodable {
  final String name;
  RestaurantName({required this.name});

  @override
  Map<String, dynamic> toJson() => {"restaurant name": name};
}

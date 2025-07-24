import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:ukopenrice/models/http_client.dart';

class UploadPhotos extends StatefulWidget {
  const UploadPhotos({super.key});

  @override
  State<UploadPhotos> createState() => _UploadPhotosState();
}

final class _UploadPhotosState extends State<UploadPhotos> {
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
                        BodyPair(
                          key: "myImage",
                          value: ImagesBodyValue(_selectedImages),
                        ),
                        BodyPair(
                          key: "restaurant info",
                          value: EncodableBodyValue(
                            RestaurantName(name: restaurantEnglishName),
                          ),
                        ),
                      ]);
                      // if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
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

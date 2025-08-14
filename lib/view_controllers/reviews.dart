import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'dart:io';
import 'package:ukopenrice/routes.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  ReviewFormState createState() => ReviewFormState();
}

class ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final httpClient = Httpclient.shared;
  final overallRating = "overall_rating";
  List<XFile> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write Review")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('restaurant_name', 'Restaurant Name', true),
              _startRatingRow(overallRating, 'Overall Rating', required: true),
              _startRatingRow('taste', 'Taste Rating'),
              _startRatingRow('decor', 'Decor Rating'),
              _startRatingRow('service', 'Service Rating'),
              _startRatingRow('hygiene', 'Hygiene Rating'),
              _startRatingRow('value', 'Value Rating'),

              _buildTextField('title', 'Title', true),
              _buildTextField('review', 'Review', true, maxLines: 5),

              _buildDatePicker('date_of_visit', 'Date of Visit'),
              _buildNumberField(
                'waiting_time',
                'Waiting Time (minutes)',
                false,
              ),
              _buildDropdown('dining_method', 'Dining Method', [
                'Dine-in',
                'Takeaway',
                'Delivery',
              ]),
              _buildTextField('spending_per_head', 'Spending Per Head', false),
              _buildTextField(
                'recommended_dishes',
                'Recommended Dishes',
                false,
              ),
              if (_selectedImages.isEmpty) SizedBox(height: 50),

              SizedBox(
                height: _selectedImages.isEmpty ? 50 : 300,
                child: UploadImageComponent(
                  selectedImages: _selectedImages,
                  onChanged: (selectedImages) {
                    setState(() {
                      _selectedImages = selectedImages;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (httpClient.username.isNotEmpty &&
                        _formData[overallRating] != null) {
                      _formData["user"] = httpClient.username;
                      final wrappedMap = MapEncodable(value: _formData);
                      await httpClient.postReview([
                        BodyPair(value: EncodableBodyValue(wrappedMap)),
                        BodyPair(
                          value: ImagesBodyValue.fromXFiles(_selectedImages),
                        ),
                      ]);
                      if (context.mounted) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(Routes.homeScreen),
                        );
                      }
                    } else {
                      showErrorOnSnackBar(
                        context,
                        '"Overall rating" can\'t be empty.',
                      );
                    }
                  }
                },
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _startRatingRow(String key, String title, {bool required = false}) {
    final int? value = _formData[key];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(title)),
        StarRating(
          initialRating: value ?? 0,
          onRatingChanged: (value) {
            setState(() {
              _formData[key] = value;
            });
          },
        ),
        if (required && _formData[key] == null) ...[
          SizedBox(width: 10),
          Text("Required"),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    bool required, {
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          required && (value == null || value.isEmpty) ? 'Required' : null,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _formData[key] = value;
        }
      },
      maxLines: maxLines,
    );
  }

  Widget _buildNumberField(String key, String label, bool required) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) return 'Required';
        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
          return 'Must be a number';
        }
        return null;
      },
      onSaved: (value) {
        // final result = int.parse(value);
        if (value != null && value.isNotEmpty) {
          _formData[key] = int.parse(value);
        }
      },
    );
  }

  Widget _buildDropdown(String key, String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: options
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: (value) => _formData[key] = value,
    );
  }

  Widget _buildDatePicker(String key, String label) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formData[key] != null ? "${_formData[key]}" : 'Select $label',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2000),
              lastDate: now,
            );
            if (picked != null) {
              setState(() {
                _formData[key] = picked.toUtc().toIso8601String();
              });
            }
          },
        ),
      ],
    );
  }
}

class ReviewDetails extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewDetails({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField('Restaurant Name', review['restaurant_name']),
          // _buildField('User', review['user']),
          _buildField('English Title', review['english_title']),
          _buildField('Chinese Title', review['chinese_title']),
          _buildField('English Review', review['english_review']),
          _buildField('Chinese Review', review['chinese_review']),
          _buildField('Overall Rating', review['overall_rating']),
          _buildField('Taste', review['taste']),
          _buildField('Decor', review['decor']),
          _buildField('Service', review['service']),
          _buildField('Hygiene', review['hygiene']),
          _buildField('Value', review['value']),
          _buildField('Date of Visit', review['date_of_visit']),
          _buildField('Waiting Time', review['waiting_time']),
          _buildField('Dining Method', review['dining_method']),
          _buildField('Spending Per Head', review['spending_per_head']),
          _buildField(
            'English Recommended Dishes',
            review['english_recommended_dishes'],
          ),
          _buildField(
            'Chinese Recommended Dishes',
            review['chinese_recommended_dishes'],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, dynamic value) {
    return value == null || value.toString().isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value.toString()),
                ],
              ),
            ),
          );
  }
}

class StarRating extends StatefulWidget {
  final int maxStars;
  final int initialRating;
  final ValueChanged<int> onRatingChanged;

  const StarRating({
    super.key,
    this.maxStars = 5,
    this.initialRating = 0,
    required this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  void _updateRating(int rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        final isSelected = index < _currentRating;
        return SizedBox(
          width: 30,
          height: 35,
          child: IconButton(
            icon: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              if (index == 0 && _currentRating == 1) {
                _updateRating(0);
              } else {
                _updateRating(index + 1);
              }
            },
            splashRadius: 20,
          ),
        );
      }),
      // ..insert(
      //   0,
      //   IconButton(
      //     // For "0 stars" reset
      //     icon: const Icon(Icons.clear, color: Colors.grey),
      //     onPressed: () => _updateRating(0),
      //     splashRadius: 20,
      //   ),
      // ),
    );
  }
}

class UploadImageComponent extends StatefulWidget {
  final List<XFile> selectedImages;
  final void Function(List<XFile>) onChanged;

  const UploadImageComponent({
    super.key,
    required this.selectedImages,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _UploadImageComponentState();
}

class _UploadImageComponentState extends State<UploadImageComponent> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.selectedImages.isNotEmpty)
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.selectedImages.length,
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
                    File(widget.selectedImages[index].path),
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
                widget.onChanged(selectedImage);
              },
              child: Text("Select Image"),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await httpClient.uploadRestaurantImages([
            //         BodyPair(
            //           key: "myImage",
            //           value: ImagesBodyValue(_selectedImages),
            //         ),
            //         BodyPair(
            //           key: "restaurant info",
            //           value: EncodableBodyValue(
            //             RestaurantName(name: restaurantEnglishName),
            //           ),
            //         ),
            //       ]);
            //       if (context.mounted) {
            //         Navigator.Until(
            //           context,
            //           ModalRoute.withName(Routes.restaurantInputMode),
            //         );
            //       }
            //     } catch (e) {
            //       if (context.mounted) {
            //         showErrorOnSnackBar(context, e);
            //       }
            //     }
            //   },
            //   child: Text("Upload"),
            // ),
          ],
        ),
      ],
    );
  }
}

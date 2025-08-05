import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ukopenrice/models/http_client.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  ReviewFormState createState() => ReviewFormState();
}

class ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final httpClient = Httpclient.shared;
  // void Function(Map<String, dynamic>) onSubmit = (_) {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('restaurant_name', 'Restaurant Name', true),
              _buildTextField('user', 'User Name', true),
              _buildTextField('title', 'Title', false),
              _buildTextField('review', 'Review', false, maxLines: 5),
              _buildNumberField('overall_rating', 'Overall Rating (1-5)', true),
              _buildNumberField('taste', 'Taste Rating (1-5)', false),
              _buildNumberField('decor', 'Decor Rating (1-5)', false),
              _buildNumberField('service', 'Service Rating (1-5)', false),
              _buildNumberField('hygiene', 'Hygiene Rating (1-5)', false),
              _buildNumberField('value', 'Value Rating (1-5)', false),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // onSubmit(_formData);
                    httpClient.postReview(_formData);
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
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _formData[key] = picked.toIso8601String();
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
          _buildField('User', review['user']),
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

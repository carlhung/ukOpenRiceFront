import 'package:flutter/material.dart';

final class _RestaurantDetailsWidgetState
    extends State<RestaurantDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name, style: Theme.of(context).textTheme.bodyMedium),
          Text(widget.address, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            widget.phoneNumber,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            widget.cuisineType,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Rating: ${widget.rating}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.imageURLs.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: widget.imageURLs.length,
                itemBuilder: (context, index) {
                  return Image.network(widget.imageURLs[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

final class RestaurantDetailsWidget extends StatefulWidget {
  final String name;
  final String id;
  final String address;
  final String phoneNumber;
  final String cuisineType;
  final String direction;
  final List<(String, String)> openHours;
  final int rating;
  final List<String> imageURLs;
  final List<String> paymentMethod;
  final List<String> otherInfo;

  const RestaurantDetailsWidget({
    super.key,
    required this.name,
    required this.id,
    required this.address,
    required this.phoneNumber,
    required this.cuisineType,
    required this.rating,
    required this.openHours,
    required this.paymentMethod,
    this.imageURLs = const [],
    this.direction = '',
    this.otherInfo = const [],
  });

  @override
  State<RestaurantDetailsWidget> createState() {
    return _RestaurantDetailsWidgetState();
  }
}

final class RestaurantDetails {
  final String name;
  final String id;
  final String address;
  final String phoneNumber;
  final String cuisineType;
  final String direction;
  final List<(String, String)> openHours;
  final int rating;
  final List<String> imageURLs;
  final List<String> paymentMethod;
  final List<String> otherInfo;

  const RestaurantDetails({
    required this.name,
    required this.id,
    required this.address,
    required this.phoneNumber,
    required this.cuisineType,
    required this.rating,
    required this.openHours,
    required this.paymentMethod,
    this.imageURLs = const [],
    this.direction = '',
    this.otherInfo = const [],
  });
}

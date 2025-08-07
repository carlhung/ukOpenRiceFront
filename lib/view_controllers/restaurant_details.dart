// import 'package:flutter/material.dart';

// final class _RestaurantDetailsWidgetState
//     extends State<RestaurantDetailsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.name, style: Theme.of(context).textTheme.bodyMedium),
//           Text(widget.address, style: Theme.of(context).textTheme.bodyMedium),
//           Text(
//             widget.phoneNumber,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           Text(
//             widget.cuisineType,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           Text(
//             'Rating: ${widget.rating}',
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           if (widget.imageURLs.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: widget.imageURLs.length,
//                 itemBuilder: (context, index) {
//                   return Image.network(widget.imageURLs[index]);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// final class RestaurantDetailsWidget extends StatefulWidget {
//   final String name;
//   final String id;
//   final String address;
//   final String phoneNumber;
//   final String cuisineType;
//   final String direction;
//   final List<(String, String)> openHours;
//   final int rating;
//   final List<String> imageURLs;
//   final List<String> paymentMethod;
//   final List<String> otherInfo;

//   const RestaurantDetailsWidget({
//     super.key,
//     required this.name,
//     required this.id,
//     required this.address,
//     required this.phoneNumber,
//     required this.cuisineType,
//     required this.rating,
//     required this.openHours,
//     required this.paymentMethod,
//     this.imageURLs = const [],
//     this.direction = '',
//     this.otherInfo = const [],
//   });

//   @override
//   State<RestaurantDetailsWidget> createState() {
//     return _RestaurantDetailsWidgetState();
//   }
// }

// final class RestaurantDetails {
//   final String name;
//   final String id;
//   final String address;
//   final String phoneNumber;
//   final String cuisineType;
//   final String direction;
//   final List<(String, String)> openHours;
//   final int rating;
//   final List<String> imageURLs;
//   final List<String> paymentMethod;
//   final List<String> otherInfo;

//   const RestaurantDetails({
//     required this.name,
//     required this.id,
//     required this.address,
//     required this.phoneNumber,
//     required this.cuisineType,
//     required this.rating,
//     required this.openHours,
//     required this.paymentMethod,
//     this.imageURLs = const [],
//     this.direction = '',
//     this.otherInfo = const [],
//   });
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // optional for links
import 'package:ukopenrice/models/resturant_info.dart';

class RestaurantDetails extends StatelessWidget {
  final ResturantInfo restaurant;

  const RestaurantDetails({super.key, required this.restaurant});

  Widget _buildField(String label, String value) {
    if (value.trim().isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.restuarantEnglishName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (restaurant.restuarantChineseName.isNotEmpty)
            Text(
              restaurant.restuarantChineseName,
              style: TextStyle(fontSize: 16),
            ),

          const SizedBox(height: 12),

          _buildField("Cuisine", restaurant.cuisine),
          _buildField("Description", restaurant.description),
          _buildField("City", restaurant.city),
          _buildField("Phone", restaurant.phone),
          _buildField("Email", restaurant.email),
          _buildField("Website", restaurant.web),
          _buildField("Facebook", restaurant.facebook),
          _buildField("Instagram", restaurant.instagram),
          _buildField("Price Range", restaurant.priceRange),
          _buildField("Currency", restaurant.currencyCode),
          _buildField("Payments", restaurant.selectedPayments.join(', ')),
          _buildField("Extra Info", restaurant.extraInfo),

          _buildField(
            "Access Reservation",
            restaurant.accessReservation ? "Yes" : "No",
          ),
          _buildField("Takeaway", restaurant.takeaway ? "Yes" : "No"),
          _buildField("Delivery", restaurant.delivery ? "Yes" : "No"),

          const SizedBox(height: 12),

          // Show address as clickable link or inline map
          Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(restaurant.map);
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
            },
            child: Text(
              restaurant.address,
              style: TextStyle(color: Colors.blue),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

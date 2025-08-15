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

class RestaurantDetails extends StatefulWidget {
  const RestaurantDetails({super.key});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  ResturantInfo? restaurant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    restaurant = ModalRoute.of(context)?.settings.arguments as ResturantInfo;
  }

  Widget _buildField(String label, String value, {IconData? icon}) {
    if (value.trim().isEmpty) return SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.blue.shade600),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHours(ResturantInfo restaurant) {
    if (restaurant.returnedOpeningHours.isEmpty) return SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Opening Hours",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...restaurant.returnedOpeningHours.map((hour) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _capitalizeFirst(hour.dayOfWeek),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${hour.openTime} - ${hour.closeTime}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ResturantInfo restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          restaurant.restuarantEnglishName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (restaurant.restuarantChineseName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      restaurant.restuarantChineseName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Basic Info Section
          _buildField("Cuisine", restaurant.cuisine, icon: Icons.restaurant),
          _buildField(
            "Description",
            restaurant.description,
            icon: Icons.description,
          ),
          _buildField("City", restaurant.city, icon: Icons.location_city),
          _buildField("Phone", restaurant.phone, icon: Icons.phone),
          _buildField("Email", restaurant.email, icon: Icons.email),
          _buildField("Website", restaurant.web, icon: Icons.web),
          _buildField("Facebook", restaurant.facebook, icon: Icons.facebook),
          _buildField(
            "Instagram",
            restaurant.instagram,
            icon: Icons.camera_alt,
          ),

          // Price & Payment Section
          _buildField(
            "Price Range",
            restaurant.priceRange,
            icon: Icons.attach_money,
          ),
          _buildField(
            "Currency",
            restaurant.currencyCode,
            icon: Icons.monetization_on,
          ),
          _buildField(
            "Payments",
            restaurant.selectedPayments.map((e) => e.name).toList().join(", "),
            icon: Icons.payment,
          ),

          // Services Section
          _buildField(
            "Access Reservation",
            restaurant.accessReservation ? "Yes" : "No",
            icon: Icons.event_available,
          ),
          _buildField(
            "Takeaway",
            restaurant.takeaway ? "Yes" : "No",
            icon: Icons.takeout_dining,
          ),
          _buildField(
            "Delivery",
            restaurant.delivery ? "Yes" : "No",
            icon: Icons.delivery_dining,
          ),

          _buildField("Extra Info", restaurant.extraInfo, icon: Icons.info),

          // Opening Hours Section
          _buildOpeningHours(restaurant),

          // Location Section
          if (restaurant.address.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        if (restaurant.map.isNotEmpty) {
                          final url = Uri.parse(restaurant.map);
                          if (await canLaunchUrl(url)) {
                            launchUrl(url);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.address,
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details")),
      body: (restaurant != null) ? _buildBody(restaurant!) : Container(),
    );
  }
}

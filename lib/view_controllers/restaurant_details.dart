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
import 'package:ukopenrice/view_controllers/home_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // optional for links
import 'package:ukopenrice/models/resturant_info.dart';

class RestaurantDetails extends StatefulWidget {
  const RestaurantDetails({super.key});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails>
    with SingleTickerProviderStateMixin {
  ResturantInfo? restaurant;
  SearchResult? searchResult;
  late TabController _tabController;
  bool _photosTabLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_photosTabLoaded) {
      setState(() {
        _photosTabLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final (restaurant, searchResult) =
        ModalRoute.of(context)?.settings.arguments
            as (ResturantInfo, SearchResult);
    this.restaurant = restaurant;
    this.searchResult = searchResult;
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

  // Widget _buildBody(ResturantInfo restaurant) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Header Card
  //         Card(
  //           elevation: 4,
  //           margin: const EdgeInsets.only(bottom: 16),
  //           child: Container(
  //             width: double.infinity,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               gradient: LinearGradient(
  //                 colors: [Colors.blue.shade50, Colors.blue.shade100],
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //               ),
  //             ),
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.restaurant_menu,
  //                       color: Colors.blue.shade700,
  //                       size: 28,
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: Text(
  //                         restaurant.restuarantEnglishName,
  //                         style: Theme.of(context).textTheme.headlineSmall
  //                             ?.copyWith(
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.blue.shade800,
  //                             ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 if (restaurant.restuarantChineseName.isNotEmpty) ...[
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     restaurant.restuarantChineseName,
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       color: Colors.blue.shade600,
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           ),
  //         ),

  //         // Basic Info Section
  //         _buildField("Cuisine", restaurant.cuisine, icon: Icons.restaurant),
  //         _buildField(
  //           "Description",
  //           restaurant.description,
  //           icon: Icons.description,
  //         ),
  //         _buildField("City", restaurant.city, icon: Icons.location_city),
  //         _buildField("Phone", restaurant.phone, icon: Icons.phone),
  //         _buildField("Email", restaurant.email, icon: Icons.email),
  //         _buildField("Website", restaurant.web, icon: Icons.web),
  //         _buildField("Facebook", restaurant.facebook, icon: Icons.facebook),
  //         _buildField(
  //           "Instagram",
  //           restaurant.instagram,
  //           icon: Icons.camera_alt,
  //         ),

  //         // Price & Payment Section
  //         _buildField(
  //           "Price Range",
  //           restaurant.priceRange,
  //           icon: Icons.attach_money,
  //         ),
  //         _buildField(
  //           "Currency",
  //           restaurant.currencyCode,
  //           icon: Icons.monetization_on,
  //         ),
  //         _buildField(
  //           "Payments",
  //           restaurant.selectedPayments.map((e) => e.name).toList().join(", "),
  //           icon: Icons.payment,
  //         ),

  //         // Services Section
  //         _buildField(
  //           "Access Reservation",
  //           restaurant.accessReservation ? "Yes" : "No",
  //           icon: Icons.event_available,
  //         ),
  //         _buildField(
  //           "Takeaway",
  //           restaurant.takeaway ? "Yes" : "No",
  //           icon: Icons.takeout_dining,
  //         ),
  //         _buildField(
  //           "Delivery",
  //           restaurant.delivery ? "Yes" : "No",
  //           icon: Icons.delivery_dining,
  //         ),

  //         _buildField("Extra Info", restaurant.extraInfo, icon: Icons.info),

  //         // Opening Hours Section
  //         _buildOpeningHours(restaurant),

  //         // Location Section
  //         if (restaurant.address.isNotEmpty)
  //           Card(
  //             margin: const EdgeInsets.symmetric(vertical: 8),
  //             elevation: 2,
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Icon(
  //                         Icons.location_on,
  //                         color: Colors.blue.shade600,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         "Location",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 16,
  //                           color: Colors.grey.shade800,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 12),
  //                   GestureDetector(
  //                     onTap: () async {
  //                       if (restaurant.map.isNotEmpty) {
  //                         final url = Uri.parse(restaurant.map);
  //                         if (await canLaunchUrl(url)) {
  //                           launchUrl(url);
  //                         }
  //                       }
  //                     },
  //                     child: Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.blue.shade50,
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.blue.shade200),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               restaurant.address,
  //                               style: TextStyle(
  //                                 color: Colors.blue.shade800,
  //                                 fontSize: 16,
  //                               ),
  //                             ),
  //                           ),
  //                           Icon(
  //                             Icons.open_in_new,
  //                             color: Colors.blue.shade600,
  //                             size: 20,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),

  //         const SizedBox(height: 20),
  //       ],
  //     ),
  //   );
  // }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
    }

    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
    }

    int remainingStars = 5 - stars.length;
    for (int i = 0; i < remainingStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
    }

    return Row(children: stars);
  }

  Widget _buildHeaderCard(ResturantInfo restaurant) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            if (searchResult != null) ...[
              const SizedBox(height: 12),
              // City and Cuisine
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${searchResult!.city} • ${searchResult!.cuisine}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Rating and Reviews
              if (searchResult!.avgRating != null) ...[
                Row(
                  children: [
                    _buildStarRating(searchResult!.avgRating!),
                    const SizedBox(width: 8),
                    Text(
                      '${searchResult!.avgRating!.toStringAsFixed(1)} (${searchResult!.totalReviews} reviews)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Price Range
              if (searchResult!.priceRange.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '£${searchResult!.priceRange}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ResturantInfo restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildOpeningHours(restaurant),
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

  Widget _buildPhotosTab(ResturantInfo restaurant) {
    if (!_photosTabLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading photos...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (restaurant.originalImages.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: restaurant.originalImages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    restaurant.originalImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No photos available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Menu coming soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Reviews coming soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Details")),
      body: Column(
        children: [
          // Header Card
          _buildHeaderCard(restaurant!),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue.shade700,
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Photos"),
              Tab(text: "Menu"),
              Tab(text: "Reviews"),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(restaurant!),
                _buildPhotosTab(restaurant!),
                _buildMenuTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

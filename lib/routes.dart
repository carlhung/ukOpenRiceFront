import 'package:flutter/material.dart';
import 'package:ukopenrice/view_controllers/remove_restaurant_info.dart';
import 'package:ukopenrice/view_controllers/restaurant_details.dart';
import 'package:ukopenrice/view_controllers/restaurant_input_mode.dart';
import 'package:ukopenrice/view_controllers/reviews.dart';
import 'view_controllers/home_screen.dart';
import 'view_controllers/restaurant_upload_form.dart';

class Routes {
  // Route name constants
  static const String homeScreen = '/';
  static const String addRestaurantInfoScreen = '/add_restaurant_information';
  static const String restaurantInputMode = '/restaurant_input_mode';
  static const String removeRestaurantInfo = '/remove_restaurant_info';
  static const String writeReview = '/write_review';
  static const String restaurantDetails = '/restaurant_details';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) => const HomeScreen(),
    addRestaurantInfoScreen: (context) => const RestaurantUploadForm(),
    restaurantInputMode: (context) => const RestaurantInputMode(),
    removeRestaurantInfo: (context) => const RemoveRestaurantInfo(),
    writeReview: (context) => const ReviewForm(),
    restaurantDetails: (context) => const RestaurantDetails(),
  };
}

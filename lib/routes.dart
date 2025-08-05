import 'package:flutter/material.dart';
import 'package:ukopenrice/view_controllers/add_restaurant_information.dart';
import 'package:ukopenrice/view_controllers/remove_restaurant_info.dart';
import 'package:ukopenrice/view_controllers/restaurant_input_mode.dart';
import 'package:ukopenrice/view_controllers/reviews.dart';
import 'package:ukopenrice/view_controllers/upload_photos.dart';
import 'view_controllers/home_screen.dart';

class Routes {
  // Route name constants
  static const String uploadPhotoScreen = '/upload_restaurant_photos';
  static const String homeScreen = '/';
  static const String addRestaurantInfoScreen = '/add_restaurant_information';
  static const String restaurantInputMode = '/restaurant_input_mode';
  static const String removeRestaurantInfo = '/remove_restaurant_info';
  static const String writeReview = 'write_review';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) =>
        const HomeScreen(), //const RestaurantHomePage(), //const HomeScreen(),
    addRestaurantInfoScreen: (context) => const AddResturantInformation(),
    uploadPhotoScreen: (context) => const UploadPhotos(),
    restaurantInputMode: (context) => const RestaurantInputMode(),
    removeRestaurantInfo: (context) => const RemoveRestaurantInfo(),
    writeReview: (context) => const ReviewForm(),
  };
}

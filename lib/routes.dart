import 'package:flutter/material.dart';
import 'package:ukopenrice/view_controllers/add_restaurant_information.dart';
import 'package:ukopenrice/view_controllers/log_in.dart';
import 'package:ukopenrice/view_controllers/remove_restaurant_info.dart';
import 'package:ukopenrice/view_controllers/restaurant_input_mode.dart';
import 'package:ukopenrice/view_controllers/upload_photos.dart';
import 'view_controllers/home_screen.dart';

class Routes {
  // Route name constants
  static const String uploadPhotoScreen = '/upload_restaurant_photos';
  static const String homeScreen = '/';
  static const String logInScreen = '/login';
  static const String addRestaurantInfoScreen = '/add_restaurant_information';
  static const String restaurantInputMode = 'Restaurant_input_mode';
  static const String removeRestaurantInfo = 'remove_restaurant_info';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) => const HomeScreen(),
    logInScreen: (context) => const LogIn(),
    addRestaurantInfoScreen: (context) => const AddResturantInformation(),
    uploadPhotoScreen: (context) => const UploadPhotos(),
    restaurantInputMode: (context) => const RestaurantInputMode(),
    removeRestaurantInfo: (context) => const RemoveRestaurantInfo(),
  };
}

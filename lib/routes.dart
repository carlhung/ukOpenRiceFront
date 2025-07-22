import 'package:flutter/material.dart';
import 'package:ukopenrice/view_controllers/add_restaurant_information.dart';
import 'package:ukopenrice/view_controllers/log_in.dart';
import 'view_controllers/home_screen.dart';

class Routes {
  // Route name constants
  static const String homeScreen = '/';
  static const String logInScreen = '/login';
  static const String addRestaurantInfoScreen = '/add_restaurant_information';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) => const HomeScreen(),
    logInScreen: (context) => const LogIn(),
    addRestaurantInfoScreen: (context) => const AddResturantInformation(),
  };
}

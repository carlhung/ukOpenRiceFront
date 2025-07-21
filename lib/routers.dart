import 'package:flutter/material.dart';
import 'package:ukopenrice/view_controllers/log_in.dart';
import 'view_controllers/homeScreen.dart';

class Routes {
  // Route name constants
  static const String homeScreen = '/';
  static const String logInScreen = '/login';
  // static const String bookScreen = '/book';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) => const HomeScreen(),
    logInScreen: (context) => const LogIn(),
    // bookScreen: (context) => const BookScreen(),
  };
}

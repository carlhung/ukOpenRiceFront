import 'package:flutter/material.dart';
import 'homeScreen.dart';

class Routes {
  // Route name constants
  static const String homeScreen = '/';
  // static const String bookScreen = '/book';

  /// The map used to define routes to be provided in [MaterialApp]
  static final Map<String, WidgetBuilder> allRoutes = {
    homeScreen: (context) => const HomeScreen(),
    // bookScreen: (context) => const BookScreen(),
  };
}

import 'package:flutter/material.dart';
import 'package:ukopenrice/routes.dart';

final class RestaurantInputMode extends StatelessWidget {
  const RestaurantInputMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.removeRestaurantInfo);
                  },
                  child: Text("Remove"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.addRestaurantInfoScreen,
                    );
                  },
                  child: Text("Add"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.pushNamed(context, Routes.addRestaurantInfoScreen);
              },
              child: Text("upload restuarant image"),
            ),
          ],
        ),
      ),
    );
  }
}

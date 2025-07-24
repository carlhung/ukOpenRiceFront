import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/models/http_client.dart';

class RemoveRestaurantInfo extends StatefulWidget {
  const RemoveRestaurantInfo({super.key});

  @override
  State<RemoveRestaurantInfo> createState() => _RemoveRestaurantInfoState();
}

final class _RemoveRestaurantInfoState extends State<RemoveRestaurantInfo> {
  final httpClient = Httpclient.shared;
  List<String> restaurantNames = [];

  _RemoveRestaurantInfoState() {
    try {
      httpClient.getListOfRestaurants().then((names) {
        setState(() {
          restaurantNames = names;
        });
      });
    } catch (e) {
      if (context.mounted) {
        showErrorOnSnackBar(context, e);
      }
    }
  }

  Future<void> removeRestaurant(int index) async {
    final name = restaurantNames[index];
    await httpClient.removeRestaurant(name);
    setState(() {
      restaurantNames.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Remove Mode")),
      body: Center(
        child: ListView.builder(
          itemCount: restaurantNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(restaurantNames[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async => await removeRestaurant(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

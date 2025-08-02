import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

enum LoginState { skipped, loggedIn, loggingIn, unknown }

class _HomeScreenState extends State<HomeScreen> {
  LoginState _loginState = LoginState.unknown;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var cuisine = '';
  var city = '';
  var stars = '';
  var isOpenNowSelected = false;
  final httpClient = Httpclient.shared;
  // bool isFilterApplied = false;
  List<String> cityList = [];
  List<String> cuisineList = [];
  final starList = ['★☆☆☆☆', '★★☆☆☆', '★★★☆☆', '★★★★☆', '★★★★★'];

  @override
  void initState() {
    super.initState();
    httpClient
        .filterData()
        .then((data) {
          if (context.mounted) {
            setState(() {
              cityList = data.$1;
              cuisineList = data.$2;
              // starList = data['stars'] as List<String>;
            });
          }
        })
        .catchError((e) {
          if (context.mounted) {
            showErrorOnSnackBar(context, e);
          }
        });
  }

  @override
  void dispose() {
    for (var controller in [usernameController, passwordController]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: Center(
        child: () {
          switch (_loginState) {
            case LoginState.skipped:
            case LoginState.loggedIn:
              return _homeScreen(context);
            case LoginState.unknown:
              return _logStateScreen(context);
            case LoginState.loggingIn:
              return _loginScreen(context);
          }
        }(),
      ),
    );
  }

  Widget _logStateScreen(BuildContext context) {
    return Column(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loginState = LoginState.skipped;
                });
              },
              child: const Text("Skip Login"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loginState = LoginState.loggingIn;
                });
                // Navigator.pushNamed(context, Routes.logInScreen);
              },
              child: const Text("Log In"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loginScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("User Name:", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "user name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            Text("Password:", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            // Handle login logic here
            final username = usernameController.text;
            final password = passwordController.text;
            if (username.isNotEmpty && password.isNotEmpty) {
              try {
                await httpClient.logIn(username, password);
                if (context.mounted) {
                  setState(() {
                    _loginState = LoginState.loggedIn;
                  });
                  if (httpClient.isAdmin) {
                    Navigator.pushNamed(context, Routes.restaurantInputMode);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  showErrorOnSnackBar(context, e);
                }
              }

              // httpClient.logIn(username, password).then((_) {
              //   if (context.mounted) {
              //     Navigator.pushNamed(context, Routes.addRestaurantInfoScreen);
              //   }
              // });
            }
          },
          child: Text("Log In"),
        ),
      ],
    );
  }

  void _showPicker(
    BuildContext context,
    List<String> data,
    void Function(String) callback,
  ) {
    Picker(
      adapter: PickerDataAdapter<String>(pickerData: data),
      title: Text('Select an option'),
      onConfirm: (Picker picker, List<int> value) {
        callback(picker.getSelectedValues().first);
      },
    ).showModal(context);
  }

  Widget _homeScreen(BuildContext context) {
    return Column(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createTextButton(city.isEmpty ? "City" : city, () {
                _showPicker(context, cityList, (str) {
                  setState(() {
                    city = str;
                  });
                });
              }),
              _createTextButton(cuisine.isEmpty ? "Cuisine" : cuisine, () {
                _showPicker(context, cuisineList, (str) {
                  setState(() {
                    cuisine = str;
                  });
                });
              }),
              _createTextButton(stars.isEmpty ? "Rating" : stars, () {
                _showPicker(context, starList, (str) {
                  setState(() {
                    stars = str;
                  });
                });
              }),
              _createTextButton(
                "Open Now",
                () {
                  setState(() {
                    isOpenNowSelected = !isOpenNowSelected;
                  });
                },
                backgroundColor: isOpenNowSelected
                    ? const Color.fromARGB(255, 192, 6, 3)
                    : const Color.fromARGB(255, 246, 243, 243),
              ),
              _createTextButton("Apply Filter", () {
                setState(() {
                  // TODO: call API to get data
                });
              }, backgroundColor: const Color.fromARGB(255, 192, 6, 3)),
              _createTextButton("Reset", () {
                setState(() {
                  _reset();
                });
              }, backgroundColor: Colors.white),
            ],
          ),
        ),
        _sectionTitle("Discover By Location"),
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _createCityAndNameButtonList(),
        ),
        _sectionTitle("Popular Cuisines"),
        _createCuisineList(),
      ],
    );
  }

  void _reset() {
    city = '';
    cuisine = '';
    stars = '';
    isOpenNowSelected = false;
  }

  Widget _cityButton(String city) {
    final encodedCity = httpClient.getCityURL(city);
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FadeInImage.assetNetwork(
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              placeholder: 'assets/city_placeholder.jpg',
              image: encodedCity,
              imageErrorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/city_placeholder.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(city, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  List<Widget> _createCityAndNameButtonList() {
    return cityList.map((city) {
      return _cityButton(city);
    }).toList();
  }

  Widget _createTextButton(
    String label,
    void Function() completionHandler, {
    Color backgroundColor = const Color.fromARGB(255, 246, 243, 243),
  }) {
    // return Chip(
    //   label: Text(label),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //   backgroundColor: Colors.grey.shade200,
    // );

    return GestureDetector(
      onTap: completionHandler,
      child: Chip(
        label: Text(label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _createCuisineList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cuisineList.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.brown.shade100,
                child: Text(
                  cuisineList[index][0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Text(cuisineList[index], style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restaurantFeatureCard(String imagePath, String name) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/restaurant.jpg',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Yang Sing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_half, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text('4.3 (217)'),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Manchester', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

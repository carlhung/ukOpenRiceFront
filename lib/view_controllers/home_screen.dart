import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/models/pagination.dart';
import 'package:ukopenrice/models/settings.dart';
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
  int? starsIndex;
  String priceRange = '';
  var isOpenNowSelected = false;
  final httpClient = Httpclient.shared;
  final settings = Settings.shared;
  // bool isFilterApplied = false;
  List<String> cityList = [];
  List<String> cuisineList = [];
  final starList = ['★☆☆☆☆', '★★☆☆☆', '★★★☆☆', '★★★★☆', '★★★★★'];
  List<SearchResult> searchResults = [];
  int page = 1;
  Pagination? pagination;

  //   List<String> starList() {
  //   const String star = "★";
  //   const String nonStar = "☆";

  //   return List.generate(5, (index) {
  //     int numOfStar = index + 1;
  //     return star * numOfStar + nonStar * (5 - numOfStar);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // httpClient
    //     .filterData()
    //     .then((data) {
    //       if (context.mounted) {
    //         setState(() {
    //           cityList = data.$1;
    //           cuisineList = data.$2;
    //           // starList = data['stars'] as List<String>;
    //         });
    //       }
    //     })
    //     .catchError((e) {
    //       if (context.mounted) {
    //         showErrorOnSnackBar(context, e);
    //       }
    //     });
  }

  Future<void> updateData(LoginState state) async {
    final data = await httpClient.filterData();
    setState(() {
      cityList = data.$1;
      cuisineList = data.$2;
      _loginState = state;
      // starList = data['stars'] as List<String>;
    });
    // .then((data) {
    //   if (context.mounted) {
    //     setState(() {
    //       cityList = data.$1;
    //       cuisineList = data.$2;
    //       // starList = data['stars'] as List<String>;
    //     });
    //   }
    // })
    // .catchError((e) {
    //   if (context.mounted) {
    //     showErrorOnSnackBar(context, e);
    //   }
    // });
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
              onPressed: () async {
                // updateData();
                // setState(() {
                //   _loginState = LoginState.skipped;
                // });
                await updateData(LoginState.skipped);
              },
              child: const Text("Skip Login"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _loginState = LoginState.loggingIn;
                });
                // Navigator.pushNamed(context, Routes.logInScreen);
                // await updateData(LoginState.loggingIn);
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
                  // setState(() {
                  //   _loginState = LoginState.loggedIn;
                  // });
                  await updateData(LoginState.loggedIn);
                  if (context.mounted && httpClient.isAdmin) {
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
              _createTextButton(
                starsIndex == null ? "Rating" : starList[starsIndex!],
                () {
                  _showPicker(context, starList, (str) {
                    setState(() {
                      final index = starList.indexOf(str);
                      starsIndex = index;
                    });
                  });
                },
              ),
              _createTextButton(priceRange.isEmpty ? "Price" : priceRange, () {
                _showPicker(
                  context,
                  createPriceRangeList().map((str) => '£$str').toList(),
                  (str) {
                    setState(() {
                      priceRange = str;
                    });
                  },
                );
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
              _createTextButton("Apply Filter", () async {
                _handleSearch();
              }, backgroundColor: const Color.fromARGB(255, 192, 6, 3)),
              _createTextButton("Reset", () {
                setState(() {
                  _reset();
                });
              }, backgroundColor: Colors.white),
            ],
          ),
        ),
        //   ...(searchResults.isEmpty
        // ? _buildHomeScreenBody()
        // : _buildSearchResults()),
        // if (searchResults.isEmpty) ..._buildHomeScreenBody(),
        ...(searchResults.isEmpty ? _buildHomeScreenBody() : [_buildResults()]),
      ],
    );
  }

  List<Widget> _buildHomeScreenBody() {
    return [
      _sectionTitle("Discover By Location"),
      SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return _cityButton(cityList[index]);
          },
          itemCount: cityList.length,
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
        ),
      ),
      // Row(
      //   spacing: 10,
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: _createCityAndNameButtonList(),
      // ),
      _sectionTitle("Popular Cuisines"),
      _createCuisineList(),
      if (_loginState == LoginState.loggedIn && httpClient.username.isNotEmpty)
        _writeReviewButton(context),
    ];
  }

  Future<void> _handleSearch() async {
    int? rating;
    if (starsIndex != null) rating = starsIndex! + 1;
    final filter = SearchFilter(
      rating,
      city,
      cuisine,
      isOpenNowSelected ? getUTC() : '',
      priceRange.replaceAll('£', ''),
      page,
      settings.pageSize,
    );
    if (isNoFilterAdded) {
      return;
    }

    final (results, pagination) = await httpClient.search(filter);
    setState(() {
      if (results.isNotEmpty) {
        searchResults = results;
        this.pagination = pagination;
      } else {
        _reset();
      }
    });
  }

  bool get isNoFilterAdded {
    return (starsIndex == null &&
        city.isEmpty &&
        cuisine.isEmpty &&
        !isOpenNowSelected &&
        priceRange.isEmpty);
  }

  String getUTC() {
    DateTime utcNow = DateTime.now().toUtc();
    return utcNow.toIso8601String();
  }

  Widget _writeReviewButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_loginState == LoginState.loggedIn &&
            httpClient.username.isNotEmpty) {
          Navigator.pushNamed(context, Routes.writeReview);
        } else {
          showErrorOnSnackBar(context, "Please LogIn");
        }
      },
      child: const Text("write review"),
    );
  }

  void _reset() {
    city = '';
    cuisine = '';
    priceRange = '';
    starsIndex = null;
    isOpenNowSelected = false;
    searchResults = [];
    pagination = null;
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

  Widget _buildResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) =>
            _buildSearchResultRow(searchResults[index]),
      ),
    );
  }

  Widget _buildSearchResultRow(SearchResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildThumbnailWidget(result.name),
        title: Text(
          result.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${result.city} • ${result.cuisine}'),
            if (result.avgRating != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildStarRating(result.avgRating!),
                  const SizedBox(width: 8),
                  Text(
                    '${result.avgRating!.toStringAsFixed(1)} (${result.totalReviews})',
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: result.priceRange.isNotEmpty
            ? Text(
                '£${result.priceRange}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
        onTap: () {
          // Handle restaurant detail navigation
        },
      ),
    );
  }

  Widget _buildThumbnailWidget(String restaurantName) {
    final thumbnailPath = httpClient.getRestaurantProfileThumbnail(
      restaurantName,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey[300],
        child: Image.network(
          thumbnailPath,
          width: 100,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Icon(Icons.restaurant, size: 30, color: Colors.grey[600]);
          },
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.restaurant, size: 30, color: Colors.grey[600]),
        ),
      ),
    );
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
}

T getRandomElement<T>(List<T> list) {
  Random random = Random();

  // Pick a random element
  T randomItem = list[random.nextInt(list.length)];
  return randomItem;
}

class SearchFilter {
  int? rating;
  String city;
  String cuisine;
  String prceRange;
  // Iso8601
  String timeInUTC;
  int page;
  int pageSize;

  SearchFilter(
    this.rating,
    this.city,
    this.cuisine,
    this.timeInUTC,
    this.prceRange,
    this.page,
    this.pageSize,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotEmpty(String key, String value) {
      final v = value.trim();
      if (v.isNotEmpty) data[key] = v;
    }

    addIfNotEmpty('city', city);
    addIfNotEmpty('cuisine', cuisine);
    addIfNotEmpty("time_in_utc", timeInUTC);
    addIfNotEmpty('price_range', prceRange);
    data['page_size'] = pageSize;
    data['page'] = page;
    if (rating != null) data["rating"] = rating;
    return data;
  }
}

class SearchResult {
  final String name;
  final String city;
  final String cuisine;
  final String priceRange;
  final double? avgRating;
  final int totalReviews;

  SearchResult({
    required this.name,
    required this.city,
    required this.cuisine,
    required this.priceRange,
    required this.avgRating,
    required this.totalReviews,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      name: json['name'],
      city: json['city'],
      cuisine: json['cuisine'],
      priceRange: json['price_range'],
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : null,
      totalReviews: json['total_reviews'],
    );
  }
}

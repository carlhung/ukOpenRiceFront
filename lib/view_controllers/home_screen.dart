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
  final httpClient = Httpclient.shared;
  bool isFilterApplied = false;
  List<String> cityList = [
    "London",
    "Manchester",
    "Birmingham",
    "Leeds",
    "Glasgow",
    "Liverpool",
    "Newcastle",
    "Sheffield",
    "Bristol",
    "Nottingham",
    "Cardiff",
    "Edinburgh",
    "Leicester",
    "Coventry",
    "Bradford",
    "Brighton",
    "Hull",
    "Plymouth",
    "Stoke-on-Trent",
    "Wolverhampton",
    "Derby",
    "Swansea",
    "Southampton",
    "Aberdeen",
    "Portsmouth",
    "Northampton",
    "Dundee",
    "Luton",
    "Sunderland",
    "Warrington",
    "Swindon",
    "Reading",
    "Milton Keynes",
    "York",
    "Blackpool",
    "Bolton",
    "Stockport",
    "Bournemouth",
    "Poole",
    "Middlesbrough",
    "Wigan",
    "Huddersfield",
    "Southend-on-Sea",
    "Slough",
    "Cheltenham",
    "Cambridge",
    "Oxford",
    "Exeter",
    "Ipswich",
    "Salisbury",
    "Bath",
    "Chester",
    "Gloucester",
    "Lincoln",
    "Norwich",
    "Wakefield",
    "Belfast",
    "Dublin",
    "Cork",
    "Galway",
    "Limerick",
    "Waterford",
    "Kilkenny",
    "Sligo",
    "Tralee",
    "Letterkenny",
    "Drogheda",
    "Dundalk",
    "Athlone",
  ];
  List<String> cuisineList = [
    "Spaish",
    "Indian",
    "Chinese",
    "Italian",
    "French",
    "Thai",
    "Japanese",
    "Korean",
    "Vietnamese",
    "American",
    "Mexican",
    "Mediterranean",
    "Middle Eastern",
    "Caribbean",
    "African",
    "British",
    "Greek",
    "Turkish",
    "Portuguese",
    "German",
    "Russian",
    "Polish",
    "Czech",
    "Hungarian",
    "Austrian",
    "Belgian",
    "Dutch",
    "Scandinavian",
    "Finnish",
    "Icelandic",
  ];
  List<String> starList = ['★☆☆☆☆', '★★☆☆☆', '★★★☆☆', '★★★★☆', '★★★★★'];

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

  // Expanded(
  //                     child: TextField(
  //                       controller: cuisineCtrllor,
  //                       decoration: InputDecoration(
  //                         labelText: "Cuisine (Required)",
  //                         border: OutlineInputBorder(),
  //                       ),
  //                       readOnly: true,
  //                       onTap: () => _showCuisinePicker(context),
  //                     ),
  //                   ),

  // void _showCuisinePicker(BuildContext context) {
  //   Picker(
  //     adapter: PickerDataAdapter<String>(pickerData: cuisineList),
  //     title: Text('Select a cuisine'),
  //     onConfirm: (Picker picker, List<int> value) {
  //       setState(() {
  //         cuisineCtrllor.text = picker.getSelectedValues().first;
  //       });
  //     },
  //   ).showModal(context);
  // }

  void showPicker(
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
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _createTextFieldButton(
              context,
              cuisine.isEmpty ? "Cuisine" : cuisine,
              cuisineList,
              (str) => setState(() {
                cuisine = str;
              }),
            ),
            _createTextFieldButton(
              context,
              city.isEmpty ? "City" : city,
              cityList,
              (str) => setState(() {
                city = str;
              }),
            ),
            _createTextFieldButton(
              context,
              stars.isEmpty ? "Rate" : stars,
              starList,
              (str) => setState(() {
                stars = str;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _createTextFieldButton(
    BuildContext context,
    String label,
    List<String> dataList,
    void Function(String) callback,
  ) {
    return SizedBox(
      width: 100,
      height: 40,
      child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 243, 243),
            border: Border.all(color: Colors.grey[350]!, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ),
        onTap: () => showPicker(context, dataList, callback),
      ),
      // TextField(
      //   textAlign: TextAlign.center,
      //   controller: controller,
      //   decoration: InputDecoration(
      //     // labelText: label,
      //     hintText: label,
      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      //   ),
      //   readOnly: true,
      //   onTap: () => showPicker(context, controller, dataList),
      // ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';

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
  final httpClient = Httpclient.shared;

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

  Widget _homeScreen(BuildContext context) {
    return Container(color: Colors.pink[100]);
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
}

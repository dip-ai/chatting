import 'package:chat_app/auth/login_page.dart';
import 'package:chat_app/first%20page/welcome_page.dart';
import 'package:chat_app/second%20page/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seen') ?? false;
  runApp(MyApp(seen: seen));
}

class MyApp extends StatelessWidget {
  final bool seen;
  const MyApp({super.key, required this.seen});

  Future<bool> _isWelcomeScreenShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen') ?? false;
  }

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // scaffoldBackgroundColor: Color(0xFF797979),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: seen ? const ContactPage() : const WelcomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _isWelcomeScreenShown(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.data == true) {
                    return FutureBuilder<bool>(
                      future: _isLoggedIn(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.data == true) {
                            return const ContactPage();
                          } else {
                            return const LoginPage();
                          }
                        }
                      },
                    );
                  } else {
                    return const WelcomePage();
                  }
                }
              },
            ),
        '/login': (context) => const LoginPage(),
        '/contact': (context) => const ContactPage(),
      },
    );
  }
}

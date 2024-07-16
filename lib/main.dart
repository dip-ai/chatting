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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // scaffoldBackgroundColor: Color(0xFF797979),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: seen ? const ContactPage() : const WelcomePage(),
    );
  }
}

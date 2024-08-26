import 'package:chat_app/auth/Screen/login_screen.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'second page/contact_page.dart';

var uuid = const Uuid();
const apiKey = "https://book-your-seat.onrender.com";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? userModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    userModel != null
        ? runApp(MyAppLoggedIn(userModel: userModel, firebaseUser: currentUser))
        : runApp(const MyApp());
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0E57A5)),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactPage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}



//eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRpaXAxMjM0QGdtYWlsLmNvbSIsImlhdCI6MTcyNDM5NzIyN30.sk0UTbLWqSIRnRMectz3zsoMuMiDyoSiFyvJPM4MzPo
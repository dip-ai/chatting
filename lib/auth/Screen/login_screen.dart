import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/auth/Screen/signup_screen.dart';
import 'package:chat_app/first%20page/config/validator.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/second%20page/contact_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/form_container_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _checkValues() {
    if (_formKey.currentState?.validate() ?? false) {
      String _email = _emailController.text.trim();
      String _password = _passwordController.text.trim();

      // FirebaseAuthServices.signIn(_email, _password);
      signIn(_email, _password);
      debugPrint("Login Successful!😎");
    }
  }

  void signIn(
    String email,
    String password,
  ) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      log("hvhv");
      log(ex.code.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Credential"),
        ),
      );
    }

    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      try {
        final response = await http.Client().post(
          Uri.parse("$apiKey/users/login"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString(
              "api_id", (jsonDecode(response.body) as Map)["id"].toString());

          prefs.setString("api_token",
              (jsonDecode(response.body) as Map)["token"].toString());
          log('User ID saved in SharedPreferences: ${prefs.getString("api_id")}');
          log('Token saved in SharedPreferences: ${prefs.getString("api_token")}');
          log(response.body.toString());
          log("Custom API sign-in successful");
        } else {
          log("Custom API sign-in error: ${response.body}");
        }
      } catch (e) {
        log("Custom API sign-in error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!😎"),
        ),
      );
      log("Login Successful!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return ContactPage(
              userModel: userModel, firebaseUser: userCredential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Image.asset(
            "assets/images/poster.jpg",
            fit: BoxFit.fill,
            width: double.infinity,
            height: 300,
          ),
          const SizedBox(height: 40),
          const Text(
            "SIGN IN",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xff0E57A5),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormContainerWidget(
                        controller: _emailController,
                        hintText: "Email",
                        isPasswordField: false,
                        validator: Validation.validateEmail,
                      ),
                      const SizedBox(height: 20),
                      FormContainerWidget(
                        controller: _passwordController,
                        hintText: "Password",
                        isPasswordField: true,
                        validator: Validation.validatePassword,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _checkValues();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xff0E57A5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Color(0xff0E57A5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

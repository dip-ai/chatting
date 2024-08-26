import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/auth/Screen/login_screen.dart';
import 'package:chat_app/first%20page/config/validator.dart';
import 'package:chat_app/widgets/form_container_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../models/user_model.dart';

import 'profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  void _checkValues() {
    if (_formKey.currentState?.validate() ?? false) {
      String _email = _emailController.text.trim();
      String _password = _passwordController.text.trim();
      String _confirmPassword = _confirmPasswordController.text.trim();
      String _fullName = _fullNameController.text.trim();

      if (_email.isEmpty ||
          _password.isEmpty ||
          _confirmPassword.isEmpty ||
          _fullName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fields can't be empty"),
          ),
        );
        debugPrint("Fields can't be empty");
      } else if (_password != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password and Confirm Password should be same"),
          ),
        );
        debugPrint("Password and Confirm Password should be same");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Looks Good!😎"),
          ),
        );
        signUp(_email, _password, _fullName);
        log("Looks Good!😎");
      }
    }
  }

  void signUp(String email, String password, String fullName) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      log(ex.code.toString());
    }

    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullName: fullName, profilePic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) => log("New user created"))
          .catchError((error) {
        log("Failed to add user to Firestore: $error");
      });
      try {
        final response = await http.Client().post(
          Uri.parse("$apiKey/users"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'email': email, 'password': password, 'username': fullName}),
        );

        if (response.statusCode == 201) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(
              "api_id", (jsonDecode(response.body) as Map)["id"].toString());
          prefs.setString("api_token",
              (jsonDecode(response.body) as Map)["token"].toString());
          log('User ID saved in SharedPreferences: ${prefs.getString("api_id")}');
          log('Token saved in SharedPreferences: ${prefs.getString("api_token")}');
          log(response.body.toString());
          log("Custom API sign-up successful");
        } else {
          log("Custom API sign-up error: ${response.body}");
        }
      } catch (e) {
        log("Custom API sign-up error: $e");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return ProfileScreen(
              userModel: newUser, firebaseUser: userCredential!.user!);
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
              "SIGN UP",
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
                  const SizedBox(height: 20),
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
                          controller: _fullNameController,
                          hintText: "Full Name",
                          isPasswordField: false,
                        ),
                        const SizedBox(height: 20),
                        FormContainerWidget(
                          controller: _passwordController,
                          hintText: "Password",
                          isPasswordField: true,
                          validator: Validation.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        FormContainerWidget(
                          controller: _confirmPasswordController,
                          hintText: "Confirmed Password",
                          isPasswordField: true,
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
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
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
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Sign In",
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
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final String developerEmail = 'casual007@gmail.com';
  final String developerPassword = 'Abc@56#95';
  bool loading = false;
  String? _emailError;
  String? _passwordError;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the authorized Email ID';
    }
    if (value != _emailController.text) {
      debugPrint("Wrong mail");
      return 'Provided email is not authorized';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,30}$',
    );

    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must be 8-30 characters long, \ncontain at least one uppercase letter, \none lowercase letter, one number, and one special character.';
    }
    if (value != developerPassword) {
      return 'Provided password is incorrect';
    }
    return null;
  }

  void _login() async {
    setState(() {
      _emailError = validateEmail(_emailController.text);
      _passwordError = validatePassword(_passwordController.text);

      if (_emailError == null && _passwordError == null) {
        // Perform login action
        _signIn();
      }
    });
  }

  void _signIn() async {
    loading = true;
    try {
      final responce =
          await post(Uri.parse("https://reqres.in/api/register"), body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      var data = jsonDecode(responce.body);

      if (responce.statusCode == 200) {
        loading = false;
        debugPrint("Login successful");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/contact');
        }
        const SnackBar(content: Text("Login Successful"));
      } else {
        loading = false;
        debugPrint("Login failed");
        Text("Login Failed, ${data['error']}");
      }
    } catch (e) {
      loading = false;
      SnackBar(content: Text("exception: ${e.toString()}"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "LOG IN",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A1BF8),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  errorText: _emailError,
                  focusColor: const Color(0xFF5A1BF8),
                ),
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: validateEmail,
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  errorText: _passwordError,
                  focusColor: const Color(0xFF5A1BF8),
                ),
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                validator: validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A1BF8),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final String developerPassword = 'Abc@56#95';

//   String? _emailError;
//   String? _passwordError;
//   bool _isLoading = false;
//   String? apiEmail;

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter the authorized Email ID';
//     }
//     if (value != apiEmail) {
//       debugPrint("Wrong email");
//       debugPrint(apiEmail);
//       return 'Provided email is not authorized';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     final passwordRegex = RegExp(
//       r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,30}$',
//     );

//     if (value == null || value.isEmpty) {
//       return 'Please enter a password';
//     }
//     if (!passwordRegex.hasMatch(value)) {
//       return 'Password must be 8-30 characters long, \ncontain at least one uppercase letter, \none lowercase letter, one number, and one special character';
//     }
//     if (value != developerPassword) {
//       return 'Provided password is incorrect';
//     }
//     return null;
//   }

//   void _login() async {
//     setState(() {
//       _emailError = validateEmail(_emailController.text);
//       _passwordError = validatePassword(_passwordController.text);
//     });

//     if (_emailError == null && _passwordError == null) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final response = await http.post(
//           Uri.parse("https://reqres.in/api/register"),
//           body: {
//             'email': _emailController.text,
//             'password': _passwordController.text,
//           },
//         ).timeout(const Duration(seconds: 10));

//         if (response.statusCode == 200) {
//           var data = jsonDecode(response.body);
//           apiEmail = data['email']; // Get the email from the API response

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('isLoggedIn', true);

//           if (mounted) {
//             Navigator.pushReplacementNamed(context, '/contact');
//           }
//         } else {
//           final data = jsonDecode(response.body);
//           setState(() {
//             _emailError = data['error'];
//             _passwordError = data['error'];
//           });
//         }
//       } on TimeoutException catch (_) {
//         setState(() {
//           _emailError = 'Request timed out. Please try again.';
//           _passwordError = 'Request timed out. Please try again.';
//         });
//       } catch (e) {
//         setState(() {
//           _emailError = 'An error occurred: ${e.toString()}';
//           _passwordError = 'An error occurred: ${e.toString()}';
//         });
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(20.0, 5, 20, 20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 "LOG IN",
//                 style: TextStyle(
//                   fontSize: 50,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF5A1BF8),
//                 ),
//               ),
//               const SizedBox(height: 25),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Email Address',
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(30)),
//                   ),
//                   errorText: _emailError,
//                   focusColor: const Color(0xFF5A1BF8),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 controller: _emailController,
//                 validator: validateEmail,
//               ),
//               const SizedBox(height: 30),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: const OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(30)),
//                   ),
//                   errorText: _passwordError,
//                   focusColor: const Color(0xFF5A1BF8),
//                 ),
//                 keyboardType: TextInputType.visiblePassword,
//                 controller: _passwordController,
//                 validator: validatePassword,
//                 obscureText: true,
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5A1BF8),
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                       : const Text(
//                           'Log in',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16.0,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

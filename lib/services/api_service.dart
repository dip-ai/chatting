// import 'package:chat_app/auth/Screen/login_screen.dart';
// import 'package:chat_app/main.dart';
// import 'package:chat_app/models/user_model.dart';
// import 'package:chat_app/second%20page/contact_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ApiFilledPage extends StatefulWidget {
//   final UserModel? userModel;
//   final User? firebaseUser;

//   const ApiFilledPage({super.key, this.userModel, this.firebaseUser});

//   @override
//   State<ApiFilledPage> createState() => _ApiFilledPageState();
// }

// class _ApiFilledPageState extends State<ApiFilledPage> {
//   final TextEditingController _apiController = TextEditingController();

//   void _next() {
//     setState(() {
//       apiKey = _apiController.text.trim();
//     });

//     if (widget.firebaseUser != null) {
//       // If user is logged in, navigate to Contact Page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ContactPage(
//             userModel: widget.userModel!,
//             firebaseUser: widget.firebaseUser!,
//           ),
//         ),
//       );
//     } else {
//       // If user is not logged in, navigate to Login Page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _apiController,
//                 decoration: const InputDecoration(
//                   labelText: "Enter API Key",
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _next,
//                 icon: const Icon(Icons.navigate_next),
//                 label: const Text("Next"),
//                 iconAlignment: IconAlignment.end,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

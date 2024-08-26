import 'dart:developer';

import 'package:chat_app/auth/Screen/profile_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseAuthServices {
  // static void signUp(
  //   String email,
  //   String password,
  // ) async {
  //   UserCredential? userCredential;

  //   try {
  //     userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //   } on FirebaseAuthException catch (ex) {
  //     log(ex.code.toString());
  //   }

  //   if (userCredential != null) {
  //     String uid = userCredential.user!.uid;
  //     UserModel newUser =
  //         UserModel(uid: uid, email: email, fullName: "", profilePic: "");
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(uid)
  //         .set(newUser.toMap())
  //         .then((value) => log("New user created"));
  //   }
  // }

//   static void signIn(
//     String email,
//     String password,
//   ) async {
//     UserCredential? userCredential;

//     try {
//       userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//     } on FirebaseAuthException catch (ex) {
//       log(ex.code.toString());
//     }

//     if (userCredential != null) {
//       String uid = userCredential.user!.uid;
//       DocumentSnapshot userData =
//           await FirebaseFirestore.instance.collection("users").doc(uid).get();
//       UserModel userModel =
//           UserModel.fromMap(userData.data() as Map<String, dynamic>);
//       log("Login Successful!");
//     }
//   }
}

// import 'dart:developer';
// import 'dart:io';
// // import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

// import 'package:chat_app/model/user_model.dart';
// import 'package:chat_app/second%20page/contact_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../widgets/button.dart';
// import '../../widgets/form_container_widget.dart';

// class ProfileScreen extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;

//   const ProfileScreen(
//       {super.key, required this.userModel, required this.firebaseUser});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   File? imageFile;
//   TextEditingController nameController = TextEditingController();

//   void selectImage(ImageSource source) async {
//     XFile? pickedFile = await ImagePicker().pickImage(source: source);
//     if (pickedFile != null) {
//       cropImage(pickedFile);
//     }
//   }

//   void cropImage(XFile file) async {
//     CroppedFile? croppedImage = (await ImageCropper().cropImage(
//       sourcePath: file.path,
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//       compressQuality: 30,
//     ));

//     if (croppedImage != null) {
//       setState(() {
//         imageFile = File(croppedImage.path);
//       });
//     }
//   }

//   void checkValues() {
//     // String name = nameController.text.trim();

//     if (imageFile == null) {
//       log("Please fill all the fields");
//       // UIHelper.showAlertDialog(context, "Incomplete Data","Please fill all the fields and upload a profile picture");
//     } else {
//       log("Uploading data..");
//       uploadData();
//     }
//   }

//   void showPhotoOptions() {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text("Upload Profile Picture"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   onTap: () {
//                     Navigator.pop(context);
//                     selectImage(ImageSource.gallery);
//                   },
//                   leading: const Icon(Icons.photo),
//                   title: const Text("Choose From Gallery"),
//                 ),
//                 ListTile(
//                   onTap: () {
//                     Navigator.pop(context);
//                     selectImage(ImageSource.camera);
//                   },
//                   leading: const Icon(Icons.camera_alt),
//                   title: const Text("Take a Photo"),
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//   void uploadData() async {
//     UploadTask uploadtask = FirebaseStorage.instance
//         .ref("profilePic")
//         .child(widget.userModel.uid.toString())
//         .putFile(imageFile!);
//     TaskSnapshot snapshot = await uploadtask;

//     String? imageUrl = await snapshot.ref.getDownloadURL();
//     String? name = nameController.text.trim();

//     widget.userModel.fullName = name;
//     widget.userModel.profilePic = imageUrl;

//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc(widget.userModel.uid)
//         .set(widget.userModel.toMap())
//         .then((onValue) => log("Data Uploaded...."));
//     log("sdfbksdkdfkdshfldsk fkuhsdfsdufhdsk fhsdukaf kusdh fkdsh fksdh fuskd fhksdf hksdjf dsbf");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//       padding: const EdgeInsets.all(14.0),
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         const Text(
//           "SET YOUR PROFILE",
//           style: TextStyle(
//               fontSize: 30,
//               color: Color(0xff0E57A5),
//               fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 25),
//         CupertinoButton(
//           onPressed: () {
//             showPhotoOptions();
//           },
//           padding: const EdgeInsets.all(0),
//           child: CircleAvatar(
//             radius: 60,
//             backgroundImage: (imageFile != null) ? FileImage(imageFile!) : null,
//             child: (imageFile == null)
//                 ? const Icon(
//                     Icons.person,
//                     size: 60,
//                   )
//                 : null,
//           ),
//         ),
//         const SizedBox(height: 25),
//         FormContainerWidget(
//           controller: nameController,
//           hintText: "Full Name",
//           isPasswordField: false,
//         ),
//         const SizedBox(height: 25),
//         SubmitButton(
//             text: "Save",
//             onTap: () {
//               checkValues();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) {
//                   return ContactPage(
//                       userModel: widget.userModel,
//                       firebaseUser: widget.firebaseUser);
//                 }),
//               );
//             })
//       ]),
//     ));
//   }
// }

import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/second%20page/contact_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/button.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ProfileScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? imageFile;
  TextEditingController nameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = (await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 30,
    ));

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo),
                  title: const Text("Choose From Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a Photo"),
                ),
              ],
            ),
          );
        });
  }

  void uploadData() async {
    String? imageUrl;

    if (imageFile != null) {
      UploadTask uploadtask = FirebaseStorage.instance
          .ref("profilePic")
          .child(widget.userModel.uid.toString())
          .putFile(imageFile!);
      TaskSnapshot snapshot = await uploadtask;

      imageUrl = await snapshot.ref.getDownloadURL();
    } else {
      imageUrl =
          "assets/images/user.png"; // Use a default profile picture if none is selected
    }

    setState(() {
      widget.userModel.profilePic = imageUrl;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((onValue) => log("Data Uploaded...."));
    log("Data successfully uploaded");

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ContactPage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "SET YOUR PROFILE",
          style: TextStyle(
              fontSize: 30,
              color: Color(0xff0E57A5),
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        CupertinoButton(
          onPressed: () {
            showPhotoOptions();
          },
          padding: const EdgeInsets.all(0),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: (imageFile != null)
                ? FileImage(imageFile!)
                : (widget.userModel.profilePic != null &&
                        widget.userModel.profilePic!.isNotEmpty)
                    ? NetworkImage(widget.userModel.profilePic!)
                    : const AssetImage("assets/images/user.png")
                        as ImageProvider, // Default profile picture
            child: (imageFile == null &&
                    (widget.userModel.profilePic == null ||
                        widget.userModel.profilePic!.isEmpty))
                ? const Icon(
                    Icons.person,
                    size: 60,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 25),
        const SizedBox(height: 25),
        SubmitButton(
            text: "Save",
            onTap: () {
              uploadData(); // Ensure uploadData is called to upload the data and update Firestore
            })
      ]),
    ));
  }
}

import 'dart:io';
import 'package:chat_app/second%20page/search_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/group_chat_model.dart';

import '../../models/user_model.dart';
import '../group_chat_page/group-chat_room_page.dart';

class CreateGroupScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CreateGroupScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;
  List<UserModel> contacts = [];
  List<UserModel> selectedContacts = [];
  bool isCreatingGroup = false;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  void fetchContacts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    contacts = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Exclude the current user from the contacts list
    contacts.removeWhere((contact) => contact.uid == widget.userModel.uid);

    setState(() {});
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 30,
    );

    if (croppedImage != null) {
      setState(() {
        image = File(croppedImage.path);
      });
    }
  }

  void createGroup() async {
    if (isCreatingGroup) return;

    if (groupNameController.text.trim().isNotEmpty &&
        image != null &&
        selectedContacts.isNotEmpty) {
      setState(() {
        isCreatingGroup = true;
      });

      String groupId =
          FirebaseFirestore.instance.collection('groupchatrooms').doc().id;

      Map<String, bool> participants = {widget.userModel.uid!: true};
      for (var contact in selectedContacts) {
        participants[contact.uid!] = true;
      }

      String? imageUrl;
      if (image != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('groupImages/$groupId.png')
            .putFile(image!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      GroupChatRoomModel groupChatRoom = GroupChatRoomModel(
        chatroomid: groupId,
        admin: widget.userModel.uid,
        participants: participants,
        lastMessage: '',
        lastMessageTimestamp: Timestamp.now(),
        createdAt: Timestamp.now(),
        groupName: groupNameController.text.trim(),
        groupImage: imageUrl ?? "",
      );

      await FirebaseFirestore.instance
          .collection('groupchatrooms')
          .doc(groupId)
          .set(groupChatRoom.toMap());

      // Update each participant's groupIds in Firestore
      List<String> userIds = selectedContacts.map((user) => user.uid!).toList();
      userIds.add(widget.userModel.uid!); // Add the current user

      for (String userId in userIds) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'groupIds': FieldValue.arrayUnion([groupId]),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GroupChatRoomPage(
              firebaseUser: widget.firebaseUser,
              userModel: widget.userModel,
              groupChatRoom: groupChatRoom,
            );
          }),
        );
      }

      setState(() {
        isCreatingGroup = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: AssetImage("assets/images/user.png"),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(image!),
                        radius: 64,
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                      onPressed: () => selectImage(ImageSource.gallery),
                      icon: const Icon(Icons.add_a_photo)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: "Enter Group Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Select Contacts",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  UserModel contact = contacts[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(contact.profilePic ?? ""),
                    ),
                    title: Text(contact.fullName ?? ""),
                    trailing: Checkbox(
                      value: selectedContacts.contains(contact),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedContacts.add(contact);
                          } else {
                            selectedContacts.remove(contact);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: const Color(0xff0E57A5),
        child: const Icon(Icons.done, color: Colors.white),
      ),
    );
  }
}

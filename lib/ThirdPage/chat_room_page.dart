import 'dart:developer';
import 'dart:io';

import 'package:chat_app/ThirdPage/fullscreenimage_page.dart';
import 'package:chat_app/calling/audio_calling.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroom_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.chatroom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void sendMessage({String? imageUrl}) async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "" || imageUrl != null) {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid!,
        createdon: Timestamp.now(),
        text: msg,
        seen: false,
      );

      if (imageUrl != null) {
        newMessage.text = imageUrl;
      }

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg.isNotEmpty ? msg : "Image";
      widget.chatroom.createdAt = Timestamp.now(); // Update this line
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      log("message sent");
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String imageUrl = await uploadImage(imageFile);
      sendMessage(imageUrl: imageUrl);
    }
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = uuid.v1();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(fileName)
        .putFile(imageFile);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime messageDate = timestamp.toDate();
    DateTime now = DateTime.now();

    if (now.difference(messageDate).inDays == 0) {
      return "Today, ${DateFormat.jm().format(messageDate)}";
    } else if (now.difference(messageDate).inDays == 1) {
      return "Yesterday, ${DateFormat.jm().format(messageDate)}";
    } else {
      return DateFormat('MMM d, yyyy, h:mm a').format(messageDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.fullName.toString()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return AudioCallingScreen(userModel: widget.userModel);
                },
              ));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                          reverse: true,
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                querySnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            bool isImage =
                                currentMessage.text.startsWith('https://');
                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? const Color(0xFF5A1BF8)
                                              : Colors.black38,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            isImage
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenImagePage(
                                                                  imageUrl:
                                                                      currentMessage
                                                                          .text),
                                                        ),
                                                      );
                                                    },
                                                    child: Image.network(
                                                      currentMessage.text,
                                                      width: 150,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Text(
                                                    currentMessage.text,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        formatTimestamp(
                                            currentMessage.createdon),
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          });
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                            "An error occurred. Check your internet connection"),
                      );
                    } else {
                      return const Center(
                        child: Text("Say hi to your buddy"),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Color(0xFF5A1BF8)),
                    onPressed: pickImage,
                  ),
                  Flexible(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Enter message"),
                    ),
                  ),
                  IconButton(
                    onPressed: () => sendMessage(),
                    icon: const Icon(Icons.send, color: Color(0xFF5A1BF8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

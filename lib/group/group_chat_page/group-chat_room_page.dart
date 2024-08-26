import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../ThirdPage/fullscreenimage_page.dart';
import '../../main.dart';
import '../../models/group_chat_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../screens/group_info_screen.dart';

class GroupChatRoomPage extends StatefulWidget {
  final GroupChatRoomModel groupChatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const GroupChatRoomPage({
    super.key,
    required this.groupChatRoom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<GroupChatRoomPage> createState() => _GroupChatRoomPageState();
}

class _GroupChatRoomPageState extends State<GroupChatRoomPage> {
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
          .collection("groupchatrooms")
          .doc(widget.groupChatRoom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.groupChatRoom.lastMessage = msg.isNotEmpty ? msg : "Image";
      widget.groupChatRoom.lastMessageTimestamp =
          Timestamp.now(); // Update this line
      FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoom.chatroomid)
          .set(widget.groupChatRoom.toMap());
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
        .child('group_chat_images')
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

  Widget buildMessage(MessageModel message, bool isSender, UserModel sender) {
    bool isImage = message.text.startsWith('https://');
    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSender)
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(sender.profilePic.toString()),
          ),
        Column(children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            decoration: BoxDecoration(
              color: isSender ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSender)
                  Text(
                    sender.fullName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                if (isImage)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImagePage(imageUrl: message.text),
                        ),
                      );
                    },
                    child: Image.network(
                      message.text,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  ),
              ],
            ),
          ),
          if (isSender)
            const SizedBox(width: 10), // Padding between message and timestamp
          Row(
            children: [
              Text(
                formatTimestamp(message.createdon),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 5),
              if (isSender)
                const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.blue,
                )
            ],
          ),
        ]),
        if (isSender)
          const SizedBox(width: 5), // Padding between message and timestamp
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoScreen(
                  groupChatRoom: widget.groupChatRoom,
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.groupChatRoom.groupImage ?? ''),
              ),
              const SizedBox(width: 10),
              Text(widget.groupChatRoom.groupName ?? "Group"),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("groupchatrooms")
                    .doc(widget.groupChatRoom.chatroomid)
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

                          bool isSender =
                              currentMessage.sender == widget.userModel.uid;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(currentMessage.sender)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.done) {
                                UserModel sender = UserModel.fromMap(
                                    userSnapshot.data!.data()
                                        as Map<String, dynamic>);

                                return buildMessage(
                                    currentMessage, isSender, sender);
                              } else {
                                return Container(); // Placeholder for loading state
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                            "An error occurred. Check your internet connection"),
                      );
                    } else {
                      return const Center(
                        child: Text("No messages yet"),
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

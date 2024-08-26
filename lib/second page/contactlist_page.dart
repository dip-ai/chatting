import 'package:chat_app/second%20page/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../ThirdPage/chat_room_page.dart';
import '../models/chatroom_model.dart';
import '../models/firebase_helper.dart';
import '../models/user_model.dart';

class ContactlistPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const ContactlistPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ContactlistPage> createState() => _ContactlistPageState();
}

class _ContactlistPageState extends State<ContactlistPage> {
  // Method to delete a chat room
  void deleteChatRoom(String chatRoomId) async {
    try {
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete chat: $e')),
      );
    }
  }

  // Method to show a confirmation dialog
  void showDeleteConfirmationDialog(String chatRoomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Chat"),
          content: const Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                deleteChatRoom(chatRoomId); // Perform the delete operation
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chatrooms")
            .where("participants.${widget.userModel.uid}", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

              return ListView.builder(
                itemCount: chatRoomSnapshot.docs.length,
                itemBuilder: (context, index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>);

                  Map<String, dynamic> participants =
                      chatRoomModel.participants!;

                  List<String> participantKeys = participants.keys.toList();
                  participantKeys.remove(widget.userModel.uid);

                  if (participantKeys.isEmpty) {
                    return Container(); // or some fallback UI
                  }

                  return FutureBuilder(
                    future: FirebaseHelper.getUserModelById(participantKeys[0]),
                    builder: (context, userData) {
                      if (userData.connectionState == ConnectionState.done) {
                        if (userData.data != null) {
                          UserModel targetUser = userData.data as UserModel;

                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    chatroom: chatRoomModel,
                                    firebaseUser: widget.firebaseUser,
                                    userModel: widget.userModel,
                                    targetUser: targetUser,
                                  );
                                }),
                              );
                            },
                            onLongPress: () {
                              // Show confirmation dialog on long press
                              showDeleteConfirmationDialog(
                                  chatRoomModel.chatroomid!);
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  targetUser.profilePic.toString()),
                            ),
                            title: Text(targetUser.fullName.toString()),
                            subtitle:
                                (chatRoomModel.lastMessage.toString() != "")
                                    ? Text(chatRoomModel.lastMessage.toString())
                                    : Text(
                                        "Say hi to your new friend!",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(
                child: Text("No Chats"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0E57A5),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            );
          }));
        },
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}

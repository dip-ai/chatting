import 'dart:developer';
import 'package:chat_app/group/group_chat_page/group-chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/models/user_model.dart';
import '../../models/group_chat_model.dart';

class GroupChatPage extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const GroupChatPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  Future<String> fetchUserName(String? uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        UserModel userModel =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        return userModel.fullName ?? 'Unknownn';
      } else {
        log('User document does not exist for UID: $uid');
        return 'Unknownnnnn';
      }
    } catch (e) {
      log('Error fetching user name for UID: $uid, Error: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groupchatrooms")
            .where('participants.${userModel.uid}', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              QuerySnapshot groupChatRoomSnapshot =
                  snapshot.data as QuerySnapshot;

              if (groupChatRoomSnapshot.docs.isEmpty) {
                return const Center(child: Text('No groups available.'));
              }

              return ListView.builder(
                itemCount: groupChatRoomSnapshot.docs.length,
                itemBuilder: (context, index) {
                  GroupChatRoomModel groupChatRoom = GroupChatRoomModel.fromMap(
                      groupChatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>);

                  return FutureBuilder(
                    future: fetchUserName(groupChatRoom.lastMessageSender),
                    builder: (context, AsyncSnapshot<String> userNameSnapshot) {
                      if (userNameSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              groupChatRoom.groupImage ??
                                  "assets/images/user.png",
                            ),
                            radius: 30,
                          ),
                          title:
                              Text(groupChatRoom.groupName ?? "Unnamed Group"),
                          subtitle: const Text("Loading..."),
                        );
                      } else {
                        String subtitleText;
                        if (groupChatRoom.lastMessage?.isNotEmpty == true) {
                          String lastMessageSender =
                              userNameSnapshot.data ?? 'Unknown';
                          log('Last Message Sender: $lastMessageSender');
                          subtitleText = "${groupChatRoom.lastMessage}";
                        } else {
                          subtitleText = 'No messages yet';
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              groupChatRoom.groupImage ??
                                  "assets/images/user.png",
                            ),
                            radius: 30,
                          ),
                          title:
                              Text(groupChatRoom.groupName ?? "Unnamed Group"),
                          subtitle: Text(subtitleText),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatRoomPage(
                                  userModel: userModel,
                                  firebaseUser: firebaseUser,
                                  groupChatRoom: groupChatRoom,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(child: Text("No groups available."));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

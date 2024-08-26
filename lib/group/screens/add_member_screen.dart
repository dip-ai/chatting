import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/group_chat_model.dart';
import '../../models/user_model.dart';
import '../group_chat_page/group-chat_room_page.dart';

class AddMembersScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final GroupChatRoomModel groupChatRoom;

  const AddMembersScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
    required this.groupChatRoom,
  });

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  List<UserModel> contacts = [];
  List<UserModel> selectedContacts = [];

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

    // Exclude already added members
    contacts.removeWhere((contact) =>
        widget.groupChatRoom.participants!.containsKey(contact.uid));

    setState(() {});
  }

  void addMembers() async {
    // Update the participants list
    Map<String, bool> newParticipants =
        Map.from(widget.groupChatRoom.participants!);
    for (var contact in selectedContacts) {
      newParticipants[contact.uid!] = true;
    }

    await FirebaseFirestore.instance
        .collection('groupchatrooms')
        .doc(widget.groupChatRoom.chatroomid)
        .update({'participants': newParticipants});

    // Update each selected participant's groupIds in Firestore
    List<String> userIds = selectedContacts.map((user) => user.uid!).toList();

    for (String userId in userIds) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'groupIds': FieldValue.arrayUnion([widget.groupChatRoom.chatroomid]),
      });
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return GroupChatRoomPage(
            firebaseUser: widget.firebaseUser,
            userModel: widget.userModel,
            groupChatRoom: widget.groupChatRoom,
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Select Contacts to Add",
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
        onPressed: addMembers,
        backgroundColor: const Color(0xff0E57A5),
        child: const Icon(Icons.done, color: Colors.white),
      ),
    );
  }
}

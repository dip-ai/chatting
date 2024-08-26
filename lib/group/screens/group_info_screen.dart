import 'dart:io';
import 'package:chat_app/group/screens/add_member_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/group_chat_model.dart';
import '../../models/user_model.dart';

class GroupInfoScreen extends StatefulWidget {
  final GroupChatRoomModel groupChatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const GroupInfoScreen({
    super.key,
    required this.groupChatRoom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  TextEditingController _groupNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.groupChatRoom.groupName ?? "";
  }

  Future<void> pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _isEditing = true;
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = uuid.v1();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('group_images')
        .child(fileName)
        .putFile(imageFile);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveChanges() async {
    if (_isEditing) {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
        widget.groupChatRoom.groupImage = imageUrl;
      }

      String newGroupName = _groupNameController.text.trim();
      widget.groupChatRoom.groupName = newGroupName.isNotEmpty
          ? newGroupName
          : widget.groupChatRoom.groupName;

      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoom.chatroomid)
          .update(widget.groupChatRoom.toMap());

      setState(() {
        _isEditing = false;
      });
    }
  }

  Future<UserModel> fetchUser(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  }

  void makeAdmin(String userId) async {
    // Update the group's participants to mark the user as an admin
    await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(widget.groupChatRoom.chatroomid)
        .update({'participants.$userId': 'admin'});

    // Ensure the user's document reflects their participation in the group
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayUnion([widget.groupChatRoom.chatroomid]),
    });

    setState(() {});
  }

  void removeMember(String userId) async {
    await FirebaseFirestore.instance
        .collection("groupchatrooms")
        .doc(widget.groupChatRoom.chatroomid)
        .update({'participants.$userId': FieldValue.delete()});
    setState(() {});
  }

  Future<void> leaveGroup() async {
    if (widget.groupChatRoom.admin == widget.userModel.uid) {
      // If the user is the admin, handle admin transfer or group dissolution logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Admin cannot leave the group. Transfer admin role first."),
        ),
      );
    } else {
      await FirebaseFirestore.instance
          .collection("groupchatrooms")
          .doc(widget.groupChatRoom.chatroomid)
          .update(
              {'participants.${widget.userModel.uid}': FieldValue.delete()});

      if (mounted) {
        Navigator.of(context).pop();
      } // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.groupChatRoom.admin == widget.userModel.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    _selectedImage != null
                        ? _selectedImage!.path
                        : widget.groupChatRoom.groupImage ?? '',
                  ),
                  radius: 100,
                ),
                if (isAdmin)
                  Positioned(
                    bottom: -10,
                    left: 120,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 40,
                      ),
                      onPressed: pickImage,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: isAdmin
                  ? TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintText: "Enter group name",
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      widget.groupChatRoom.groupName ?? "Group Name",
                      style: const TextStyle(fontSize: 24),
                    ),
            ),
            const Divider(),
            const ListTile(
              title: Text("Members"),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupchatrooms')
                  .doc(widget.groupChatRoom.chatroomid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var participants =
                    snapshot.data!['participants'] as Map<String, dynamic>;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    String userId = participants.keys.elementAt(index);
                    var role = participants[userId];

                    // Ensure the role is a String
                    bool isMemberAdmin = (role is String && role == 'admin');

                    return FutureBuilder<UserModel>(
                      future: fetchUser(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            title: Text("Loading..."),
                          );
                        }
                        UserModel user = userSnapshot.data!;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(user.profilePic ?? ''),
                          ),
                          title: Text(user.fullName ?? ''),
                          subtitle: isMemberAdmin ||
                                  userId == widget.groupChatRoom.admin
                              ? const Text('Admin')
                              : null,
                          trailing:
                              isAdmin && userId != widget.groupChatRoom.admin
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'makeAdmin') {
                                          makeAdmin(userId);
                                        } else if (value == 'remove') {
                                          removeMember(userId);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (!isMemberAdmin)
                                          const PopupMenuItem(
                                            value: 'makeAdmin',
                                            child: Text('Make Admin'),
                                          ),
                                        const PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Remove'),
                                        ),
                                      ],
                                    )
                                  : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
            const Divider(),
            if (isAdmin)
              ListTile(
                title: Text(
                  "Add Member",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: Icon(Icons.add, color: Colors.grey.shade700),
                onTap: () {
                  // Code to add new members
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return AddMembersScreen(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser,
                        groupChatRoom: widget.groupChatRoom,
                      );
                    }),
                  );
                },
              ),
            if (!isAdmin)
              ListTile(
                title: Text(
                  "Add Member",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                trailing: Icon(Icons.add, color: Colors.grey.shade400),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You are not Admin"),
                    ),
                  );
                },
              ),
            const Divider(),
            ListTile(
              title: Text(
                "Leave Group",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              trailing: const Icon(Icons.exit_to_app, color: Colors.grey),
              onTap: leaveGroup,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import '../models/user_model.dart';

// class SearchPage extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;
//   const SearchPage(
//       {super.key, required this.userModel, required this.firebaseUser});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   List _allResult = [];
//   List _resultList = [];
//   TextEditingController _searchController = TextEditingController();
//   @override
//   void initState() {
//     _searchController.addListener(_onSearchChanged);
//     super.initState();
//   }

//   _onSearchChanged() {
//     log(_searchController.text);
//     searchResultList();
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     getClientStream();
//     super.didChangeDependencies();
//   }

//   getClientStream() async {
//     var data = await FirebaseFirestore.instance
//         .collection('users')
//         .orderBy('fullName')
//         .get();

//     setState(() {
//       _allResult = data.docs;
//     });
//     searchResultList();
//   }

//   searchResultList() {
//     var _showResult = [];
//     if (_searchController.text != "") {
//       for (var userSnapShot in _allResult) {
//         var name = userSnapShot['fullName'].toString().toLowerCase();

//         if (name.contains(_searchController.text.toLowerCase())) {
//           _showResult.add(userSnapShot);
//         }
//       }
//     }
//     setState(() {
//       _resultList = _showResult;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: CupertinoSearchTextField(
//           controller: _searchController,
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: _resultList.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundImage:
//                     NetworkImage(_resultList[index]['profilePic'] ??
// Image.asset(
//   "assets/images/user.png",
//   color: Colors.white,
// )),
//                 backgroundColor: Colors.grey[500],
//               ),
//               title: Text(_resultList[index]['fullName']),
//               subtitle: Text(_resultList[index]['email']),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chatroom_model.dart';
import '../models/user_model.dart';
import '../ThirdPage/chat_room_page.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _allResult = [];
  List _resultList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    log(_searchController.text);
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('fullName')
        .get();

    setState(() {
      _allResult = data.docs;
    });
    searchResultList();
  }

  searchResultList() {
    var _showResult = [];
    if (_searchController.text != "") {
      for (var userSnapShot in _allResult) {
        var name = userSnapShot['fullName'].toString().toLowerCase();
        var email = userSnapShot['email'].toString().toLowerCase();

        if (name.contains(_searchController.text.toLowerCase()) ||
            email.contains(_searchController.text.toLowerCase())) {
          _showResult.add(userSnapShot);
        }
      }
    }
    setState(() {
      _resultList = _showResult;
    });
  }

  Future<ChatRoomModel?> getChatRoom(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      chatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        groupName: '',
        groupImage: '',
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          controller: _searchController,
        ),
      ),
      body: ListView.builder(
        itemCount: _resultList.length,
        itemBuilder: (context, index) {
          UserModel searchedUser = UserModel.fromMap(_resultList[index].data());

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
              onTap: () async {
                ChatRoomModel? chatRoomModel = await getChatRoom(searchedUser);
                if (chatRoomModel != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomPage(
                        chatroom: chatRoomModel,
                        firebaseUser: widget.firebaseUser,
                        userModel: widget.userModel,
                        targetUser: searchedUser,
                      ),
                    ),
                  );
                }
              },
              leading: CircleAvatar(
                backgroundImage: NetworkImage(_resultList[index]['profilePic']),
                backgroundColor: Colors.grey[500],
              ),
              title: Text(_resultList[index]['fullName']),
              subtitle: Text(_resultList[index]['email']),
            ),
          );
        },
      ),
    );
  }
}

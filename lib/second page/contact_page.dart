import 'package:chat_app/second%20page/contactlist_page.dart';
import 'package:chat_app/second%20page/menu.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../bookings/bookings_screen.dart';
import '../group/group_chat_page/groupchat_page.dart';

import '../models/user_model.dart';

class ContactPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ContactPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  int index = 0;
  late List<Widget> widgetList;
  @override
  void initState() {
    super.initState();
    widgetList = [
      ContactlistPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      const Center(child: Text("Updates", style: TextStyle(fontSize: 40))),
      GroupChatPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      const BookingPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyMenu(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      body: SafeArea(child: widgetList[index]),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff0E57A5),
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(
              icon: Icon(Icons.update_sharp), label: "Updates"),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined), label: "Groups"),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_online), label: "Bookings"),
        ],
      ),
    );
  }
}

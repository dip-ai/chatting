import 'dart:developer';
import 'package:chat_app/group/screens/create_group_screen.dart';
import 'package:chat_app/second%20page/settingspage/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';

class MyMenu extends StatelessWidget implements PreferredSizeWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyMenu(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      title: const Text(
        "Chat App",
        style: TextStyle(color: Color(0xff0E57A5), fontWeight: FontWeight.bold),
      ),
      actions: [
        PopupMenuButton<int>(
          onSelected: (item) => _onSelected(context, item),
          itemBuilder: (context) => [
            const PopupMenuItem<int>(
              value: 0,
              child: Text('New group'),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text('New broadcast'),
            ),
            const PopupMenuItem<int>(
              value: 2,
              child: Text('Linked devices'),
            ),
            const PopupMenuItem<int>(
              value: 3,
              child: Text('Settings'),
            ),
          ],
          icon: const Icon(
            Icons.menu,
            color: Color(0xff0E57A5),
          ),
          offset: const Offset(0, 40),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return CreateGroupScreen(
                userModel: userModel, firebaseUser: firebaseUser);
          }),
        );
        log('New group selected');
        break;
      case 1:
        log('New broadcast selected');
        break;
      case 2:
        log('Linked devices selected');
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }
}

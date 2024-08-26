import 'package:chat_app/auth/Screen/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/Screen/login_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }),
                );
              },
              icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Account'),
            subtitle:
                const Text('Privacy, security Notofication, change number'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_open_rounded),
            title: const Text('Privacy'),
            subtitle: const Text('Block Contacts, disappering messages'),
            onTap: () {
              // Navigate to Account settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text('Avtar'),
            subtitle: const Text('Create, edit, profie, photo'),
            onTap: () {
              // Navigate to Account settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_open_rounded),
            title: const Text('Favourites'),
            subtitle: const Text('Add, reorder, remove'),
            onTap: () {
              // Navigate to Account settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chats'),
            subtitle: const Text('Theme, chat history, wallpaper'),
            onTap: () {
              // Navigate to Chats settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Message, group & call tones'),
            onTap: () {
              // Navigate to Notifications settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Storage and data'),
            subtitle: const Text('Network usage, auto-download'),
            onTap: () {
              // Navigate to Storage and data settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('App language'),
            subtitle: const Text('English(Device\'s language)'),
            onTap: () {
              // Navigate to Storage and data settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            subtitle: const Text('Help center, contact us, privacy policy'),
            onTap: () {
              // Navigate to Help settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Invite a friend'),
            onTap: () {
              // Navigate to Invite a friend
            },
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_setup_rounded),
            title: const Text('App Update'),
            onTap: () {
              // Navigate to Invite a friend
            },
          ),
        ],
      ),
    );
  }
}

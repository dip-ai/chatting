import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../second page/contact_page.dart';

class ChatPage extends StatefulWidget {
  final Contact contact;
  const ChatPage({super.key, required this.contact});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedMessages = prefs.getStringList(widget.contact.name);

    if (storedMessages != null) {
      setState(() {
        _messages = storedMessages
            .map((message) => Map<String, String>.from(json.decode(message)))
            .toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> storedMessages =
          _messages.map((message) => json.encode(message)).toList();
      await prefs.setStringList(widget.contact.name, storedMessages);
    } catch (e) {
      debugPrint("Error saving messages: $e");
    }
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({"sender": "me", "message": message});
    });
    _saveMessages();
    _replyToMessage(message);
  }

  void _replyToMessage(String message) {
    String reply;
    if (message.toLowerCase() == 'hi' || message.toLowerCase() == 'hello') {
      reply = 'Hello';
    } else if (message.toLowerCase() == 'how are you') {
      reply = 'fine. you?';
    } else {
      reply = 'I didn\'t understand that.';
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({"sender": "them", "message": reply});
      });
      _saveMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.contact.imagePath),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(widget.contact.name),
                Padding(
                  padding: const EdgeInsets.only(right: 80.0),
                  child: const Text(
                    "online",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12, color: Colors.cyan),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.video_call),
          SizedBox(width: 15),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.phone),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isMe = _messages[index]["sender"] == "me";
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF5A1BF8) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _messages[index]["message"]!,
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Type here...",
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                        ),
                        _messageController.text.isEmpty
                            ? Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.sticky_note_2_rounded),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () {},
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  String message =
                                      _messageController.text.trim();
                                  if (message.isNotEmpty) {
                                    _sendMessage(message);
                                    _messageController.clear();
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

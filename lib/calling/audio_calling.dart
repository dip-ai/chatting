import 'dart:math';

import 'package:chat_app/calling/utils.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallingScreen extends StatefulWidget {
  final UserModel userModel;
  const AudioCallingScreen({super.key, required this.userModel});

  @override
  State<AudioCallingScreen> createState() => _AudioCallingScreenState();
}

final userId = Random().nextInt(10000).toString();

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  final callIdController = TextEditingController(text: '1');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Calling'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: callIdController,
              decoration: const InputDecoration(
                  hintText: 'Enter callign id', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AudioCallingPage(
                                callingId: callIdController.text.toString(),
                                userModel: widget.userModel,
                              )));
                },
                child: const Text('Call'))
          ],
        ),
      ),
    );
  }
}

class AudioCallingPage extends StatelessWidget {
  final String callingId;
  final UserModel userModel;
  const AudioCallingPage(
      {super.key, required this.callingId, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ZegoUIKitPrebuiltCall(
      appID: Utils.appId,
      appSign: Utils.appSignin,
      userID: userId,
      callID: callingId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      userName: userModel.fullName!,
    ));
  }
}

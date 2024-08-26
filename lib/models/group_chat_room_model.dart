// group_chat_room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatRoomModel {
  String? chatroomid;
  String? admin;
  Map<String, bool>? participants;
  String? lastMessage;
  Timestamp? lastMessageTimestamp;
  Timestamp? createdAt;
  String? groupName;
  String? groupImage;

  GroupChatRoomModel({
    this.chatroomid,
    this.admin,
    this.participants,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.createdAt,
    this.groupName,
    this.groupImage,
  });

  // Convert a GroupChatRoomModel object into a map
  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'admin': admin,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'createdAt': createdAt,
      'groupName': groupName,
      'groupImage': groupImage,
    };
  }

  // Create a GroupChatRoomModel object from a map
  factory GroupChatRoomModel.fromMap(Map<String, dynamic> map) {
    return GroupChatRoomModel(
      chatroomid: map['chatroomid'],
      admin: map['admin'],
      participants: Map<String, bool>.from(map['participants']),
      lastMessage: map['lastMessage'],
      lastMessageTimestamp: map['lastMessageTimestamp'],
      createdAt: map['createdAt'],
      groupName: map['groupName'],
      groupImage: map['groupImage'],
    );
  }
}

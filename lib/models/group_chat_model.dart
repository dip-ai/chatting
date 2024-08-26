import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatRoomModel {
  String? chatroomid;
  String? admin;
  Map<String, dynamic>? participants;
  String? lastMessage;
  String? lastMessageSender;
  Timestamp? lastMessageTimestamp;
  Timestamp? createdAt;
  String? groupName;
  String? groupImage;

  GroupChatRoomModel({
    this.chatroomid,
    this.admin,
    this.participants,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTimestamp,
    this.createdAt,
    this.groupName,
    this.groupImage,
  });

  GroupChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    admin = map["admin"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastMessageSender = map["lastMessageSender"];
    lastMessageTimestamp = map["lastMessageTimestamp"];
    createdAt = map["createdAt"];
    groupName = map["groupName"];
    groupImage = map["groupImage"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "admin": admin,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageSender": lastMessageSender,
      "lastMessageTimestamp": lastMessageTimestamp,
      "createdAt": createdAt,
      "groupName": groupName,
      "groupImage": groupImage,
    };
  }
}

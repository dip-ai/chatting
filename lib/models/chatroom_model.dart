import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  Timestamp? lastMessageTimestamp;
  Timestamp? createdAt;

  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.createdAt,
    required String groupName,
    required String groupImage,
    String? admin,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];

    participants = map["participants"];
    lastMessage = map["lastmessage"];
    lastMessageTimestamp = map["lastMessageTimestamp"];
    createdAt = map["createdat"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      // Add this field
      "participants": participants,
      "lastmessage": lastMessage,
      "lastMessageTimestamp": lastMessageTimestamp,
      "createdat": createdAt,
    };
  }
}

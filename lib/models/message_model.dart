// class MessageModel {
//   String? messageid;
//   String? sender;
//   String? text;
//   bool? seen;
//   DateTime? createdon;

//   MessageModel(
//       {this.messageid, this.sender, this.text, this.seen, this.createdon});

//   MessageModel.fromMap(Map<String, dynamic> map) {
//     messageid = map["messageid"];
//     sender = map["sender"];
//     text = map["text"];
//     seen = map["seen"];
//     createdon = map["createdon"].toDate();
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       "messageid": messageid,
//       "sender": sender,
//       "text": text,
//       "seen": seen,
//       "createdon": createdon
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageid;
  String sender;
  Timestamp createdon;
  String text;
  bool seen;
  String? imageUrl;

  MessageModel({
    required this.messageid,
    required this.sender,
    required this.createdon,
    required this.text,
    required this.seen,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageid': messageid,
      'sender': sender,
      'createdon': createdon,
      'text': text,
      'seen': seen,
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageid: map['messageid'],
      sender: map['sender'],
      createdon: map['createdon'],
      text: map['text'],
      seen: map['seen'],
      imageUrl: map['imageUrl'],
    );
  }
}

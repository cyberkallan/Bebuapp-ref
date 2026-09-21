// To parse this JSON data, do
//
//     final personalChatModel = personalChatModelFromJson(jsonString);

import 'dart:convert';

PersonalChatModel personalChatModelFromJson(String str) => PersonalChatModel.fromJson(json.decode(str));

String personalChatModelToJson(PersonalChatModel data) => json.encode(data.toJson());

class PersonalChatModel {
  bool? status;
  String? message;
  String? chatTopicId;
  List<PersonalChat>? chat;

  PersonalChatModel({
    this.status,
    this.message,
    this.chatTopicId,
    this.chat,
  });

  factory PersonalChatModel.fromJson(Map<String, dynamic> json) => PersonalChatModel(
        status: json["status"],
        message: json["message"],
        chatTopicId: json["chatTopicId"],
        chat: json["chat"] == null ? [] : List<PersonalChat>.from(json["chat"]!.map((x) => PersonalChat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "chatTopicId": chatTopicId,
        "chat": chat == null ? [] : List<dynamic>.from(chat!.map((x) => x.toJson())),
      };
}

class PersonalChat {
  String? id;
  String? chatTopicId;
  String? senderId;
  String? message;
  String? image;
  String? audio;
  bool? isRead;
  String? callId;
  String? callDuration;
  String? date;
  int? messageType;
  int? callType;
  DateTime? createdAt;
  DateTime? updatedAt;

  PersonalChat({
    this.id,
    this.chatTopicId,
    this.senderId,
    this.message,
    this.image,
    this.audio,
    this.isRead,
    this.callId,
    this.callDuration,
    this.date,
    this.messageType,
    this.callType,
    this.createdAt,
    this.updatedAt,
  });

  factory PersonalChat.fromJson(Map<String, dynamic> json) => PersonalChat(
        id: json["_id"],
        chatTopicId: json["chatTopicId"],
        senderId: json["senderId"],
        message: json["message"],
        image: json["image"],
        audio: json["audio"],
        isRead: json["isRead"],
        callId: json["callId"],
        callDuration: json["callDuration"],
        date: json["date"],
        messageType: json["messageType"],
        callType: json["callType"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "chatTopicId": chatTopicId,
        "senderId": senderId,
        "message": message,
        "image": image,
        "audio": audio,
        "isRead": isRead,
        "callId": callId,
        "callDuration": callDuration,
        "date": date,
        "messageType": messageType,
        "callType": callType,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

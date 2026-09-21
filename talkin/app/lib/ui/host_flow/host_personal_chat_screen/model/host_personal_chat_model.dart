// To parse this JSON data, do
//
//     final hostPersonalChatModel = hostPersonalChatModelFromJson(jsonString);

import 'dart:convert';

HostPersonalChatModel hostPersonalChatModelFromJson(String str) => HostPersonalChatModel.fromJson(json.decode(str));

String hostPersonalChatModelToJson(HostPersonalChatModel data) => json.encode(data.toJson());

class HostPersonalChatModel {
  bool? status;
  String? message;
  String? chatTopic;
  List<ListenerChat>? chat;

  HostPersonalChatModel({
    this.status,
    this.message,
    this.chatTopic,
    this.chat,
  });

  factory HostPersonalChatModel.fromJson(Map<String, dynamic> json) => HostPersonalChatModel(
        status: json["status"],
        message: json["message"],
        chatTopic: json["chatTopic"],
        chat: json["chat"] == null ? [] : List<ListenerChat>.from(json["chat"]!.map((x) => ListenerChat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "chatTopic": chatTopic,
        "chat": chat == null ? [] : List<dynamic>.from(chat!.map((x) => x.toJson())),
      };
}

class ListenerChat {
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

  ListenerChat({
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

  factory ListenerChat.fromJson(Map<String, dynamic> json) => ListenerChat(
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

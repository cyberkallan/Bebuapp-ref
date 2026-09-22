// To parse this JSON data, do
//
//     final personalChatModel = personalChatModelFromJson(jsonString);

import 'dart:convert';

import 'package:talk_in/ui/user_flow/gifts/model/gift_model.dart';

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

  /// Present on messageType 6 (gift).
  GiftSnapshot? gift;

  /// Local-only delivery state for my own messages (never serialised).
  /// `pending` = optimistic, waiting for the server echo; `failed` = no echo
  /// within the timeout, tap to retry.
  bool pending;
  bool failed;

  /// Client-side id kept across the optimistic → server swap so the bubble
  /// keeps its widget identity (no flicker) and the echo can be matched.
  String? localId;

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
    this.gift,
    this.pending = false,
    this.failed = false,
    this.localId,
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
        date: json["date"]?.toString(),
        messageType: json["messageType"] is int ? json["messageType"] : int.tryParse(json["messageType"]?.toString() ?? ''),
        callType: json["callType"] is int ? json["callType"] : int.tryParse(json["callType"]?.toString() ?? ''),
        createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"].toString()),
        updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"].toString()),
        localId: json["localId"]?.toString(),
        gift: GiftSnapshot.tryParse(json),
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

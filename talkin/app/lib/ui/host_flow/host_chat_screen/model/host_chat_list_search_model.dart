// To parse this JSON data, do
//
//     final hostChatListSearchModel = hostChatListSearchModelFromJson(jsonString);

import 'dart:convert';

HostChatListSearchModel hostChatListSearchModelFromJson(String str) => HostChatListSearchModel.fromJson(json.decode(str));

String hostChatListSearchModelToJson(HostChatListSearchModel data) => json.encode(data.toJson());

class HostChatListSearchModel {
  bool? status;
  String? message;
  List<HostSearchChatList>? data;

  HostChatListSearchModel({
    this.status,
    this.message,
    this.data,
  });

  factory HostChatListSearchModel.fromJson(Map<String, dynamic> json) => HostChatListSearchModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<HostSearchChatList>.from(json["data"]!.map((x) => HostSearchChatList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HostSearchChatList {
  String? chatUserId;
  String? nickName;
  String? fullName;
  String? profilePic;
  bool? isOnline;
  String? lastMessage;
  DateTime? messageTime;

  HostSearchChatList({
    this.chatUserId,
    this.nickName,
    this.fullName,
    this.profilePic,
    this.isOnline,
    this.lastMessage,
    this.messageTime,
  });

  factory HostSearchChatList.fromJson(Map<String, dynamic> json) => HostSearchChatList(
        chatUserId: json["chatUserId"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        profilePic: json["profilePic"],
        isOnline: json["isOnline"],
        lastMessage: json["lastMessage"],
        messageTime: json["messageTime"] == null ? null : DateTime.parse(json["messageTime"]),
      );

  Map<String, dynamic> toJson() => {
        "chatUserId": chatUserId,
        "nickName": nickName,
        "fullName": fullName,
        "profilePic": profilePic,
        "isOnline": isOnline,
        "lastMessage": lastMessage,
        "messageTime": messageTime?.toIso8601String(),
      };
}

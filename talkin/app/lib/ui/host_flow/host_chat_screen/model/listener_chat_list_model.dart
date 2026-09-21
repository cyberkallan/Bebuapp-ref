// To parse this JSON data, do
//
//     final listenerChatListModel = listenerChatListModelFromJson(jsonString);

import 'dart:convert';

ListenerChatListModel listenerChatListModelFromJson(String str) => ListenerChatListModel.fromJson(json.decode(str));

String listenerChatListModelToJson(ListenerChatListModel data) => json.encode(data.toJson());

class ListenerChatListModel {
  bool? status;
  String? message;
  List<ListenerChatList>? chatList;

  ListenerChatListModel({
    this.status,
    this.message,
    this.chatList,
  });

  factory ListenerChatListModel.fromJson(Map<String, dynamic> json) => ListenerChatListModel(
        status: json["status"],
        message: json["message"],
        chatList: json["chatList"] == null ? [] : List<ListenerChatList>.from(json["chatList"]!.map((x) => ListenerChatList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "chatList": chatList == null ? [] : List<dynamic>.from(chatList!.map((x) => x.toJson())),
      };
}

class ListenerChatList {
  String? id;
  String? userId;
  String? nickName;
  String? fullName;
  String? profilePic;
  bool? isOnline;
  String? chatTopicId;
  String? senderId;
  String? message;
  int? messageType;
  DateTime? lastChatMessageTime;
  int? unreadCount;
  String? time;

  ListenerChatList({
    this.id,
    this.userId,
    this.nickName,
    this.fullName,
    this.profilePic,
    this.isOnline,
    this.chatTopicId,
    this.senderId,
    this.message,
    this.messageType,
    this.lastChatMessageTime,
    this.unreadCount,
    this.time,
  });

  factory ListenerChatList.fromJson(Map<String, dynamic> json) => ListenerChatList(
        id: json["_id"],
        userId: json["userId"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        profilePic: json["profilePic"],
        isOnline: json["isOnline"],
        chatTopicId: json["chatTopicId"],
        senderId: json["senderId"],
        message: json["message"],
        messageType: json["messageType"],
        lastChatMessageTime: json["lastChatMessageTime"] == null ? null : DateTime.parse(json["lastChatMessageTime"]),
        unreadCount: json["unreadCount"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "nickName": nickName,
        "fullName": fullName,
        "profilePic": profilePic,
        "isOnline": isOnline,
        "chatTopicId": chatTopicId,
        "senderId": senderId,
        "message": message,
        "messageType": messageType,
        "lastChatMessageTime": lastChatMessageTime?.toIso8601String(),
        "unreadCount": unreadCount,
        "time": time,
      };
}

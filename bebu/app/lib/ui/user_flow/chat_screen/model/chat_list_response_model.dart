// To parse this JSON data, do
//
//     final chatListResponseModel = chatListResponseModelFromJson(jsonString);

import 'dart:convert';

ChatListResponseModel chatListResponseModelFromJson(String str) => ChatListResponseModel.fromJson(json.decode(str));

String chatListResponseModelToJson(ChatListResponseModel data) => json.encode(data.toJson());

class ChatListResponseModel {
  bool? status;
  String? message;
  List<ChatList>? chatList;

  ChatListResponseModel({
    this.status,
    this.message,
    this.chatList,
  });

  factory ChatListResponseModel.fromJson(Map<String, dynamic> json) => ChatListResponseModel(
        status: json["status"],
        message: json["message"],
        chatList: json["chatList"] == null ? [] : List<ChatList>.from(json["chatList"]!.map((x) => ChatList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "chatList": chatList == null ? [] : List<dynamic>.from(chatList!.map((x) => x.toJson())),
      };
}

class ChatList {
  String? id;
  String? receiverId;
  String? name;
  String? image;
  bool? isOnline;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  dynamic video;
  bool? isFake;
  String? chatTopicId;
  String? senderId;
  int? messageType;
  String? message;
  DateTime? lastChatMessageTime;
  int? unreadCount;
  String? time;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;

  ChatList({
    this.id,
    this.receiverId,
    this.name,
    this.image,
    this.isOnline,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.video,
    this.isFake,
    this.chatTopicId,
    this.senderId,
    this.messageType,
    this.message,
    this.lastChatMessageTime,
    this.unreadCount,
    this.time,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
        id: json["_id"],
        receiverId: json["receiverId"],
        name: json["name"],
        image: json["image"],
        isOnline: json["isOnline"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        video: json["video"],
        isFake: json["isFake"],
        chatTopicId: json["chatTopicId"],
        senderId: json["senderId"],
        messageType: json["messageType"],
        message: json["message"],
        lastChatMessageTime: json["lastChatMessageTime"] == null ? null : DateTime.parse(json["lastChatMessageTime"]),
        unreadCount: json["unreadCount"],
        time: json["time"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "receiverId": receiverId,
        "name": name,
        "image": image,
        "isOnline": isOnline,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "video": video,
        "isFake": isFake,
        "chatTopicId": chatTopicId,
        "senderId": senderId,
        "messageType": messageType,
        "message": message,
        "lastChatMessageTime": lastChatMessageTime?.toIso8601String(),
        "unreadCount": unreadCount,
        "time": time,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
      };
}

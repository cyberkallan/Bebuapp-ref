// To parse this JSON data, do
//
//     final chatListSearchModel = chatListSearchModelFromJson(jsonString);

import 'dart:convert';

ChatListSearchModel chatListSearchModelFromJson(String str) => ChatListSearchModel.fromJson(json.decode(str));

String chatListSearchModelToJson(ChatListSearchModel data) => json.encode(data.toJson());

class ChatListSearchModel {
  bool? status;
  String? message;
  List<ChatListSearch>? data;

  ChatListSearchModel({
    this.status,
    this.message,
    this.data,
  });

  factory ChatListSearchModel.fromJson(Map<String, dynamic> json) => ChatListSearchModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<ChatListSearch>.from(json["data"]!.map((x) => ChatListSearch.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ChatListSearch {
  String? chatUserId;
  String? name;
  String? nickName;
  String? image;
  bool? isOnline;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  String? lastMessage;
  DateTime? messageTime;
  bool? isFake;
  List<String>? video;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;

  ChatListSearch({
    this.chatUserId,
    this.name,
    this.nickName,
    this.image,
    this.isOnline,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.lastMessage,
    this.messageTime,
    this.video,
    this.isFake,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
  });

  factory ChatListSearch.fromJson(Map<String, dynamic> json) => ChatListSearch(
        chatUserId: json["chatUserId"],
        name: json["name"],
        nickName: json["nickName"],
        image: json["image"],
        isOnline: json["isOnline"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        lastMessage: json["lastMessage"],
        messageTime: json["messageTime"] == null ? null : DateTime.parse(json["messageTime"]),
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
      );

  Map<String, dynamic> toJson() => {
        "chatUserId": chatUserId,
        "name": name,
        "nickName": nickName,
        "image": image,
        "isOnline": isOnline,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "lastMessage": lastMessage,
        "messageTime": messageTime?.toIso8601String(),
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
      };
}

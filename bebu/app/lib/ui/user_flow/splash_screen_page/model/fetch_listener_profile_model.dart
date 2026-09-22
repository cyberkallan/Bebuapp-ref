// To parse this JSON data, do
//
//     final fetchListenerProfileModel = fetchListenerProfileModelFromJson(jsonString);

import 'dart:convert';

FetchListenerProfileModel fetchListenerProfileModelFromJson(String str) => FetchListenerProfileModel.fromJson(json.decode(str));

String fetchListenerProfileModelToJson(FetchListenerProfileModel data) => json.encode(data.toJson());

class FetchListenerProfileModel {
  bool? status;
  String? message;
  Data? data;

  FetchListenerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory FetchListenerProfileModel.fromJson(Map<String, dynamic> json) => FetchListenerProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? id;
  String? name;
  String? nickName;
  final String? uniqueId;

  String? email;
  String? selfIntro;
  List<String>? talkTopics;
  List<String>? language;
  String? image;
  num? ratePrivateVideoCall;
  num? ratePrivateAudioCall;
  num? rateRandomVideoCall;
  num? rateRandomAudioCall;
  num? rating;
  num? callCount;
  String? experience;
  num? currentCoinBalance;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;
  bool? isNotificationEnabled;
  bool? isFake;
  List<String>? video;

  Data({
    this.id,
    this.name,
    this.nickName,
    this.uniqueId,
    this.email,
    this.selfIntro,
    this.talkTopics,
    this.language,
    this.image,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.rateRandomVideoCall,
    this.rateRandomAudioCall,
    this.rating,
    this.callCount,
    this.experience,
    this.currentCoinBalance,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
    this.isNotificationEnabled,
    this.video,
    this.isFake,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        name: json["name"],
        nickName: json["nickName"],
        uniqueId: json["uniqueId"],
        email: json["email"],
        selfIntro: json["selfIntro"],
        talkTopics: json["talkTopics"] == null ? [] : List<String>.from(json["talkTopics"]!.map((x) => x)),
        language: json["language"] == null ? [] : List<String>.from(json["language"]!.map((x) => x)),
        image: json["image"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rateRandomVideoCall: json["rateRandomVideoCall"],
        rateRandomAudioCall: json["rateRandomAudioCall"],
        rating: json["rating"],
        callCount: json["callCount"],
        experience: json["experience"],
        currentCoinBalance: json["currentCoinBalance"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
        isNotificationEnabled: json["isNotificationEnabled"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "nickName": nickName,
        "uniqueId": uniqueId,
        "email": email,
        "selfIntro": selfIntro,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!.map((x) => x)),
        "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rateRandomVideoCall": rateRandomVideoCall,
        "rateRandomAudioCall": rateRandomAudioCall,
        "rating": rating,
        "callCount": callCount,
        "experience": experience,
        "currentCoinBalance": currentCoinBalance,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "isNotificationEnabled": isNotificationEnabled,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
      };
}

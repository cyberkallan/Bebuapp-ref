// To parse this JSON data, do
//
//     final topListenersModel = topListenersModelFromJson(jsonString);

import 'dart:convert';

TopListenersModel topListenersModelFromJson(String str) => TopListenersModel.fromJson(json.decode(str));

String topListenersModelToJson(TopListenersModel data) => json.encode(data.toJson());

class TopListenersModel {
  bool? status;
  String? message;
  List<TopListeners>? data;

  TopListenersModel({
    this.status,
    this.message,
    this.data,
  });

  factory TopListenersModel.fromJson(Map<String, dynamic> json) => TopListenersModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<TopListeners>.from(json["data"]!.map((x) => TopListeners.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TopListeners {
  String? id;
  String? name;
  int? age;
  List<String>? talkTopics;
  List<String>? language;
  String? image;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  int? rateRandomVideoCall;
  int? rateRandomAudioCall;
  List<String>? video;
  double? rating;
  int? callCount;
  String? experience;
  bool? isFake;
  bool? isOnline;
  String? statusLabel;
  String? uniqueId;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;
  String? audio;

  TopListeners({
    this.id,
    this.name,
    this.age,
    this.talkTopics,
    this.language,
    this.image,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.rateRandomVideoCall,
    this.rateRandomAudioCall,
    this.video,
    this.rating,
    this.callCount,
    this.experience,
    this.isFake,
    this.isOnline,
    this.statusLabel,
    this.uniqueId,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
    this.audio,
  });

  factory TopListeners.fromJson(Map<String, dynamic> json) => TopListeners(
        id: json["_id"],
        name: json["name"],
        age: json["age"],
        talkTopics: json["talkTopics"] == null ? [] : List<String>.from(json["talkTopics"]!.map((x) => x)),
        language: json["language"] == null ? [] : List<String>.from(json["language"]!.map((x) => x)),
        image: json["image"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rateRandomVideoCall: json["rateRandomVideoCall"],
        rateRandomAudioCall: json["rateRandomAudioCall"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        rating: json["rating"]?.toDouble(),
        callCount: json["callCount"],
        experience: json["experience"],
        isFake: json["isFake"],
        isOnline: json["isOnline"],
        statusLabel: json["statusLabel"],
        uniqueId: json["uniqueId"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
        audio: json["audio"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "age": age,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!.map((x) => x)),
        "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rateRandomVideoCall": rateRandomVideoCall,
        "rateRandomAudioCall": rateRandomAudioCall,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "rating": rating,
        "callCount": callCount,
        "experience": experience,
        "isFake": isFake,
        "isOnline": isOnline,
        "statusLabel": statusLabel,
        "uniqueId": uniqueId,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "audio": audio,
      };
}

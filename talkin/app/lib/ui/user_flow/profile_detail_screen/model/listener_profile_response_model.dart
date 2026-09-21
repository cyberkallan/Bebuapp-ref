import 'dart:convert';

ListenerProfileModel listenerProfileModelFromJson(String str) => ListenerProfileModel.fromJson(json.decode(str));

String listenerProfileModelToJson(ListenerProfileModel data) => json.encode(data.toJson());

class ListenerProfileModel {
  final bool? status;
  final String? message;
  final ListenerData? data;

  ListenerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory ListenerProfileModel.fromJson(Map<String, dynamic> json) => ListenerProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ListenerData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ListenerData {
  final String? id;
  final String? name;
  final String? selfIntro;
  final List<String>? talkTopics;
  final List<String>? language;
  final String? image;
  final int? ratePrivateVideoCall;
  final int? ratePrivateAudioCall;
  final int? rateRandomVideoCall;
  final int? rateRandomAudioCall;
  final double? rating;
  final int? callCount;
  final String? experience;
  final String? statusLabel;
  int? totalCoins;
  final int? age; // Optional, included for compatibility
  bool? isFake;
  List<String>? video;
  String? uniqueId;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;
  String? audio;

  ListenerData({
    this.id,
    this.name,
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
    this.statusLabel,
    this.age,
    this.totalCoins,
    this.video,
    this.isFake,
    this.uniqueId,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
    this.audio,
  });

  factory ListenerData.fromJson(Map<String, dynamic> json) => ListenerData(
        id: json["_id"],
        name: json["name"],
        selfIntro: json["selfIntro"],
        talkTopics: json["talkTopics"] == null ? [] : List<String>.from(json["talkTopics"]),
        language: json["language"] == null ? [] : List<String>.from(json["language"]),
        image: json["image"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rateRandomVideoCall: json["rateRandomVideoCall"],
        rateRandomAudioCall: json["rateRandomAudioCall"],
        rating: json["rating"].toDouble(),
        callCount: json["callCount"],
        experience: json["experience"],
        statusLabel: json["statusLabel"],
        age: json["age"],
        totalCoins: json["totalCoins"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],
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
        "selfIntro": selfIntro,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!),
        "language": language == null ? [] : List<dynamic>.from(language!),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rateRandomVideoCall": rateRandomVideoCall,
        "rateRandomAudioCall": rateRandomAudioCall,
        "rating": rating,
        "callCount": callCount,
        "experience": experience,
        "statusLabel": statusLabel,
        "age": age,
        "totalCoins": totalCoins,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
        "uniqueId": uniqueId,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "audio": audio,
      };
}

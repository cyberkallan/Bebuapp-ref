// To parse this JSON data, do
//
//     final randomAvailableListenerModel = randomAvailableListenerModelFromJson(jsonString);

import 'dart:convert';

RandomAvailableListenerModel randomAvailableListenerModelFromJson(String str) => RandomAvailableListenerModel.fromJson(json.decode(str));

String randomAvailableListenerModelToJson(RandomAvailableListenerModel data) => json.encode(data.toJson());

class RandomAvailableListenerModel {
  bool? status;
  String? message;
  Data? data;

  RandomAvailableListenerModel({
    this.status,
    this.message,
    this.data,
  });

  factory RandomAvailableListenerModel.fromJson(Map<String, dynamic> json) => RandomAvailableListenerModel(
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
  String? userId;
  String? name;
  String? nickName;
  String? email;
  String? selfIntro;
  int? age;
  List<String>? talkTopics;
  List<String>? language;
  String? image;
  String? location;
  String? fcmToken;
  String? uniqueId;
  String? identityProofType;
  List<String>? identityProof;
  String? reason;
  int? status;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  int? rateRandomVideoCall;
  int? rateRandomAudioCall;
  List<dynamic>? video;
  double? rating;
  int? reviewCount;
  int? callCount;
  String? experience;
  int? totalCoins;
  int? currentCoinBalance;
  int? coinsRedeemed;
  double? amountRedeemed;
  bool? isAvailableForRandomCall;
  bool? isNotificationEnabled;
  bool? isFake;
  bool? isBlock;
  bool? isOnline;
  bool? isBusy;
  dynamic callId;
  String? date;
  DateTime? reviewAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  String? audio;
  bool? isAvailableForChat;

  Data({
    this.id,
    this.userId,
    this.name,
    this.nickName,
    this.email,
    this.selfIntro,
    this.age,
    this.talkTopics,
    this.language,
    this.image,
    this.location,
    this.fcmToken,
    this.uniqueId,
    this.identityProofType,
    this.identityProof,
    this.reason,
    this.status,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.rateRandomVideoCall,
    this.rateRandomAudioCall,
    this.video,
    this.rating,
    this.reviewCount,
    this.callCount,
    this.experience,
    this.totalCoins,
    this.currentCoinBalance,
    this.coinsRedeemed,
    this.amountRedeemed,
    this.isAvailableForRandomCall,
    this.isNotificationEnabled,
    this.isFake,
    this.isBlock,
    this.isOnline,
    this.isBusy,
    this.callId,
    this.date,
    this.reviewAt,
    this.createdAt,
    this.updatedAt,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.audio,
    this.isAvailableForChat,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        userId: json["userId"],
        name: json["name"],
        nickName: json["nickName"],
        email: json["email"],
        selfIntro: json["selfIntro"],
        age: json["age"],
        talkTopics: json["talkTopics"] == null ? [] : List<String>.from(json["talkTopics"]!.map((x) => x)),
        language: json["language"] == null ? [] : List<String>.from(json["language"]!.map((x) => x)),
        image: json["image"],
        location: json["location"],
        fcmToken: json["fcmToken"],
        uniqueId: json["uniqueId"],
        identityProofType: json["identityProofType"],
        identityProof: json["identityProof"] == null ? [] : List<String>.from(json["identityProof"]!.map((x) => x)),
        reason: json["reason"],
        status: json["status"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rateRandomVideoCall: json["rateRandomVideoCall"],
        rateRandomAudioCall: json["rateRandomAudioCall"],
        video: json["video"] == null ? [] : List<dynamic>.from(json["video"]!.map((x) => x)),
        rating: json["rating"] is int ? (json["rating"] as int).toDouble() : json["rating"],
        reviewCount: json["reviewCount"],
        callCount: json["callCount"],
        experience: json["experience"],
        totalCoins: json["totalCoins"],
        currentCoinBalance: json["currentCoinBalance"],
        coinsRedeemed: json["coinsRedeemed"],
        amountRedeemed: json["amountRedeemed"] is int ? (json["amountRedeemed"] as int).toDouble() : json["amountRedeemed"],
        isAvailableForRandomCall: json["isAvailableForRandomCall"],
        isNotificationEnabled: json["isNotificationEnabled"],
        isFake: json["isFake"],
        isBlock: json["isBlock"],
        isOnline: json["isOnline"],
        isBusy: json["isBusy"],
        callId: json["callId"],
        date: json["date"],
        reviewAt: json["reviewAt"] == null ? null : DateTime.parse(json["reviewAt"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        audio: json["audio"],
        isAvailableForChat: json["isAvailableForChat"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "name": name,
        "nickName": nickName,
        "email": email,
        "selfIntro": selfIntro,
        "age": age,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!.map((x) => x)),
        "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
        "image": image,
        "location": location,
        "fcmToken": fcmToken,
        "uniqueId": uniqueId,
        "identityProofType": identityProofType,
        "identityProof": identityProof == null ? [] : List<dynamic>.from(identityProof!.map((x) => x)),
        "reason": reason,
        "status": status,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rateRandomVideoCall": rateRandomVideoCall,
        "rateRandomAudioCall": rateRandomAudioCall,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "rating": rating,
        "reviewCount": reviewCount,
        "callCount": callCount,
        "experience": experience,
        "totalCoins": totalCoins,
        "currentCoinBalance": currentCoinBalance,
        "coinsRedeemed": coinsRedeemed,
        "amountRedeemed": amountRedeemed,
        "isAvailableForRandomCall": isAvailableForRandomCall,
        "isNotificationEnabled": isNotificationEnabled,
        "isFake": isFake,
        "isBlock": isBlock,
        "isOnline": isOnline,
        "isBusy": isBusy,
        "callId": callId,
        "date": date,
        "reviewAt": reviewAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "audio": audio,
        "isAvailableForChat": isAvailableForChat,
      };
}

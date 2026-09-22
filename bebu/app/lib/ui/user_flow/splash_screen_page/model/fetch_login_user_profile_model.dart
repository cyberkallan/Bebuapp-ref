// To parse this JSON data, do
//
//     final fetchLoginUserProfileModel = fetchLoginUserProfileModelFromJson(jsonString);

import 'dart:convert';

FetchLoginUserProfileModel fetchLoginUserProfileModelFromJson(String str) => FetchLoginUserProfileModel.fromJson(json.decode(str));

String fetchLoginUserProfileModelToJson(FetchLoginUserProfileModel data) => json.encode(data.toJson());

class FetchLoginUserProfileModel {
  final bool? status;
  final String? message;
  final User? user;

  FetchLoginUserProfileModel({
    this.status,
    this.message,
    this.user,
  });

  factory FetchLoginUserProfileModel.fromJson(Map<String, dynamic> json) => FetchLoginUserProfileModel(
        status: json["status"],
        message: json["message"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user": user?.toJson(),
      };
}

class User {
  String? id;
  String? nickName;
  String? fullName;
  String? birthDate;
  String? gender;
  String? bio;
  int? age;
  String? countryCode;
  String? phoneNumber;
  String? profilePic;
  String? email;
  String? password;
  String? countryFlag;
  String? country;
  int? loginType;
  String? identity;
  String? fcmToken;
  String? uniqueId;
  String? firebaseId;
  String? authProvider;
  int? coins;
  int? coinsSpent;
  int? coinsRecharged;
  bool? isBlock;
  bool? isOnline;
  bool? isBusy;
  bool? isNotificationEnabled;
  dynamic callId;
  bool? isListener;
  dynamic listenerId;
  String? lastlogin;
  String? date;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.nickName,
    this.fullName,
    this.birthDate,
    this.gender,
    this.bio,
    this.age,
    this.countryCode,
    this.phoneNumber,
    this.profilePic,
    this.email,
    this.password,
    this.countryFlag,
    this.country,
    this.loginType,
    this.identity,
    this.fcmToken,
    this.uniqueId,
    this.firebaseId,
    this.authProvider,
    this.coins,
    this.coinsSpent,
    this.coinsRecharged,
    this.isBlock,
    this.isOnline,
    this.isBusy,
    this.isNotificationEnabled,
    this.callId,
    this.isListener,
    this.listenerId,
    this.lastlogin,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        birthDate: json["birthDate"],
        gender: json["gender"],
        bio: json["bio"],
        age: json["age"],
        countryCode: json["countryCode"],
        phoneNumber: json["phoneNumber"],
        profilePic: json["profilePic"],
        email: json["email"],
        password: json["password"],
        countryFlag: json["countryFlag"],
        country: json["country"],
        loginType: json["loginType"],
        identity: json["identity"],
        fcmToken: json["fcmToken"],
        uniqueId: json["uniqueId"],
        firebaseId: json["firebaseId"],
        authProvider: json["authProvider"],
        coins: json["coins"],
        coinsSpent: json["coinsSpent"],
        coinsRecharged: json["coinsRecharged"],
        isBlock: json["isBlock"],
        isOnline: json["isOnline"],
        isBusy: json["isBusy"],
        isNotificationEnabled: json["isNotificationEnabled"],
        callId: json["callId"],
        isListener: json["isListener"],
        listenerId: json["listenerId"],
        lastlogin: json["lastlogin"],
        date: json["date"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "nickName": nickName,
        "fullName": fullName,
        "birthDate": birthDate,
        "gender": gender,
        "bio": bio,
        "age": age,
        "countryCode": countryCode,
        "phoneNumber": phoneNumber,
        "profilePic": profilePic,
        "email": email,
        "password": password,
        "countryFlag": countryFlag,
        "country": country,
        "loginType": loginType,
        "identity": identity,
        "fcmToken": fcmToken,
        "uniqueId": uniqueId,
        "firebaseId": firebaseId,
        "authProvider": authProvider,
        "coins": coins,
        "coinsSpent": coinsSpent,
        "coinsRecharged": coinsRecharged,
        "isBlock": isBlock,
        "isOnline": isOnline,
        "isBusy": isBusy,
        "isNotificationEnabled": isNotificationEnabled,
        "callId": callId,
        "isListener": isListener,
        "listenerId": listenerId,
        "lastlogin": lastlogin,
        "date": date,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

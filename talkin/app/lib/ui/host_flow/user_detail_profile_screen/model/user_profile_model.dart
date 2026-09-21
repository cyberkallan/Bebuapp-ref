// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) => UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) => json.encode(data.toJson());

class UserProfileModel {
  bool? status;
  String? message;
  User? user;

  UserProfileModel({
    this.status,
    this.message,
    this.user,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
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
  String? profilePic;
  String? email;
  String? countryFlag;
  String? country;
  String? uniqueId;
  bool? isOnline;

  User({
    this.id,
    this.nickName,
    this.fullName,
    this.birthDate,
    this.gender,
    this.bio,
    this.age,
    this.profilePic,
    this.email,
    this.countryFlag,
    this.country,
    this.uniqueId,
    this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        birthDate: json["birthDate"],
        gender: json["gender"],
        bio: json["bio"],
        age: json["age"],
        profilePic: json["profilePic"],
        email: json["email"],
        countryFlag: json["countryFlag"],
        country: json["country"],
        uniqueId: json["uniqueId"],
        isOnline: json["isOnline"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "nickName": nickName,
        "fullName": fullName,
        "birthDate": birthDate,
        "gender": gender,
        "bio": bio,
        "age": age,
        "profilePic": profilePic,
        "email": email,
        "countryFlag": countryFlag,
        "country": country,
        "uniqueId": uniqueId,
        "isOnline": isOnline,
      };
}

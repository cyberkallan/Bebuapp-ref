// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  final bool? status;
  final String? message;
  final User? user;
  final bool? signUp;

  LoginModel({
    this.status,
    this.message,
    this.user,
    this.signUp,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        message: json["message"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        signUp: json["signUp"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user": user?.toJson(),
        "signUp": signUp,
      };
}

class User {
  final String? id;
  final String? nickName;
  final String? fullName;
  final String? profilePic;
  final String? email;
  final int? loginType;
  final String? fcmToken;
  final bool? isBlock;
  final bool? isListener;
  final dynamic listenerId;
  final String? lastlogin;
  final DateTime? updatedAt;

  User({
    this.id,
    this.nickName,
    this.fullName,
    this.profilePic,
    this.email,
    this.loginType,
    this.fcmToken,
    this.isBlock,
    this.isListener,
    this.listenerId,
    this.lastlogin,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        profilePic: json["profilePic"],
        email: json["email"],
        loginType: json["loginType"],
        fcmToken: json["fcmToken"],
        isBlock: json["isBlock"],
        isListener: json["isListener"],
        listenerId: json["listenerId"],
        lastlogin: json["lastlogin"],
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "nickName": nickName,
        "fullName": fullName,
        "profilePic": profilePic,
        "email": email,
        "loginType": loginType,
        "fcmToken": fcmToken,
        "isBlock": isBlock,
        "isListener": isListener,
        "listenerId": listenerId,
        "lastlogin": lastlogin,
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

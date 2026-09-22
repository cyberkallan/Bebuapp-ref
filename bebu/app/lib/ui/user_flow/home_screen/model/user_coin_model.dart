// To parse this JSON data, do
//
//     final userCoinModel = userCoinModelFromJson(jsonString);

import 'dart:convert';

UserCoinModel userCoinModelFromJson(String str) => UserCoinModel.fromJson(json.decode(str));

String userCoinModelToJson(UserCoinModel data) => json.encode(data.toJson());

class UserCoinModel {
  bool? status;
  String? message;
  int? coin;

  UserCoinModel({
    this.status,
    this.message,
    this.coin,
  });

  factory UserCoinModel.fromJson(Map<String, dynamic> json) => UserCoinModel(
        status: json["status"],
        message: json["message"],
        coin: json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "coin": coin,
      };
}

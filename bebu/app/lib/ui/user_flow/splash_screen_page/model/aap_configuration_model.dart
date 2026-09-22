// To parse this JSON data, do
//
//     final appConfigurationModel = appConfigurationModelFromJson(jsonString);

import 'dart:convert';

AppConfigurationModel appConfigurationModelFromJson(String str) => AppConfigurationModel.fromJson(json.decode(str));

String appConfigurationModelToJson(AppConfigurationModel data) => json.encode(data.toJson());

class AppConfigurationModel {
  bool? status;
  String? message;
  Data? data;

  AppConfigurationModel({
    this.status,
    this.message,
    this.data,
  });

  factory AppConfigurationModel.fromJson(Map<String, dynamic> json) => AppConfigurationModel(
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
  String? userPrivacyPolicyUrl;
  bool? isApplicationLive;
  Map<String, dynamic>? login;
  Map<String, dynamic>? appearance;
  int? welcomeCoins;
  Map<String, dynamic>? dailyReward;
  Map<String, dynamic>? premium;

  Data({
    this.userPrivacyPolicyUrl,
    this.isApplicationLive,
    this.login,
    this.appearance,
    this.welcomeCoins,
    this.dailyReward,
    this.premium,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userPrivacyPolicyUrl: json["userPrivacyPolicyUrl"],
        isApplicationLive: json["isApplicationLive"],
        login: json["login"] is Map ? Map<String, dynamic>.from(json["login"]) : null,
        appearance: json["appearance"] is Map ? Map<String, dynamic>.from(json["appearance"]) : null,
        welcomeCoins: (json["welcomeCoins"] as num?)?.toInt(),
        dailyReward: json["dailyReward"] is Map ? Map<String, dynamic>.from(json["dailyReward"]) : null,
        premium: json["premium"] is Map ? Map<String, dynamic>.from(json["premium"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "userPrivacyPolicyUrl": userPrivacyPolicyUrl,
        "isApplicationLive": isApplicationLive,
        "login": login,
        "appearance": appearance,
        "welcomeCoins": welcomeCoins,
        "dailyReward": dailyReward,
        "premium": premium,
      };
}

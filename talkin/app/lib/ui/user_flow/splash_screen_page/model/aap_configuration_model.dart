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

  Data({
    this.userPrivacyPolicyUrl,
    this.isApplicationLive,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userPrivacyPolicyUrl: json["userPrivacyPolicyUrl"],
        isApplicationLive: json["isApplicationLive"],
      );

  Map<String, dynamic> toJson() => {
        "userPrivacyPolicyUrl": userPrivacyPolicyUrl,
        "isApplicationLive": isApplicationLive,
      };
}

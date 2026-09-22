// To parse this JSON data, do
//
//     final notificationUpdateUserModel = notificationUpdateUserModelFromJson(jsonString);

import 'dart:convert';

NotificationUpdateUserModel notificationUpdateUserModelFromJson(String str) => NotificationUpdateUserModel.fromJson(json.decode(str));

String notificationUpdateUserModelToJson(NotificationUpdateUserModel data) => json.encode(data.toJson());

class NotificationUpdateUserModel {
  bool? status;
  String? message;

  NotificationUpdateUserModel({
    this.status,
    this.message,
  });

  factory NotificationUpdateUserModel.fromJson(Map<String, dynamic> json) => NotificationUpdateUserModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

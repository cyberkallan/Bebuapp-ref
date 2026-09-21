// To parse this JSON data, do
//
//     final notificationUpdateModel = notificationUpdateModelFromJson(jsonString);

import 'dart:convert';

NotificationUpdateModel notificationUpdateModelFromJson(String str) => NotificationUpdateModel.fromJson(json.decode(str));

String notificationUpdateModelToJson(NotificationUpdateModel data) => json.encode(data.toJson());

class NotificationUpdateModel {
  bool? status;
  String? message;

  NotificationUpdateModel({
    this.status,
    this.message,
  });

  factory NotificationUpdateModel.fromJson(Map<String, dynamic> json) => NotificationUpdateModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

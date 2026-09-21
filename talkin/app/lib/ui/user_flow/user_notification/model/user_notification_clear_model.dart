// To parse this JSON data, do
//
//     final notificationClearModel = notificationClearModelFromJson(jsonString);

import 'dart:convert';

NotificationClearModel notificationClearModelFromJson(String str) => NotificationClearModel.fromJson(json.decode(str));

String notificationClearModelToJson(NotificationClearModel data) => json.encode(data.toJson());

class NotificationClearModel {
  bool? status;
  String? message;

  NotificationClearModel({
    this.status,
    this.message,
  });

  factory NotificationClearModel.fromJson(Map<String, dynamic> json) => NotificationClearModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

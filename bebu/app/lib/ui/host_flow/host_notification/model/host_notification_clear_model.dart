// To parse this JSON data, do
//
//     final hostNotificationClearModel = hostNotificationClearModelFromJson(jsonString);

import 'dart:convert';

HostNotificationClearModel hostNotificationClearModelFromJson(String str) => HostNotificationClearModel.fromJson(json.decode(str));

String hostNotificationClearModelToJson(HostNotificationClearModel data) => json.encode(data.toJson());

class HostNotificationClearModel {
  bool? status;
  String? message;

  HostNotificationClearModel({
    this.status,
    this.message,
  });

  factory HostNotificationClearModel.fromJson(Map<String, dynamic> json) => HostNotificationClearModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

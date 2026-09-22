// To parse this JSON data, do
//
//     final hostNotificationModel = hostNotificationModelFromJson(jsonString);

import 'dart:convert';

HostNotificationModel hostNotificationModelFromJson(String str) => HostNotificationModel.fromJson(json.decode(str));

String hostNotificationModelToJson(HostNotificationModel data) => json.encode(data.toJson());

class HostNotificationModel {
  bool? status;
  String? message;
  List<Notification>? notification;

  HostNotificationModel({
    this.status,
    this.message,
    this.notification,
  });

  factory HostNotificationModel.fromJson(Map<String, dynamic> json) => HostNotificationModel(
        status: json["status"],
        message: json["message"],
        notification: json["notification"] == null ? [] : List<Notification>.from(json["notification"]!.map((x) => Notification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "notification": notification == null ? [] : List<dynamic>.from(notification!.map((x) => x.toJson())),
      };
}

class Notification {
  String? id;
  dynamic userId;
  String? listenerId;
  String? title;
  String? message;
  String? date;
  DateTime? createdAt;
  DateTime? updatedAt;

  Notification({
    this.id,
    this.userId,
    this.listenerId,
    this.title,
    this.message,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["_id"],
        userId: json["userId"],
        listenerId: json["listenerId"],
        title: json["title"],
        message: json["message"],
        date: json["date"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "listenerId": listenerId,
        "title": title,
        "message": message,
        "date": date,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

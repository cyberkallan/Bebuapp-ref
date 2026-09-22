// To parse this JSON data, do
//
//     final userNotificationModel = userNotificationModelFromJson(jsonString);

import 'dart:convert';

UserNotificationModel userNotificationModelFromJson(String str) => UserNotificationModel.fromJson(json.decode(str));

String userNotificationModelToJson(UserNotificationModel data) => json.encode(data.toJson());

class UserNotificationModel {
  bool? status;
  String? message;
  List<Notification>? notification;

  UserNotificationModel({
    this.status,
    this.message,
    this.notification,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) => UserNotificationModel(
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

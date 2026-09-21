// To parse this JSON data, do
//
//     final hostCallingHistoryModel = hostCallingHistoryModelFromJson(jsonString);

import 'dart:convert';

HostCallingHistoryModel hostCallingHistoryModelFromJson(String str) => HostCallingHistoryModel.fromJson(json.decode(str));

String hostCallingHistoryModelToJson(HostCallingHistoryModel data) => json.encode(data.toJson());

class HostCallingHistoryModel {
  bool? status;
  String? message;
  List<HostCallHistory>? data;

  HostCallingHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory HostCallingHistoryModel.fromJson(Map<String, dynamic> json) => HostCallingHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<HostCallHistory>.from(json["data"]!.map((x) => HostCallHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HostCallHistory {
  String? id;
  String? userId;

  String? duration;
  String? date;
  DateTime? createdAt;
  String? callStatusText; // Changed
  String? fullName; // Changed
  String? profilePic;
  num? coin;
  bool? isFake;
  List<String>? video;
  String? audio;
  bool? isOnline;

  HostCallHistory({
    this.id,
    this.userId,
    this.duration,
    this.date,
    this.createdAt,
    this.callStatusText,
    this.fullName,
    this.profilePic,
    this.coin,
    this.video,
    this.isFake,
    this.audio,
    this.isOnline,
  });

  factory HostCallHistory.fromJson(Map<String, dynamic> json) => HostCallHistory(
        id: json["_id"],
        userId: json["userId"],

        duration: json["duration"],
        date: json["date"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        callStatusText: json["callStatusText"], // No enum lookup
        fullName: json["fullName"], // No enum lookup
        profilePic: json["profilePic"],
        coin: json["coin"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],
        audio: json["audio"],
        isOnline: json["isOnline"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "duration": duration,
        "date": date,
        "createdAt": createdAt?.toIso8601String(),
        "callStatusText": callStatusText,
        "fullName": fullName,
        "profilePic": profilePic,
        "coin": coin,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
        "audio": audio,
        "isOnline": isOnline,
      };
}

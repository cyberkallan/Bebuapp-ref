// To parse this JSON data, do
//
//     final hostCoinHistoryModel = hostCoinHistoryModelFromJson(jsonString);

import 'dart:convert';

HostCoinHistoryModel hostCoinHistoryModelFromJson(String str) => HostCoinHistoryModel.fromJson(json.decode(str));

String hostCoinHistoryModelToJson(HostCoinHistoryModel data) => json.encode(data.toJson());

class HostCoinHistoryModel {
  bool? status;
  String? message;
  List<HostCoinHistory>? data;

  HostCoinHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory HostCoinHistoryModel.fromJson(Map<String, dynamic> json) => HostCoinHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<HostCoinHistory>.from(json["data"]!.map((x) => HostCoinHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HostCoinHistory {
  String? id;
  String? duration;
  int? listenerCoin;
  int? payoutStatus;
  String? date;
  int? type;
  DateTime? createdAt;
  String? fullName;
  String? profilePic;

  HostCoinHistory({
    this.id,
    this.duration,
    this.listenerCoin,
    this.payoutStatus,
    this.date,
    this.type,
    this.createdAt,
    this.fullName,
    this.profilePic,
  });

  factory HostCoinHistory.fromJson(Map<String, dynamic> json) => HostCoinHistory(
        id: json["_id"],
        duration: json["duration"],
        listenerCoin: json["listenerCoin"],
        payoutStatus: json["payoutStatus"],
        date: json["date"],
        type: json["type"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        fullName: json["fullName"],
        profilePic: json["profilePic"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "duration": duration,
        "listenerCoin": listenerCoin,
        "payoutStatus": payoutStatus,
        "date": date,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "fullName": fullName,
        "profilePic": profilePic,
      };
}

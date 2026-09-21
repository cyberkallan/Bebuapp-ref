// To parse this JSON data, do
//
//     final coinHistoryModel = coinHistoryModelFromJson(jsonString);

import 'dart:convert';

CoinHistoryModel coinHistoryModelFromJson(String str) => CoinHistoryModel.fromJson(json.decode(str));

String coinHistoryModelToJson(CoinHistoryModel data) => json.encode(data.toJson());

class CoinHistoryModel {
  bool? status;
  String? message;
  List<CoinHistory>? data;

  CoinHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory CoinHistoryModel.fromJson(Map<String, dynamic> json) => CoinHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<CoinHistory>.from(json["data"]!.map((x) => CoinHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CoinHistory {
  String? id;
  String? duration;
  int? userCoin;
  String? date;
  int? type;
  DateTime? createdAt;
  String? receiverName;
  String? receiverImage;

  bool? isIncome;

  CoinHistory({
    this.id,
    this.duration,
    this.userCoin,
    this.date,
    this.type,
    this.createdAt,
    this.receiverName,
    this.receiverImage,
    this.isIncome,
  });

  factory CoinHistory.fromJson(Map<String, dynamic> json) => CoinHistory(
        id: json["_id"],
        duration: json["duration"],
        userCoin: json["userCoin"],
        date: json["date"],
        type: json["type"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        receiverName: json["receiverName"],
        receiverImage: json["receiverImage"],
        isIncome: json["isIncome"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "duration": duration,
        "userCoin": userCoin,
        "date": date,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "receiverName": receiverName,
        "receiverImage": receiverImage,
        "isIncome": isIncome,
      };
}

// To parse this JSON data, do
//
//     final getPurchaseCoinPlanModel = getPurchaseCoinPlanModelFromJson(jsonString);

import 'dart:convert';

GetPurchaseCoinPlanModel getPurchaseCoinPlanModelFromJson(String str) => GetPurchaseCoinPlanModel.fromJson(json.decode(str));

String getPurchaseCoinPlanModelToJson(GetPurchaseCoinPlanModel data) => json.encode(data.toJson());

class GetPurchaseCoinPlanModel {
  bool? status;
  String? message;
  List<Datum>? data;

  GetPurchaseCoinPlanModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetPurchaseCoinPlanModel.fromJson(Map<String, dynamic> json) => GetPurchaseCoinPlanModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  String? uniqueId;
  int? userCoin;
  double? price;
  String? paymentGateway;
  String? date;
  DateTime? createdAt;

  Datum({
    this.id,
    this.uniqueId,
    this.userCoin,
    this.price,
    this.paymentGateway,
    this.date,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        uniqueId: json["uniqueId"],
        userCoin: json["userCoin"],
        price: json["price"]?.toDouble(),
        paymentGateway: json["paymentGateway"],
        date: json["date"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "uniqueId": uniqueId,
        "userCoin": userCoin,
        "price": price,
        "paymentGateway": paymentGateway,
        "date": date,
        "createdAt": createdAt?.toIso8601String(),
      };
}

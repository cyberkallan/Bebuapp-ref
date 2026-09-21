// To parse this JSON data, do
//
//     final fetchCoinPlan = fetchCoinPlanFromJson(jsonString);

import 'dart:convert';

FetchCoinPlan fetchCoinPlanFromJson(String str) => FetchCoinPlan.fromJson(json.decode(str));

String fetchCoinPlanToJson(FetchCoinPlan data) => json.encode(data.toJson());

class FetchCoinPlan {
  bool? status;
  String? message;
  int? userCoin;
  List<CoinPlan>? data;

  FetchCoinPlan({
    this.status,
    this.message,
    this.userCoin,
    this.data,
  });

  factory FetchCoinPlan.fromJson(Map<String, dynamic> json) => FetchCoinPlan(
        status: json["status"],
        message: json["message"],
        userCoin: json["userCoin"],
        data: json["data"] == null ? [] : List<CoinPlan>.from(json["data"]!.map((x) => CoinPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "userCoin": userCoin,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CoinPlan {
  String? id;
  int? coins;
  double? price;
  String? productId;
  bool? isPopular;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  CoinPlan({
    this.id,
    this.coins,
    this.price,
    this.productId,
    this.isPopular,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CoinPlan.fromJson(Map<String, dynamic> json) => CoinPlan(
        id: json["_id"],
        coins: json["coins"],
        price: json["price"]?.toDouble(),
        productId: json["productId"],
        isPopular: json["isPopular"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "coins": coins,
        "price": price,
        "productId": productId,
        "isPopular": isPopular,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

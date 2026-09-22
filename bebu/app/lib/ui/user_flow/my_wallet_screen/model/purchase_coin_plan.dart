// To parse this JSON data, do
//
//     final purchaseCoinPlan = purchaseCoinPlanFromJson(jsonString);

import 'dart:convert';

PurchaseCoinPlan purchaseCoinPlanFromJson(String str) => PurchaseCoinPlan.fromJson(json.decode(str));

String purchaseCoinPlanToJson(PurchaseCoinPlan data) => json.encode(data.toJson());

class PurchaseCoinPlan {
  bool? status;
  String? message;
  int? totalCoins;
  HistoryRecord? historyRecord;

  PurchaseCoinPlan({
    this.status,
    this.message,
    this.totalCoins,
    this.historyRecord,
  });

  factory PurchaseCoinPlan.fromJson(Map<String, dynamic> json) => PurchaseCoinPlan(
        status: json["status"],
        message: json["message"],
        totalCoins: json["totalCoins"],
        historyRecord: json["historyRecord"] == null ? null : HistoryRecord.fromJson(json["historyRecord"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "totalCoins": totalCoins,
        "historyRecord": historyRecord?.toJson(),
      };
}

class HistoryRecord {
  String? transactionId;
  String? date;
  double? amountPaid;
  String? paymentMode;
  int? userCoin;

  HistoryRecord({
    this.transactionId,
    this.date,
    this.amountPaid,
    this.paymentMode,
    this.userCoin,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
        transactionId: json["transactionId"],
        date: json["date"],
        amountPaid: json["amountPaid"]?.toDouble(),
        paymentMode: json["paymentMode"],
        userCoin: json["userCoin"],
      );

  Map<String, dynamic> toJson() => {
        "transactionId": transactionId,
        "date": date,
        "amountPaid": amountPaid,
        "paymentMode": paymentMode,
        "userCoin": userCoin,
      };
}

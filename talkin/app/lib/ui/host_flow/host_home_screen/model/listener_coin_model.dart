// To parse this JSON data, do
//
//     final listenerCoinModel = listenerCoinModelFromJson(jsonString);

import 'dart:convert';

ListenerCoinModel listenerCoinModelFromJson(String str) => ListenerCoinModel.fromJson(json.decode(str));

String listenerCoinModelToJson(ListenerCoinModel data) => json.encode(data.toJson());

class ListenerCoinModel {
  bool? status;
  String? message;
  int? coin;

  ListenerCoinModel({
    this.status,
    this.message,
    this.coin,
  });

  factory ListenerCoinModel.fromJson(Map<String, dynamic> json) => ListenerCoinModel(
        status: json["status"],
        message: json["message"],
        coin: json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "coin": coin,
      };
}

// To parse this JSON data, do
//
//     final withdrawCoinSubmitModel = withdrawCoinSubmitModelFromJson(jsonString);

import 'dart:convert';

WithdrawCoinSubmitModel withdrawCoinSubmitModelFromJson(String str) => WithdrawCoinSubmitModel.fromJson(json.decode(str));

String withdrawCoinSubmitModelToJson(WithdrawCoinSubmitModel data) => json.encode(data.toJson());

class WithdrawCoinSubmitModel {
  bool? status;
  String? message;

  WithdrawCoinSubmitModel({
    this.status,
    this.message,
  });

  factory WithdrawCoinSubmitModel.fromJson(Map<String, dynamic> json) => WithdrawCoinSubmitModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

// To parse this JSON data, do
//
//     final becomeHostModel = becomeHostModelFromJson(jsonString);

import 'dart:convert';

BecomeHostModel becomeHostModelFromJson(String str) => BecomeHostModel.fromJson(json.decode(str));

String becomeHostModelToJson(BecomeHostModel data) => json.encode(data.toJson());

class BecomeHostModel {
  final bool? status;
  final String? message;

  BecomeHostModel({
    this.status,
    this.message,
  });

  factory BecomeHostModel.fromJson(Map<String, dynamic> json) => BecomeHostModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

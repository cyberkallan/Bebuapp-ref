// To parse this JSON data, do
//
//     final passwordResponseModel = passwordResponseModelFromJson(jsonString);

import 'dart:convert';

ForgotPasswordResponseModel forgotPasswordResponseModelFromJson(String str) => ForgotPasswordResponseModel.fromJson(json.decode(str));

String forgotPasswordResponseModelToJson(ForgotPasswordResponseModel data) => json.encode(data.toJson());

class ForgotPasswordResponseModel {
  final bool? status;
  final String? message;

  ForgotPasswordResponseModel({
    this.status,
    this.message,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) => ForgotPasswordResponseModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

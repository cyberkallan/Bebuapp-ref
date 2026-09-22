// To parse this JSON data, do
//
//     final checkUserExistModel = checkUserExistModelFromJson(jsonString);

import 'dart:convert';

CheckUserExistModel checkUserExistModelFromJson(String str) => CheckUserExistModel.fromJson(json.decode(str));

String checkUserExistModelToJson(CheckUserExistModel data) => json.encode(data.toJson());

class CheckUserExistModel {
  final bool? status;
  final String? message;
  final bool? isLogin;

  CheckUserExistModel({
    this.status,
    this.message,
    this.isLogin,
  });

  factory CheckUserExistModel.fromJson(Map<String, dynamic> json) => CheckUserExistModel(
        status: json["status"],
        message: json["message"],
        isLogin: json["isLogin"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "isLogin": isLogin,
      };
}

// To parse this JSON data, do
//
//     final deleteUserResponseModel = deleteUserResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteUserResponseModel deleteUserResponseModelFromJson(String str) => DeleteUserResponseModel.fromJson(json.decode(str));

String deleteUserResponseModelToJson(DeleteUserResponseModel data) => json.encode(data.toJson());

class DeleteUserResponseModel {
  bool? status;
  String? message;

  DeleteUserResponseModel({
    this.status,
    this.message,
  });

  factory DeleteUserResponseModel.fromJson(Map<String, dynamic> json) => DeleteUserResponseModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

// To parse this JSON data, do
//
//     final deleteListenerResponseModel = deleteListenerResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteListenerResponseModel deleteListenerResponseModelFromJson(String str) => DeleteListenerResponseModel.fromJson(json.decode(str));

String deleteListenerResponseModelToJson(DeleteListenerResponseModel data) => json.encode(data.toJson());

class DeleteListenerResponseModel {
  bool? status;
  String? message;

  DeleteListenerResponseModel({
    this.status,
    this.message,
  });

  factory DeleteListenerResponseModel.fromJson(Map<String, dynamic> json) => DeleteListenerResponseModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

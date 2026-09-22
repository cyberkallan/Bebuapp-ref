// To parse this JSON data, do
//
//     final updateRandomCallStatusModel = updateRandomCallStatusModelFromJson(jsonString);

import 'dart:convert';

UpdateRandomCallStatusModel updateRandomCallStatusModelFromJson(String str) => UpdateRandomCallStatusModel.fromJson(json.decode(str));

String updateRandomCallStatusModelToJson(UpdateRandomCallStatusModel data) => json.encode(data.toJson());

class UpdateRandomCallStatusModel {
  bool? status;
  String? message;

  UpdateRandomCallStatusModel({
    this.status,
    this.message,
  });

  factory UpdateRandomCallStatusModel.fromJson(Map<String, dynamic> json) => UpdateRandomCallStatusModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

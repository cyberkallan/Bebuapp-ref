// To parse this JSON data, do
//
//     final submitCallRateModel = submitCallRateModelFromJson(jsonString);

import 'dart:convert';

SubmitCallRateModel submitCallRateModelFromJson(String str) => SubmitCallRateModel.fromJson(json.decode(str));

String submitCallRateModelToJson(SubmitCallRateModel data) => json.encode(data.toJson());

class SubmitCallRateModel {
  bool? status;
  String? message;

  SubmitCallRateModel({
    this.status,
    this.message,
  });

  factory SubmitCallRateModel.fromJson(Map<String, dynamic> json) => SubmitCallRateModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

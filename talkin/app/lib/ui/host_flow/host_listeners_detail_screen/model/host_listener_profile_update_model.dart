// To parse this JSON data, do
//
//     final hostListenerProfileUpdateModel = hostListenerProfileUpdateModelFromJson(jsonString);

import 'dart:convert';

HostListenerProfileUpdateModel hostListenerProfileUpdateModelFromJson(String str) => HostListenerProfileUpdateModel.fromJson(json.decode(str));

String hostListenerProfileUpdateModelToJson(HostListenerProfileUpdateModel data) => json.encode(data.toJson());

class HostListenerProfileUpdateModel {
  bool? status;
  String? message;

  HostListenerProfileUpdateModel({
    this.status,
    this.message,
  });

  factory HostListenerProfileUpdateModel.fromJson(Map<String, dynamic> json) => HostListenerProfileUpdateModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

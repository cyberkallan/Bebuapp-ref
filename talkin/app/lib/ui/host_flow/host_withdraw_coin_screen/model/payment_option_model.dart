// To parse this JSON data, do
//
//     final paymentOptionModel = paymentOptionModelFromJson(jsonString);

import 'dart:convert';

PaymentOptionModel paymentOptionModelFromJson(String str) => PaymentOptionModel.fromJson(json.decode(str));

String paymentOptionModelToJson(PaymentOptionModel data) => json.encode(data.toJson());

class PaymentOptionModel {
  bool? status;
  String? message;
  List<PaymentOption>? data;

  PaymentOptionModel({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentOptionModel.fromJson(Map<String, dynamic> json) => PaymentOptionModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<PaymentOption>.from(json["data"]!.map((x) => PaymentOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class PaymentOption {
  String? id;
  String? name;
  String? image;
  List<String>? details;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentOption({
    this.id,
    this.name,
    this.image,
    this.details,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentOption.fromJson(Map<String, dynamic> json) => PaymentOption(
        id: json["_id"],
        name: json["name"],
        image: json["image"],
        details: json["details"] == null ? [] : List<String>.from(json["details"]!.map((x) => x)),
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x)),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

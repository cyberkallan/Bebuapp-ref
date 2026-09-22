// To parse this JSON data, do
//
//     final identityProofModel = identityProofModelFromJson(jsonString);

import 'dart:convert';

IdentityProofModel identityProofModelFromJson(String str) => IdentityProofModel.fromJson(json.decode(str));

String identityProofModelToJson(IdentityProofModel data) => json.encode(data.toJson());

class IdentityProofModel {
  final bool? status;
  final String? message;
  final List<IdentityProof>? data;

  IdentityProofModel({
    this.status,
    this.message,
    this.data,
  });

  factory IdentityProofModel.fromJson(Map<String, dynamic> json) => IdentityProofModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<IdentityProof>.from(json["data"]!.map((x) => IdentityProof.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class IdentityProof {
  final String? id;
  final String? title;
  final DateTime? createdAt;

  IdentityProof({
    this.id,
    this.title,
    this.createdAt,
  });

  factory IdentityProof.fromJson(Map<String, dynamic> json) => IdentityProof(
        id: json["_id"],
        title: json["title"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "createdAt": createdAt?.toIso8601String(),
      };
}

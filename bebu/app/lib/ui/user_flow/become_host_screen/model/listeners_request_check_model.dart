// To parse this JSON data, do
//
//     final listenersRequestCheckModel = listenersRequestCheckModelFromJson(jsonString);

import 'dart:convert';

ListenersRequestCheckModel listenersRequestCheckModelFromJson(String str) => ListenersRequestCheckModel.fromJson(json.decode(str));

String listenersRequestCheckModelToJson(ListenersRequestCheckModel data) => json.encode(data.toJson());

class ListenersRequestCheckModel {
  final bool? status;
  final String? message;
  final Data? data;

  ListenersRequestCheckModel({
    this.status,
    this.message,
    this.data,
  });

  factory ListenersRequestCheckModel.fromJson(Map<String, dynamic> json) => ListenersRequestCheckModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final String? id;
  final String? name;
  final String? email;
  final String? selfIntro;
  final String? image;
  final String? uniqueId;
  final int? status;
  final String? date;
  final String? location;

  Data({
    this.id,
    this.name,
    this.email,
    this.selfIntro,
    this.image,
    this.uniqueId,
    this.status,
    this.date,
    this.location,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        selfIntro: json["selfIntro"],
        image: json["image"],
        uniqueId: json["uniqueId"],
        status: json["status"],
        date: json["date"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "selfIntro": selfIntro,
        "image": image,
        "uniqueId": uniqueId,
        "status": status,
        "date": date,
        "location": location,
      };
}

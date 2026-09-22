// To parse this JSON data, do
//
//     final listenerReviewModel = listenerReviewModelFromJson(jsonString);

import 'dart:convert';

ListenerReviewModel listenerReviewModelFromJson(String str) => ListenerReviewModel.fromJson(json.decode(str));

String listenerReviewModelToJson(ListenerReviewModel data) => json.encode(data.toJson());

class ListenerReviewModel {
  bool? status;
  String? message;
  List<Review>? reviews;

  ListenerReviewModel({
    this.status,
    this.message,
    this.reviews,
  });

  factory ListenerReviewModel.fromJson(Map<String, dynamic> json) => ListenerReviewModel(
        status: json["status"],
        message: json["message"],
        reviews: json["reviews"] == null ? [] : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
      };
}

class Review {
  String? id;
  String? review;
  int? rating;
  String? nickName;
  String? fullName;
  String? profilePic;
  String? time;

  Review({
    this.id,
    this.review,
    this.rating,
    this.nickName,
    this.fullName,
    this.profilePic,
    this.time,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["_id"],
        review: json["review"],
        rating: json["rating"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        profilePic: json["profilePic"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "review": review,
        "rating": rating,
        "nickName": nickName,
        "fullName": fullName,
        "profilePic": profilePic,
        "time": time,
      };
}

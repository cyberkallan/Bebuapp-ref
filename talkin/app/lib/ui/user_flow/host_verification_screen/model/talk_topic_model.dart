// To parse this JSON data, do
//
//     final talkTopicsModel = talkTopicsModelFromJson(jsonString);

import 'dart:convert';

TalkTopicsModel talkTopicsModelFromJson(String str) => TalkTopicsModel.fromJson(json.decode(str));

String talkTopicsModelToJson(TalkTopicsModel data) => json.encode(data.toJson());

class TalkTopicsModel {
  final bool? status;
  final String? message;
  final List<TalkTopic>? talkTopics;

  TalkTopicsModel({
    this.status,
    this.message,
    this.talkTopics,
  });

  factory TalkTopicsModel.fromJson(Map<String, dynamic> json) => TalkTopicsModel(
        status: json["status"],
        message: json["message"],
        talkTopics: json["talkTopics"] == null ? [] : List<TalkTopic>.from(json["talkTopics"]!.map((x) => TalkTopic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!.map((x) => x.toJson())),
      };
}

class TalkTopic {
  final String? id;
  final String? name;

  TalkTopic({
    this.id,
    this.name,
  });

  factory TalkTopic.fromJson(Map<String, dynamic> json) => TalkTopic(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

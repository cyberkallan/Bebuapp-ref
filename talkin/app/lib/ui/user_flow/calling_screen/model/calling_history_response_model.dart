import 'dart:convert';

CallingHistoryModel hostCallingHistoryModelFromJson(String str) => CallingHistoryModel.fromJson(json.decode(str));

String hostCallingHistoryModelToJson(CallingHistoryModel data) => json.encode(data.toJson());

class CallingHistoryModel {
  bool? status;
  String? message;
  List<CallHistory>? data;

  CallingHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory CallingHistoryModel.fromJson(Map<String, dynamic> json) => CallingHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<CallHistory>.from(json["data"]!.map((x) => CallHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CallHistory {
  String? id;
  String? listenerId;
  String? duration;
  String? date;
  DateTime? createdAt;
  String? callStatusText; // Changed
  String? name; // Changed
  String? image;
  num? coin;
  bool? isFake;
  List<String>? video;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForRandomAudioCall;
  bool? isAvailableForRandomVideoCall;
  bool? isAvailableForChat;
  String? audio;
  bool? isOnline;

  CallHistory({
    this.id,
    this.listenerId,
    this.duration,
    this.date,
    this.createdAt,
    this.callStatusText,
    this.name,
    this.image,
    this.coin,
    this.video,
    this.isFake,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForRandomAudioCall,
    this.isAvailableForRandomVideoCall,
    this.isAvailableForChat,
    this.audio,
    this.isOnline,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) => CallHistory(
        id: json["_id"],
        listenerId: json["listenerId"],
        duration: json["duration"],
        date: json["date"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        callStatusText: json["callStatusText"], // No enum lookup
        name: json["name"], // No enum lookup
        image: json["image"],
        coin: json["coin"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],

        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForRandomAudioCall: json["isAvailableForRandomAudioCall"],
        isAvailableForRandomVideoCall: json["isAvailableForRandomVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
        audio: json["audio"],
        isOnline: json["isOnline"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "listenerId": listenerId,
        "duration": duration,
        "date": date,
        "createdAt": createdAt?.toIso8601String(),
        "callStatusText": callStatusText,
        "name": name,
        "image": image,
        "coin": coin,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForRandomAudioCall": isAvailableForRandomAudioCall,
        "isAvailableForRandomVideoCall": isAvailableForRandomVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "audio": audio,
        "isOnline": isOnline,
      };
}

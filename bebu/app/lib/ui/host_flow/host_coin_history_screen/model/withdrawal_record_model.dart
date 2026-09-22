// // To parse this JSON data, do
// //
// //     final withdrawalRecordModel = withdrawalRecordModelFromJson(jsonString);
//
// import 'dart:convert';
//
// WithdrawalRecordModel withdrawalRecordModelFromJson(String str) => WithdrawalRecordModel.fromJson(json.decode(str));
//
// String withdrawalRecordModelToJson(WithdrawalRecordModel data) => json.encode(data.toJson());
//
// class WithdrawalRecordModel {
//   bool? status;
//   String? message;
//   List<Datum>? data;
//
//   WithdrawalRecordModel({
//     this.status,
//     this.message,
//     this.data,
//   });
//
//   factory WithdrawalRecordModel.fromJson(Map<String, dynamic> json) => WithdrawalRecordModel(
//         status: json["status"],
//         message: json["message"],
//         data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//       };
// }
//
// class Datum {
//   String? id;
//   String? listenerId;
//   String? uniqueId;
//   int? status;
//   int? coin;
//   int? amount;
//   String? paymentGateway;
//   PaymentDetails? paymentDetails;
//   String? reason;
//   String? requestDate;
//   String? acceptOrDeclineDate;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//
//   Datum({
//     this.id,
//     this.listenerId,
//     this.uniqueId,
//     this.status,
//     this.coin,
//     this.amount,
//     this.paymentGateway,
//     this.paymentDetails,
//     this.reason,
//     this.requestDate,
//     this.acceptOrDeclineDate,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         id: json["_id"],
//         listenerId: json["listenerId"],
//         uniqueId: json["uniqueId"],
//         status: json["status"],
//         coin: json["coin"],
//         amount: json["amount"],
//         paymentGateway: json["paymentGateway"],
//         paymentDetails: json["paymentDetails"] == null ? null : PaymentDetails.fromJson(json["paymentDetails"]),
//         reason: json["reason"],
//         requestDate: json["requestDate"],
//         acceptOrDeclineDate: json["acceptOrDeclineDate"],
//         createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//         updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "listenerId": listenerId,
//         "uniqueId": uniqueId,
//         "status": status,
//         "coin": coin,
//         "amount": amount,
//         "paymentGateway": paymentGateway,
//         "paymentDetails": paymentDetails?.toJson(),
//         "reason": reason,
//         "requestDate": requestDate,
//         "acceptOrDeclineDate": acceptOrDeclineDate,
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//       };
// }
//
// class PaymentDetails {
//   String? transactionId;
//   String? paymentMethod;
//
//   PaymentDetails({
//     this.transactionId,
//     this.paymentMethod,
//   });
//
//   factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
//         transactionId: json["transactionId"],
//         paymentMethod: json["paymentMethod"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "transactionId": transactionId,
//         "paymentMethod": paymentMethod,
//       };
// }

import 'dart:convert';

WithdrawalRecordModel withdrawalRecordModelFromJson(String str) => WithdrawalRecordModel.fromJson(json.decode(str));

String withdrawalRecordModelToJson(WithdrawalRecordModel data) => json.encode(data.toJson());

class WithdrawalRecordModel {
  bool? status;
  String? message;
  List<Datum>? data;

  WithdrawalRecordModel({
    this.status,
    this.message,
    this.data,
  });

  factory WithdrawalRecordModel.fromJson(Map<String, dynamic> json) => WithdrawalRecordModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  String? listenerId;
  String? uniqueId;
  int? status;
  int? coin;
  num? amount;
  String? paymentGateway;
  PaymentDetails? paymentDetails;
  String? reason;
  String? requestDate;
  String? acceptOrDeclineDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.listenerId,
    this.uniqueId,
    this.status,
    this.coin,
    this.amount,
    this.paymentGateway,
    this.paymentDetails,
    this.reason,
    this.requestDate,
    this.acceptOrDeclineDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        listenerId: json["listenerId"],
        uniqueId: json["uniqueId"],
        status: json["status"],
        coin: json["coin"],
        amount: json["amount"],
        paymentGateway: json["paymentGateway"],
        paymentDetails: json["paymentDetails"] == null ? null : PaymentDetails.fromJson(json["paymentDetails"]),
        reason: json["reason"],
        requestDate: json["requestDate"],
        acceptOrDeclineDate: json["acceptOrDeclineDate"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "listenerId": listenerId,
        "uniqueId": uniqueId,
        "status": status,
        "coin": coin,
        "amount": amount,
        "paymentGateway": paymentGateway,
        "paymentDetails": paymentDetails?.toJson(),
        "reason": reason,
        "requestDate": requestDate,
        "acceptOrDeclineDate": acceptOrDeclineDate,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class PaymentDetails {
  Map<String, dynamic>? details;

  PaymentDetails({this.details});

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(details: json);

  Map<String, dynamic> toJson() => details ?? {};
}

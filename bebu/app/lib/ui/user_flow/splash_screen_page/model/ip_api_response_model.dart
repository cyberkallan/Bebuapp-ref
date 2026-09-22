// To parse this JSON data, do
//
//     final ipApiResponseModel = ipApiResponseModelFromJson(jsonString);

import 'dart:convert';

IpApiResponseModel ipApiResponseModelFromJson(String str) => IpApiResponseModel.fromJson(json.decode(str));

String ipApiResponseModelToJson(IpApiResponseModel data) => json.encode(data.toJson());

class IpApiResponseModel {
  final String? status;
  final String? country;
  final String? countryCode;
  final String? region;
  final String? regionName;
  final String? city;
  final String? zip;
  final double? lat;
  final double? lon;
  final String? timezone;
  final String? isp;
  final String? org;
  final String? ipApiResponseModelAs;
  final String? query;

  IpApiResponseModel({
    this.status,
    this.country,
    this.countryCode,
    this.region,
    this.regionName,
    this.city,
    this.zip,
    this.lat,
    this.lon,
    this.timezone,
    this.isp,
    this.org,
    this.ipApiResponseModelAs,
    this.query,
  });

  factory IpApiResponseModel.fromJson(Map<String, dynamic> json) => IpApiResponseModel(
        status: json["status"],
        country: json["country"],
        countryCode: json["countryCode"],
        region: json["region"],
        regionName: json["regionName"],
        city: json["city"],
        zip: json["zip"],
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
        timezone: json["timezone"],
        isp: json["isp"],
        org: json["org"],
        ipApiResponseModelAs: json["as"],
        query: json["query"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "country": country,
        "countryCode": countryCode,
        "region": region,
        "regionName": regionName,
        "city": city,
        "zip": zip,
        "lat": lat,
        "lon": lon,
        "timezone": timezone,
        "isp": isp,
        "org": org,
        "as": ipApiResponseModelAs,
        "query": query,
      };
}

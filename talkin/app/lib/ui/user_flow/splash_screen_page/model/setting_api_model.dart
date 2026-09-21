// To parse this JSON data, do
//
//     final settingApiModel = settingApiModelFromJson(jsonString);

import 'dart:convert';

SettingApiModel settingApiModelFromJson(String str) => SettingApiModel.fromJson(json.decode(str));

String settingApiModelToJson(SettingApiModel data) => json.encode(data.toJson());

class SettingApiModel {
  final bool? status;
  final String? message;
  final Data? data;

  SettingApiModel({
    this.status,
    this.message,
    this.data,
  });

  factory SettingApiModel.fromJson(Map<String, dynamic> json) => SettingApiModel(
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
  final Currency? currency;
  final String? id;
  final String? privacyPolicyUrl;
  final String? termsOfUseUrl;
  final bool? isGooglePlayEnabled;
  final bool? isStripeEnabled;
  final String? stripePublicKey;
  final String? stripeSecretKey;
  final bool? isRazorpayEnabled;
  final String? razorpayKeyId;
  final String? razorpayKeySecret;
  final bool? isFlutterwaveEnabled;
  final String? flutterwavePublicKey;
  final String? agoraAppId;
  final String? agoraAppCertificate;
  final int? dailyLoginBonusCoins;
  final bool? isDemoContentEnabled;
  final bool? isApplicationLive;
  final bool? allowBecomeHostOption;
  final Map<String, dynamic>? appearance;
  final int? adminCommissionPercent;
  final int? minimumCoinsForConversion;
  final int? minimumCoinsForPayout;
  final int? videoCallRatePrivate;
  final int? audioCallRatePrivate;
  final int? videoCallRateRandom;
  final int? audioCallRateRandom;
  final PrivateKey? privateKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? zegoAppId;
  final String? zegoAppSignIn;
  final String? aboutUsUrl;
  final String? listenerPrivacyPolicyUrl;
  final String? userPrivacyPolicyUrl;
  final String? helpdeskEmail;

  Data({
    this.currency,
    this.id,
    this.privacyPolicyUrl,
    this.termsOfUseUrl,
    this.isGooglePlayEnabled,
    this.isStripeEnabled,
    this.stripePublicKey,
    this.stripeSecretKey,
    this.isRazorpayEnabled,
    this.razorpayKeyId,
    this.razorpayKeySecret,
    this.isFlutterwaveEnabled,
    this.flutterwavePublicKey,
    this.agoraAppId,
    this.agoraAppCertificate,
    this.dailyLoginBonusCoins,
    this.isDemoContentEnabled,
    this.isApplicationLive,
    this.allowBecomeHostOption,
    this.appearance,
    this.adminCommissionPercent,
    this.minimumCoinsForConversion,
    this.minimumCoinsForPayout,
    this.videoCallRatePrivate,
    this.audioCallRatePrivate,
    this.videoCallRateRandom,
    this.audioCallRateRandom,
    this.privateKey,
    this.createdAt,
    this.updatedAt,
    this.zegoAppId,
    this.zegoAppSignIn,
    this.aboutUsUrl,
    this.listenerPrivacyPolicyUrl,
    this.userPrivacyPolicyUrl,
    this.helpdeskEmail,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
        id: json["_id"],
        privacyPolicyUrl: json["privacyPolicyUrl"],
        termsOfUseUrl: json["termsOfUseUrl"],
        isGooglePlayEnabled: json["isGooglePlayEnabled"],
        isStripeEnabled: json["isStripeEnabled"],
        stripePublicKey: json["stripePublicKey"],
        stripeSecretKey: json["stripeSecretKey"],
        isRazorpayEnabled: json["isRazorpayEnabled"],
        razorpayKeyId: json["razorpayKeyId"],
        razorpayKeySecret: json["razorpayKeySecret"],
        isFlutterwaveEnabled: json["isFlutterwaveEnabled"],
        flutterwavePublicKey: json["flutterwavePublicKey"],
        agoraAppId: json["agoraAppId"],
        agoraAppCertificate: json["agoraAppCertificate"],
        dailyLoginBonusCoins: json["dailyLoginBonusCoins"],
        isDemoContentEnabled: json["isDemoContentEnabled"],
        isApplicationLive: json["isApplicationLive"],
        allowBecomeHostOption: json["allowBecomeHostOption"],
        appearance: json["appearance"] is Map ? Map<String, dynamic>.from(json["appearance"]) : null,
        adminCommissionPercent: json["adminCommissionPercent"],
        minimumCoinsForConversion: json["minimumCoinsForConversion"],
        minimumCoinsForPayout: json["minimumCoinsForPayout"],
        videoCallRatePrivate: json["videoCallRatePrivate"],
        audioCallRatePrivate: json["audioCallRatePrivate"],
        videoCallRateRandom: json["videoCallRateRandom"],
        audioCallRateRandom: json["audioCallRateRandom"],
        privateKey: json["privateKey"] == null ? null : PrivateKey.fromJson(json["privateKey"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        zegoAppId: json["zegoAppId"],
        zegoAppSignIn: json["zegoAppSignIn"],
        aboutUsUrl: json["aboutUsUrl"],
        listenerPrivacyPolicyUrl: json["listenerPrivacyPolicyUrl"],
        userPrivacyPolicyUrl: json["userPrivacyPolicyUrl"],
        helpdeskEmail: json["helpdeskEmail"],
      );

  Map<String, dynamic> toJson() => {
        "currency": currency?.toJson(),
        "_id": id,
        "privacyPolicyUrl": privacyPolicyUrl,
        "termsOfUseUrl": termsOfUseUrl,
        "isGooglePlayEnabled": isGooglePlayEnabled,
        "isStripeEnabled": isStripeEnabled,
        "stripePublicKey": stripePublicKey,
        "stripeSecretKey": stripeSecretKey,
        "isRazorpayEnabled": isRazorpayEnabled,
        "razorpayKeyId": razorpayKeyId,
        "razorpayKeySecret": razorpayKeySecret,
        "isFlutterwaveEnabled": isFlutterwaveEnabled,
        "flutterwavePublicKey": flutterwavePublicKey,
        "agoraAppId": agoraAppId,
        "agoraAppCertificate": agoraAppCertificate,
        "dailyLoginBonusCoins": dailyLoginBonusCoins,
        "isDemoContentEnabled": isDemoContentEnabled,
        "isApplicationLive": isApplicationLive,
        "allowBecomeHostOption": allowBecomeHostOption,
        "appearance": appearance,
        "adminCommissionPercent": adminCommissionPercent,
        "minimumCoinsForConversion": minimumCoinsForConversion,
        "minimumCoinsForPayout": minimumCoinsForPayout,
        "videoCallRatePrivate": videoCallRatePrivate,
        "audioCallRatePrivate": audioCallRatePrivate,
        "videoCallRateRandom": videoCallRateRandom,
        "audioCallRateRandom": audioCallRateRandom,
        "privateKey": privateKey?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "zegoAppId": zegoAppId,
        "zegoAppSignIn": zegoAppSignIn,
        "aboutUsUrl": aboutUsUrl,
        "listenerPrivacyPolicyUrl": listenerPrivacyPolicyUrl,
        "userPrivacyPolicyUrl": userPrivacyPolicyUrl,
        "helpdeskEmail": helpdeskEmail,
      };
}

class Currency {
  final String? name;
  final String? symbol;
  final String? countryCode;
  final String? currencyCode;
  final bool? isDefault;

  Currency({
    this.name,
    this.symbol,
    this.countryCode,
    this.currencyCode,
    this.isDefault,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        name: json["name"],
        symbol: json["symbol"],
        countryCode: json["countryCode"],
        currencyCode: json["currencyCode"],
        isDefault: json["isDefault"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "symbol": symbol,
        "countryCode": countryCode,
        "currencyCode": currencyCode,
        "isDefault": isDefault,
      };
}

class PrivateKey {
  final String? type;
  final String? projectId;
  final String? privateKeyId;
  final String? privateKey;
  final String? clientEmail;
  final String? clientId;
  final String? authUri;
  final String? tokenUri;
  final String? authProviderX509CertUrl;
  final String? clientX509CertUrl;
  final String? universeDomain;

  PrivateKey({
    this.type,
    this.projectId,
    this.privateKeyId,
    this.privateKey,
    this.clientEmail,
    this.clientId,
    this.authUri,
    this.tokenUri,
    this.authProviderX509CertUrl,
    this.clientX509CertUrl,
    this.universeDomain,
  });

  factory PrivateKey.fromJson(Map<String, dynamic> json) => PrivateKey(
        type: json["type"],
        projectId: json["project_id"],
        privateKeyId: json["private_key_id"],
        privateKey: json["private_key"],
        clientEmail: json["client_email"],
        clientId: json["client_id"],
        authUri: json["auth_uri"],
        tokenUri: json["token_uri"],
        authProviderX509CertUrl: json["auth_provider_x509_cert_url"],
        clientX509CertUrl: json["client_x509_cert_url"],
        universeDomain: json["universe_domain"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "project_id": projectId,
        "private_key_id": privateKeyId,
        "private_key": privateKey,
        "client_email": clientEmail,
        "client_id": clientId,
        "auth_uri": authUri,
        "token_uri": tokenUri,
        "auth_provider_x509_cert_url": authProviderX509CertUrl,
        "client_x509_cert_url": clientX509CertUrl,
        "universe_domain": universeDomain,
      };
}

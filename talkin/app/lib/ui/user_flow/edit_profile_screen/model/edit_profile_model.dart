import 'dart:convert';

EditProfileModel editProfileModelFromJson(String str) => EditProfileModel.fromJson(json.decode(str));

class EditProfileModel {
  final bool? status;
  final String? message;

  /// The saved user (the server now responds after writing).
  final EditedUser? user;

  EditProfileModel({this.status, this.message, this.user});

  factory EditProfileModel.fromJson(Map<String, dynamic> json) => EditProfileModel(
        status: json["status"],
        message: json["message"],
        user: json["user"] is Map ? EditedUser.fromJson(Map<String, dynamic>.from(json["user"])) : null,
      );

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}

class EditedUser {
  final String? profilePic;
  final String? nickName;
  final String? fullName;
  final String? gender;
  final String? birthDate;
  final String? phoneNumber;
  final String? email;

  EditedUser({this.profilePic, this.nickName, this.fullName, this.gender, this.birthDate, this.phoneNumber, this.email});

  factory EditedUser.fromJson(Map<String, dynamic> j) => EditedUser(
        profilePic: j["profilePic"]?.toString(),
        nickName: j["nickName"]?.toString(),
        fullName: j["fullName"]?.toString(),
        gender: j["gender"]?.toString(),
        birthDate: j["birthDate"]?.toString(),
        phoneNumber: j["phoneNumber"]?.toString(),
        email: j["email"]?.toString(),
      );
}

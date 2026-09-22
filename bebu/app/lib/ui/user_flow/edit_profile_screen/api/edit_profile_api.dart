import 'dart:convert';
import 'dart:developer';

import 'package:talk_in/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:talk_in/utils/firebse_access_token.dart';

class EditProfileApi {
  static Future<EditProfileModel?> callApi({
    required String uid,
    String? loginUserId,
    required String nickName,
    required String gender,
    required String phoneNumber,
    required String birthDate,
    required String? country,
    required String? countryFlag,
    String? countryCode,
    String? image,
    String? fullName,
    String? email,
  }) async {
    Utils.showLog("Edit Profile Api Calling...");
    final token = await FirebaseAccessToken.onGet();

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(Api.editProfile),
      );
      Utils.showLog("Edit Profile Api URL => ${request.url}");

      var headers = {
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: 'Bearer $token',
        ApiParams.contentType: 'application/json',
        ApiParams.authUid: uid
      };
      Utils.showLog("Edit Profile Api Headers => $headers");

      request.fields.addAll({
        ApiParams.email: email ?? '',
        ApiParams.fullName: fullName ?? "",
        ApiParams.nickName: nickName,
        ApiParams.birthDate: birthDate,
        ApiParams.gender: gender,
        ApiParams.phoneNumber: phoneNumber,
        ApiParams.profilePic: image ?? '',
        ApiParams.countryCode: countryCode ?? '',
        ApiParams.country: country ?? '',
        ApiParams.countryFlag: countryFlag ?? '',
      });

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('profilePic', image));
      }

      request.headers.addAll(headers);
      log("Edit Profile Api Request => ${request.fields}");

      final response = await request.send();
      log("Edit Profile Api Response => ${response.statusCode}");
      log("Edit Profile Api Status => ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Edit Profile Api Response => $jsonResult");

      return EditProfileModel.fromJson(jsonResult);
    } catch (e) {
      Utils.showLog("Edit Profile Api Error => $e");
      return null;
    }
  }
}

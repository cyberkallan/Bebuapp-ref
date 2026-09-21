import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/utils.dart';

class FetchLoginUserProfileApi {
  static Future<FetchLoginUserProfileModel?> callApi({required String loginUserId, required String token}) async {
    Utils.showLog("Get Login User Profile Api Calling...");

    final uri = Uri.parse(Api.loginUserProfile);

    Utils.showLog("Get Login User Profile uri => $uri");

    final headers = {
      "key": Api.secretKey,
      "Content-Type": "application/json",
      "x-auth-token": "Bearer $token",
      "x-auth-uid": loginUserId,
    };

    log("Get Login User Profile headers  $headers");
    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Get Login User Profile Response.status code => ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Get Login User Profile Response => ${response.body}");
        Utils.showLog("Get Login User Profile Response.status code => ${response.statusCode}");

        return FetchLoginUserProfileModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Login User Profile StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Login User Profile Api Error => $error");
    }
    return null;
  }
}

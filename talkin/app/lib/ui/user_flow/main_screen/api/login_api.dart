import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class LoginApi {
  static Future<LoginModel?> callApi({
    required int loginType,
    String? email,
    required String identity,
    required String fcmToken,
    required String countryCode,
    String? userName,
    String? profilePic,
    String? mobileNumber,
    // String? password,
    String? confirmPassword,
    String? authToken,
    String? authUid,
  }) async {
    Utils.showLog("Login Api Calling...");

    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("Login Api Token :: $token");

    final uri = Uri.parse(Api.login);
    Utils.showLog("Login Api URL :: $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Login Api Headers :: $headers");

    final body = loginType == 4
        ? json.encode(
            Database.userExist == false
                ? {
                    ApiParams.loginType: loginType,
                    ApiParams.email: email,
                    ApiParams.identity: identity,
                    ApiParams.fcmToken: fcmToken,
                    ApiParams.fullName: userName,
                    // ApiParams.password: password,
                    ApiParams.confirmPassword: confirmPassword,
                    ApiParams.countryCode: countryCode,
                  }
                : {
                    ApiParams.loginType: loginType,
                    ApiParams.email: email,
                    ApiParams.identity: identity,
                    ApiParams.fcmToken: fcmToken,
                    // ApiParams.password: password,
                    ApiParams.countryCode: countryCode,
                  },
          )
        : loginType == 3
            ? json.encode(
                {
                  ApiParams.loginType: loginType,
                  ApiParams.phoneNumber: mobileNumber,
                  ApiParams.identity: identity,
                  ApiParams.fcmToken: fcmToken,
                  ApiParams.countryCode: countryCode,
                },
              )
            : json.encode(
                {
                  ApiParams.loginType: loginType,
                  ApiParams.email: email,
                  ApiParams.identity: identity,
                  ApiParams.fcmToken: fcmToken,
                  ApiParams.profilePic: profilePic,
                  ApiParams.fullName: userName,
                  ApiParams.countryCode: countryCode,
                },
              );
    Utils.showLog("Login Api Body :: $body");

    try {
      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Login Api StatusCode :: ${response.statusCode}");
      Utils.showLog("Login Api Response :: ${response.body}");

      final jsonResponse = json.decode(response.body);
      return LoginModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("Login Api Error => $error");
    }
    return null;
  }
}

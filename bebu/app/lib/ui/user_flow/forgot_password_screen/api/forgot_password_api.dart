import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/forgot_password_screen/model/forgot_password_response_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class ForgotPasswordApi {
  static Future<ForgotPasswordResponseModel?> callApi({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Utils.showLog("Forgot Password Api Calling...");

    final uri = Uri.parse(
        "${Api.forgotPassword}${ApiParams.email}=$email&${ApiParams.newPassword}=$newPassword&${ApiParams.confirmPassword}=$confirmPassword");
    final headers = {ApiParams.key: Api.secretKey};

    Utils.showLog("Forgot Password Api uri :: $uri");
    Utils.showLog("Forgot Password Api headers :: $headers");

    try {
      final response = await http.patch(uri, headers: headers);

      log('Forgot Password API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ForgotPasswordResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Forgot Password :: $e");
    }
    return null;
  }
}

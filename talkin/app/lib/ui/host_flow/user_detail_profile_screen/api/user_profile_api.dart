import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/model/user_profile_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class UserProfileApi {
  static Future<UserProfileModel?> callApi({
    required String userId,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("User profile Api Calling...");

    final uri = Uri.parse("${Api.userProfileApi}${ApiParams.userId}=$userId");
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("User profile Api uri :: $uri");
    Utils.showLog("User profile Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('User profile API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserProfileModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("User profile :: $e");
    }
    return null;
  }
}

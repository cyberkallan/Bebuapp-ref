import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class FetchListenerProfileAPi {
  static Future<FetchListenerProfileModel?> callApi({required String loginListenerId}) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("Get Login Listener Profile Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: loginListenerId,
    };

    log("Get Login Listener Profile queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.loginListenerProfile + (query.isNotEmpty ? query : ''));

    final headers = {
      "key": Api.secretKey,
      "Content-Type": "application/json",
      "x-auth-token": "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    log("Get Login Listener Profile headers  $headers");
    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Get Login Listener Profile Response => ${response.body}");
        Utils.showLog("Get Login Listener Profile Response.status code => ${response.statusCode}");

        return FetchListenerProfileModel.fromJson(json.decode(response.body));
      } else {
        Utils.showLog("Get Login Listener Profile StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Login Listener Profile Api Error => $error");
    }
    return null;
  }
}

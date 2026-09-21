import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/random_call_screen/model/get_random_available_listener_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class GetRandomAvailableListenerApi {
  static Future<RandomAvailableListenerModel?> callApi({
    required String callType,
    required String callMode,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("available Listener Api Calling...");

    final uri = Uri.parse("${Api.availableListener}?${ApiParams.callType}=$callType&${ApiParams.callMode}=$callMode");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("available Listener Api uri :: $uri");
    Utils.showLog("available Listener Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('available Listener API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return RandomAvailableListenerModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("available Listener :: $e");
    }
    return null;
  }
}

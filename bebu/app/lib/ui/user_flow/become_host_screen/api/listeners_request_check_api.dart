import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/become_host_screen/model/listeners_request_check_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class ListenersRequestCheckApi {
  static Future<ListenersRequestCheckModel?> callApi() async {
    Utils.showLog("Listeners Request check Api Calling...");

    final token = await FirebaseAccessToken.onGet();

    final uri = Uri.parse(Api.listenersRequestCheck);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Listeners Request check Api uri :: $uri");
    Utils.showLog("Listeners Request check Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Listeners Request check API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ListenersRequestCheckModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Listeners Request check :: $e");
    }
    return null;
  }
}

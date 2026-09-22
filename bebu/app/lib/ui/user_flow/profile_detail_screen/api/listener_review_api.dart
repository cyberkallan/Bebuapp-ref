import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_review_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class ListenerReviewApi {
  static Future<ListenerReviewModel?> callApi({
    required String listenerId,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Listener Review  Api Calling...");

    final uri = Uri.parse("${Api.listenerReviewApi}${ApiParams.listenerId}=$listenerId");
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Listener Review  Api uri :: $uri");
    Utils.showLog("Listener Review  Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Listener Review  API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ListenerReviewModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Listener Review  :: $e");
    }
    return null;
  }
}

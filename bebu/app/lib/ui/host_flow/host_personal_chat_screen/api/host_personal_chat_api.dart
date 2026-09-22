import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class HostPersonalChatApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<HostPersonalChatModel?> callApi({
    required String receiverId,
    required String senderId,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Listener Personal Personal Chat List Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.receiverId: receiverId,
      ApiParams.senderId: senderId,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Listener Personal Chat List queryParameters ::$queryParameters");
    startPagination++;

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerPersonalChatListApi + query);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Listener Personal Chat List  Api uri :: $uri");
    Utils.showLog("Listener Personal Chat List  Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Listener Personal Chat List  API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostPersonalChatModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Listener Personal Chat List  :: $e");
    }
    return null;
  }
}

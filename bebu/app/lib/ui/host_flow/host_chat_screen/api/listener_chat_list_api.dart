import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_chat_screen/model/listener_chat_list_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class ListenerChatListApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<ListenerChatListModel?> callApi({
    required String listenerId,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Listener Chat List Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: listenerId,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Listener Chat List queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerChatListApi + query);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Listener Chat List  Api uri :: $uri");
    Utils.showLog("Listener Chat List  Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Listener Chat List  API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ListenerChatListModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Chat List  :: $e");
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/chat_screen/model/chat_list_response_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class ChatListApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<ChatListResponseModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Chat List Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Chat List queryParameters ::$queryParameters");
    startPagination += 1;

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.chatListApi + query);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Chat List  Api uri :: $uri");
    Utils.showLog("Chat List  Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Chat List  API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ChatListResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Chat List  :: $e");
    }
    return null;
  }
}

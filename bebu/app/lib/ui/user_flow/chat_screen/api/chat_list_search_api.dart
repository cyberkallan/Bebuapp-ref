import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/chat_screen/model/chat_list_search_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class ChatListSearchApi {
  // static int startPagination = 0;
  // static int limitPagination = 20;

  static Future<ChatListSearchModel?> callApi({
    String? searchString,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("search chat list user Api Calling...");
    // startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      // ApiParams.start: startPagination.toString(),
      // ApiParams.limit: limitPagination.toString(),
    };

    if (searchString != null && searchString.isNotEmpty) {
      queryParameters[ApiParams.searchString] = searchString;
    }

    log("search chat list user queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.searchChatUser + (query.isNotEmpty ? query : ''));
    // final uri = Uri.parse("${Api.allListeners}${ApiParams.start}=$start&${ApiParams.limit}=$limit&${ApiParams.searchString}=$searchString");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("search chat list user Api uri :: $uri");
    Utils.showLog("search chat list user Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('search chat list user API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ChatListSearchModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("search chat list user :: $e");
    }
    return null;
  }
}

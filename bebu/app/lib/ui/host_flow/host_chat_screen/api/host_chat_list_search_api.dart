import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_chat_screen/model/host_chat_list_search_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HostChatListSearchApi {
  // static int startPagination = 0;
  // static int limitPagination = 20;

  static Future<HostChatListSearchModel?> callApi({
    String? searchString,
  }) async {
    Utils.showLog("search chat list Listener Api Calling...");
    // startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
      // ApiParams.limit: limitPagination.toString(),
    };

    if (searchString != null && searchString.isNotEmpty) {
      queryParameters[ApiParams.searchString] = searchString;
    }

    log("search chat list Listener queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.searchChatListener + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("search chat list Listener Api uri :: $uri");
    Utils.showLog("search chat list Listener Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('search chat list Listener API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostChatListSearchModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("search chat list Listener :: $e");
    }
    return null;
  }
}

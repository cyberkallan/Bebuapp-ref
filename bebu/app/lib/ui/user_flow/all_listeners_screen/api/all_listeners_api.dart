import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class AllListenersApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<TopListenersModel?> callApi({
    String? searchString,
    String? talkTopic,
    String? language,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("All Listeners Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    if (searchString != null && searchString.isNotEmpty) {
      queryParameters[ApiParams.searchString] = searchString;
    }
    if (talkTopic != null && talkTopic.isNotEmpty) {
      queryParameters[ApiParams.talkTopic] = talkTopic;
    }
    if (language != null && language.isNotEmpty) {
      queryParameters[ApiParams.language] = language;
    }

    log("All Listeners queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.allListeners + (query.isNotEmpty ? query : ''));
    // final uri = Uri.parse("${Api.allListeners}${ApiParams.start}=$start&${ApiParams.limit}=$limit&${ApiParams.searchString}=$searchString");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("All Listeners Api uri :: $uri");
    Utils.showLog("All Listeners Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('All Listeners API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TopListenersModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("All Listeners :: $e");
    }
    return null;
  }
}

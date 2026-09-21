import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class TopListenersApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<TopListenersModel?> callApi({required String searchString, required String token, required String uid}) async {
    Utils.showLog("Top Listeners Api Calling...");

    startPagination += 1;

    final queryParameters = {
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
      ApiParams.searchString: searchString,
    };

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.topListeners + query);

    Utils.showLog("Top Listeners Api url => $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId
    };

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Top Listeners Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TopListenersModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Top Listeners Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("Top Listeners Api Response => ${e.toString()}");
    }
    return null;
  }
}

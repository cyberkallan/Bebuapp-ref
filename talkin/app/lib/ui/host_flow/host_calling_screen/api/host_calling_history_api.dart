import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_calling_screen/model/host_calling_history_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class HostCallingHistoryApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<HostCallingHistoryModel?> callApi({
    required String endDate,
    required String startDate,
    required String listenerId,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Host Calling History Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
      ApiParams.listenerId: listenerId,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Host Calling History queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerCallingHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Host Calling History Api uri :: $uri");
    Utils.showLog("Host Calling History Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Host Calling History API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostCallingHistoryModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Host Calling History :: $e");
    }
    return null;
  }
}

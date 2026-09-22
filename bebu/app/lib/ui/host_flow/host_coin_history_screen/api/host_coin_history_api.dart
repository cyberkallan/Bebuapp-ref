import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HostCoinHistoryApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<HostCoinHistoryModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    Utils.showLog("Host history Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Host history queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerCoinHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
    };
    Utils.showLog("Host Coin history Api uri :: $uri");
    Utils.showLog("Host Coin history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Host Coin history API STATUS CODE :: ${response.statusCode} \n Host history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostCoinHistoryModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Host history :: $e");
    }
    return null;
  }
}

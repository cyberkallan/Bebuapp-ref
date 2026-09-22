import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_coin_history_screen/model/withdrawal_record_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class WithdrawalRecordApi {
  static int startPagination = 0;
  static int limitPagination = 20;
  WithdrawalRecordModel? withdrawalRecordModel;

  static Future<WithdrawalRecordModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    Utils.showLog("Withdrawal history Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
    };

    log("Withdrawal history queryParameters ::$queryParameters");

    final uri = Uri.parse(Api.withdrawalRecord).replace(queryParameters: queryParameters);

    final headers = {
      ApiParams.key: Api.secretKey,
    };
    Utils.showLog("Withdrawal history Api uri :: $uri");
    Utils.showLog("Withdrawal history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Withdrawal history API STATUS CODE :: ${response.statusCode} \n Withdrawal history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return WithdrawalRecordModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Withdrawal history :: $e");
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class PurchaseCoinGetPlanApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<GetPurchaseCoinPlanModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("purchase Coin history Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("purchase Coin history queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.paymentHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("purchase Coin history Api uri :: $uri");
    Utils.showLog("purchase Coin history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('purchase Coin history API STATUS CODE :: ${response.statusCode} \n purchase Coin history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GetPurchaseCoinPlanModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("purchase Coin history :: $e");
    }
    return null;
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/purchase_coin_plan.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';

import '../../utils/utils.dart';

class PurchaseCoinPlanApi {
  static Future<PurchaseCoinPlan?> callApi({
    required String coinPlanId,
    required String paymentGateway,
    required String token,
    required String uid,
  }) async {
    Utils.showLog("Create Coin Plan Api Calling...");

    final queryParameters = {
      ApiParams.coinPlanId: coinPlanId,
      ApiParams.paymentGateway: paymentGateway,
    };
    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.purchasedCoinPlan + query);

    Utils.showLog("Create Coin Plan Api Url $uri");

    final headers = {ApiParams.key: Api.secretKey, ApiParams.authToken: ApiParams.tokenStartPoint + token, ApiParams.authUid: uid};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Create Coin Plan Api Response => ${response.body}");

        final jsonResponse = jsonDecode(response.body);

        return PurchaseCoinPlan.fromJson(jsonResponse);
      } else {
        Utils.showLog("Create Coin Plan Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Create Coin Plan Api Error => $error");
    }
    return null;
  }
}

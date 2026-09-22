import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class FetchCoinPlanApi {
  static Future<FetchCoinPlan?> callApi({
    required String uid,
    required String token,
  }) async {
    Utils.showLog("Fetch Coin plan Api Calling...");

    final uri = Uri.parse(Api.fetchCoinPlan);

    Utils.showLog("Fetch Coin plan Api url => $uri");

    final headers = {ApiParams.key: Api.secretKey, ApiParams.authToken: ApiParams.tokenStartPoint + token, ApiParams.authUid: uid};

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Fetch Coin plan Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return FetchCoinPlan.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Coin plan Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Coin plan Api Error => $error");
    }
    return null;
  }
}

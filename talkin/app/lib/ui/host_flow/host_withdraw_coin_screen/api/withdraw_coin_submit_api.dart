import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/withdraw_coin_submit_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class WithdrawCoinSubmitApi {
  static Future<WithdrawCoinSubmitModel?> callApi({
    required String listenerId,
    required String coin,
    required String paymentGateway,
    // required List<String> paymentDetails,
    required Map<String, String> paymentDetails,
  }) async {
    final uri = Uri.parse(Api.addWithdrawalRecord);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: "application/json",
    };

    Utils.showLog("With Draw Request Api => $uri");

    final body = json.encode({
      ApiParams.listenerId: listenerId,
      ApiParams.paymentGateway: paymentGateway,
      ApiParams.paymentDetails: paymentDetails,
      ApiParams.coin: coin,
    });

    Utils.showLog("With Draw Request Body => $body");

    try {
      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Withdraw Request Body => $body");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("With Draw Request Api Response => ${response.body}");
        return WithdrawCoinSubmitModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("With Draw Request Api Response => ${response.body}");
        Utils.showLog("With Draw Request Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("With Draw Request Api Error => $error");
    }
    return null;
  }
}

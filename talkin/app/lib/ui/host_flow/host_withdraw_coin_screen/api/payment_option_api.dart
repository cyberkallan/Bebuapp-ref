import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/payment_option_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class PaymentOptionApi {
  static Future<PaymentOptionModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    Utils.showLog("payment option Api Calling...");

    final uri = Uri.parse(Api.paymentOptions);

    final headers = {
      ApiParams.key: Api.secretKey,
    };
    Utils.showLog("payment option Api uri :: $uri");
    Utils.showLog("payment option Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('payment option API STATUS CODE :: ${response.statusCode} \n payment option API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PaymentOptionModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("payment option :: $e");
    }
    return null;
  }
}

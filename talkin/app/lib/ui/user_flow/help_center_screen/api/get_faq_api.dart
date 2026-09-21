import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class GetFaqApi {
  static Future<FaqModel?> callApi({required String category}) async {
    Utils.showLog("Faq Api Calling...");

    final uri = Uri.parse("${Api.faq}${ApiParams.faqCategory}=$category");
    final headers = {ApiParams.key: Api.secretKey};

    Utils.showLog("Faq Api uri :: $uri");
    Utils.showLog("Faq Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('FAQ API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return FaqModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("FAQ :: $e");
    }
    return null;
  }
}

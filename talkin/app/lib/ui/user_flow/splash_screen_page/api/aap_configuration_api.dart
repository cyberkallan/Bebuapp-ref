import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/splash_screen_page/model/aap_configuration_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class AppConfigurationApi {
  static Future<AppConfigurationModel?> callApi() async {
    Utils.showLog("App Configuration Api Calling...");

    final uri = Uri.parse(Api.appConfigurationApi);
    final headers = {ApiParams.key: Api.secretKey};

    Utils.showLog("App Configuration Api uri :: $uri");
    Utils.showLog("App Configuration Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('App Configuration Api STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AppConfigurationModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("App Configuration Api  :: $e");
    }
    return null;
  }
}

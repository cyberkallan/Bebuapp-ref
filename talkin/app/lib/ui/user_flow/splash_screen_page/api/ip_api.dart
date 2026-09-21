import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/splash_screen_page/model/ip_api_response_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/utils.dart';

class IpApi {
  static Future<IpApiResponseModel?> callApi() async {
    Utils.showLog("Ip Api Calling...");

    final uri = Uri.parse(Api.ipApi);

    Utils.showLog("Ip uri => $uri");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Ip Response => ${response.body}");
        Utils.showLog("Ip Response.status code => ${response.statusCode}");

        return IpApiResponseModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Ip StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Ip Api Error => $error");
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_setting_screen/model/delete_listener_response_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class DeleteListenerApi {
  static Future<DeleteListenerResponseModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("listener delete account Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
    };

    log("listener delete account Api queryParameters ::$queryParameters");

    // String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse("${Api.deleteListenerAccount}${ApiParams.listenerId}=${Database.fetchListenerProfileModel?.data?.id}");
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log("listener delete account Api URL ::$uri");

    try {
      final response = await http.delete(uri, headers: headers);

      Utils.showLog("listener delete account Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DeleteListenerResponseModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("listener delete account Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("listener delete account Api Response => ${e.toString()}");
    }
    return null;
  }
}

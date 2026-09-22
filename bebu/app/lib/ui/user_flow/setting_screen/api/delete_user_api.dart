import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/setting_screen/model/delete_user_account_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class DeleteUserApi {
  static Future<DeleteUserResponseModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("User account Delete Api Calling...");

    final uri = Uri.parse(Api.deleteUserAccount);
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log("User account Delete Api URL ::$uri");

    try {
      final response = await http.delete(uri, headers: headers);

      Utils.showLog("User account Delete Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DeleteUserResponseModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("User account Delete Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("User account Delete Api Response => ${e.toString()}");
    }
    return null;
  }
}

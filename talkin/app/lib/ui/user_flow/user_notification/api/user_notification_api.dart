import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationApi {
  static Future<UserNotificationModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("User Notification Api Calling...");

    final uri = Uri.parse(Api.userNotification);

    Utils.showLog("User Notification Api url => $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("User Notification Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserNotificationModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("User Notification Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("User Notification Api Response => ${e.toString()}");
    }
    return null;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/setting_screen/model/user_notification_update_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationUpdateApi {
  static NotificationUpdateUserModel? notificationUpdateUserModel;

  static Future<NotificationUpdateUserModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("User Notification switch Status...");

    final uri = Uri.parse(Api.updateUserNotificationPermission);
    Utils.showLog("User Notification switch Status Api URL :: $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("User Notification switch Status Api Headers => $headers");

    try {
      final response = await http.patch(uri, headers: headers);

      log("User Notification switch Status Api Response => ${response.statusCode}");

      final jsonResponse = json.decode(response.body);
      return NotificationUpdateUserModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("User Notification switch Status Api Error => $error");
    }

    return notificationUpdateUserModel;
  }
}

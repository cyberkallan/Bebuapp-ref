import 'dart:convert';
import 'dart:developer';

import 'package:talk_in/ui/host_flow/host_setting_screen/model/notification_update_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:http/http.dart' as http;

class HostNotificationUpdateApi {
  static NotificationUpdateModel? notificationUpdateModel;

  static Future<NotificationUpdateModel?> callApi({
    required String listenerId,
  }) async {
    Utils.showLog("Notification switch Status...");

    final uri = Uri.parse("${Api.updateNotifyPermission}${ApiParams.listenerId}=$listenerId");
    Utils.showLog("Notification switch Status Api URL :: $uri");

    var headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: 'application/json',
    };
    Utils.showLog("Notification switch Status Api Headers => $headers");

    try {
      final response = await http.patch(uri, headers: headers);

      log("Notification switch Status Api Response => ${response.statusCode}");

      final jsonResponse = json.decode(response.body);
      return NotificationUpdateModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("Notification switch Status Api Error => $error");
    }

    return notificationUpdateModel;
  }
}

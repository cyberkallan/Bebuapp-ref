import 'dart:convert';

import 'package:talk_in/ui/host_flow/host_home_screen/model/update_random_call_status_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:http/http.dart' as http;

class UpdateRandomCallStatusApi {
  static UpdateRandomCallStatusModel? updateRandomCallStatusModel;

  static Future<UpdateRandomCallStatusModel?> callApi({
    required String listenerId,
    required String status,
  }) async {
    Utils.showLog("Updating Random Call Status...");

    final uri = Uri.parse("${Api.updateRandomCallStatus}${ApiParams.listenerId}=$listenerId&${ApiParams.field}=$status");
    Utils.showLog("Update Random Call Status Api URL :: $uri");

    var headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: 'application/json',
    };
    Utils.showLog("Update Random Call Status Api Headers => $headers");

    try {
      final response = await http.patch(uri, headers: headers);

      Utils.showLog("Update Random Call Status Api StatusCode :: ${response.statusCode}");
      Utils.showLog("Update Random Call Status Api Response :: ${response.body}");

      final jsonResponse = json.decode(response.body);
      return UpdateRandomCallStatusModel.fromJson(jsonResponse);
    } catch (error) {
      Utils.showLog("Update Random Call Status Api Error => $error");
    }

    return updateRandomCallStatusModel;
  }
}

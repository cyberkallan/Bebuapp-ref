import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/call_cut_screen/model/submit_call_rate_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class SubmitCallRateApi {
  static Future<SubmitCallRateModel?> callApi({
    required String listenerId,
    required String review,
    required String rating,
  }) async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("submit call rate Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: listenerId,
      ApiParams.rating: rating.toString(),
      ApiParams.review: review.toString(),
    };

    log("submit call rate queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.submitCallRate + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };

    Utils.showLog("submit call rate Request Api => $uri");

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("submit call rate Request Api Response => ${response.body}");
        return SubmitCallRateModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("submit call rate Request Api Response => ${response.body}");
        Utils.showLog("submit call rate Request Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("submit call rate Request Api Error => $error");
    }
    return null;
  }
}

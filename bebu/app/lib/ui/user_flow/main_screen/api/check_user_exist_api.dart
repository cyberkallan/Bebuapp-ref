import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/main_screen/model/check_user_exist_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class CheckUserExistApi {
  static CheckUserExistModel? checkUserExistModel;

  static Future<CheckUserExistModel?> callApi({
    required String identity,
    required String loginType,
    String? email,
    String? mobileNumber,
    String? password,
  }) async {
    Utils.showLog("Check User Exist Api Calling...");

    final uri = Uri.parse(
        "${Api.checkUserExit}${ApiParams.loginType}=$loginType&${ApiParams.identity}=$identity&${ApiParams.email}=$email&${ApiParams.password}=$password");

    Utils.showLog("Check User Exist Api uri => $uri");
    final headers = {ApiParams.key: Api.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        Utils.showLog("Check User Exist Api Response => ${response.body}");
        final jsonResponse = json.decode(response.body);
        checkUserExistModel = CheckUserExistModel.fromJson(jsonResponse);
        return checkUserExistModel;
      } else {
        Utils.showLog(">>>>> Check User Exist Api StateCode Error <<<<<");
      }
    } catch (error) {
      Utils.showLog("Check User Exist Api Error => $error");
    }
    return null;
  }
}

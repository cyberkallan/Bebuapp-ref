  import 'dart:convert';
  import 'dart:developer';

  import 'package:http/http.dart' as http;
  import 'package:talk_in/ui/user_flow/host_verification_screen/model/identity_proof_model.dart';
  import 'package:talk_in/utils/api.dart';
  import 'package:talk_in/utils/api_params.dart';
  import 'package:talk_in/utils/utils.dart';

  class IdentityProofApi {
    static Future<IdentityProofModel?> callApi() async {
      Utils.showLog("IdentityProof Api Calling...");

      final uri = Uri.parse(Api.identityProofs);
      final headers = {ApiParams.key: Api.secretKey};

      Utils.showLog("IdentityProof Api uri :: $uri");
      Utils.showLog("IdentityProof Api headers :: $headers");

      try {
        final response = await http.get(uri, headers: headers);

        log('IdentityProof API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          return IdentityProofModel.fromJson(jsonResponse);
        } else {
          throw Exception('Status code is not 200');
        }
      } catch (e) {
        log("IdentityProof api  :: $e");
      }
      return null;
    }
  }

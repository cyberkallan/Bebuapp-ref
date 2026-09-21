import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/host_verification_screen/model/become_host_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class BecomeHostApi {
  static Future<BecomeHostModel?> callApi({
    required List<String> identityProof,
    required String name,
    required String image,
    required String email,
    required String identityProofType,
    required String selfIntro,
    required String talkTopic,
    required String language,
    required String fcmToken,
    required String uid,
    required String address,
    required String age,
    required String experience,
    required String nickName,
    required String gender,
    required String country,
  }) async {
    Utils.showLog("Become host Api Calling...");

    final token = await FirebaseAccessToken.onGet();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.becomeHost),
      );
      Utils.showLog("Become Host Api URL => ${request.url}");

      var headers = {
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: 'Bearer $token',
        ApiParams.authUid: uid.toString(),
        ApiParams.contentType: 'application/json',
      };
      Utils.showLog("Become Host Api Headers => $headers");

      request.fields.addAll({
        'email': email,
        'name': name,
        'selfIntro': selfIntro,
        'talkTopics': talkTopic,
        'language': language,
        'identityProofType': identityProofType,
        // 'image': image ?? '',
        // 'identityProof': identityProof []?? '',
        'fcmToken': fcmToken,
        'location': address,
        'age': age,
        'experience': experience,
        'nickName': nickName,
        'gender': gender,
        'country': country,
      });

      request.files.add(await http.MultipartFile.fromPath('image', image));

      for (String proof in identityProof) {
        if (proof.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath('identityProof', proof));
        }
      }

      request.headers.addAll(headers);
      log("Become Host Api Request => ${request.fields}");

      final response = await request.send();
      log("Become Host Api Response => ${response.statusCode}");
      log("Become Host Api Status => ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Become Host Api Response => $jsonResult");

      return BecomeHostModel.fromJson(jsonResult);
    } catch (e) {
      Utils.showLog("Become Host Api Error => $e");
      return null;
    }
  }
}

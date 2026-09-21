import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/model/host_listener_profile_update_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class HostListenerProfileUpdateApi {
  static Future<HostListenerProfileUpdateModel?> callApi({
    required String? listenerId,
    required String? selfIntro,
    required String? name,
    required String? nickName,
    required String? rateRandomAudioCall,
    required String? image,
    required String? rateRandomVideoCall,
    required String? ratePrivateVideoCall,
    required String? ratePrivateAudioCall,
    required String? language,
    required String? talkTopics,
  }) async {
    Utils.showLog("Listener Edit Profile Api Calling...");

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse("${Api.listenerEditProfile}${ApiParams.listenerId}=$listenerId"),
      );
      Utils.showLog("Listener Edit Profile Api URL => ${request.url}");

      var headers = {
        ApiParams.key: Api.secretKey,
        // ApiParams.authToken: 'Bearer $token',
        ApiParams.contentType: 'application/json',
        // ApiParams.authUid: uid
      };
      Utils.showLog("Listener Edit Profile Api Headers => $headers");

      request.fields.addAll({
        ApiParams.selfIntro: selfIntro ?? '',
        ApiParams.name: name ?? "",
        ApiParams.nickName: nickName ?? "",
        ApiParams.language: language ?? '',
        ApiParams.talkTopics: talkTopics ?? '',
        ApiParams.ratePrivateAudioCall: ratePrivateAudioCall ?? '',
        ApiParams.ratePrivateVideoCall: ratePrivateVideoCall ?? '',
        ApiParams.rateRandomAudioCall: rateRandomAudioCall ?? '',
        ApiParams.rateRandomVideoCall: rateRandomVideoCall ?? '',
        ApiParams.image: image ?? ''
      });

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(ApiParams.image, image));
      }

      request.headers.addAll(headers);
      log("Listener Edit Profile Api Request => ${request.fields}");

      final response = await request.send();
      log("Listener Edit Profile Api Response => ${response.statusCode}");
      log("Listener Edit Profile Api Status => ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Listener Edit Profile Api Response => $jsonResult");

      return HostListenerProfileUpdateModel.fromJson(jsonResult);
    } catch (e) {
      Utils.showLog("Listener Edit Profile Api Error => $e");
      return null;
    }
  }
}

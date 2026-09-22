// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart' as http;
// import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_send_image_audio_model.dart';
// import 'package:talk_in/utils/api.dart';
// import 'package:talk_in/utils/api_params.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/firebse_access_token.dart';
// import 'package:talk_in/utils/utils.dart';
//
// class HostSendImageAudioApi {
//   static Future<HostSendImageAudioModel?> callApi({
//     required int messageType,
//     required String chatTopicId,
//     required String receiverId,
//     required String senderId,
//     String? filePath,
//     String? imagePath, // full file path of image
//   }) async {
//     final token = await FirebaseAccessToken.onGet();
//
//     Utils.showLog("Listener Send Image or Audio Api Calling...");
//
//     try {
//       final uri = Uri.parse(Api.listenerSendImageAudioApi);
//       final request = http.MultipartRequest('POST', uri);
//
//       Utils.showLog("Listener Send Image or Audio URL => ${request.url}");
//
//       final headers = {
//         ApiParams.key: Api.secretKey,
//         ApiParams.authToken: 'Bearer $token',
//         ApiParams.authUid: Database.loginUserFirebaseId,
//       };
//
//       Utils.showLog("Listener Send Image or Audio Api headers :: $headers");
//
//       // Attach image file
//       request.fields.addAll({
//         ApiParams.chatTopicId: chatTopicId,
//         ApiParams.receiverId: receiverId,
//         ApiParams.senderId: senderId,
//         ApiParams.messageType: messageType.toString(),
//         ApiParams.image: imagePath ?? '',
//         ApiParams.audio: filePath ?? '',
//       });
//
//       // if (imagePath != null) {
//       //   request.files.add(await http.MultipartFile.fromPath('image', imagePath));
//       // }
//       if (messageType == 2) {
//         request.files.add(await http.MultipartFile.fromPath('image', imagePath ?? '')); // Message Type Image => 2
//       } else {
//         request.files.add(await http.MultipartFile.fromPath('audio', filePath ?? '')); // Message Type Audio => 3
//       }
//
//       request.headers.addAll(headers);
//
//       log("Listener Send Image or Audio Api Request => ${request.fields}");
//
//       final response = await request.send();
//       log('Listener Send Image or Audio  API STATUS CODE :: ${response.statusCode} ');
//
//       final responseBody = await response.stream.bytesToString();
//       final jsonResult = jsonDecode(responseBody);
//       Utils.showLog("Listener Send Image or Audio Api Response => $jsonResult");
//       return HostSendImageAudioModel.fromJson(jsonResult);
//     } catch (e) {
//       log("Listener Send Image or Audio API error: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_send_image_audio_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class HostSendImageAudioApi {
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  static Future<HostSendImageAudioModel?> callApi({
    required int messageType,
    required String chatTopicId,
    required String receiverId,
    required String senderId,
    String? filePath,
    String? imagePath,
  }) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("Host Send Image or Audio API Calling...");

    try {
      final uri = Uri.parse(Api.listenerSendImageAudioApi);
      final request = http.MultipartRequest('POST', uri);

      final headers = {
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: 'Bearer $token',
        ApiParams.authUid: Database.loginUserFirebaseId,
      };
      request.headers.addAll(headers);

      final fileToSend = messageType == 2 ? imagePath : filePath;

      if (fileToSend == null || fileToSend.isEmpty) {
        log("❌ File path is missing.");
        return null;
      }

      // Validate file
      if (!await _isValidFile(fileToSend, messageType)) {
        log("❌ File failed validation.");
        return null;
      }

      final sanitizedFileName = _sanitizeFileName(fileToSend);

      // Add form fields
      request.fields.addAll({
        ApiParams.chatTopicId: chatTopicId,
        ApiParams.receiverId: receiverId,
        ApiParams.senderId: senderId,
        ApiParams.messageType: messageType.toString(),
        ApiParams.image: imagePath ?? '',
        ApiParams.audio: filePath ?? '',
      });

      // Attach file
      request.files.add(await http.MultipartFile.fromPath(
        messageType == 2 ? 'image' : 'audio',
        fileToSend,
        filename: sanitizedFileName,
      ));

      log("Host Send Image/Audio Api Request => ${request.fields}");

      final response = await request.send();
      log('Host Send Image/Audio API STATUS CODE :: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Host Send Image/Audio API Response => $jsonResult");

      return HostSendImageAudioModel.fromJson(jsonResult);
    } catch (e) {
      log("Host Send Image/Audio API error: $e");
      return null;
    }
  }

  static Future<bool> _isValidFile(String path, int messageType) async {
    final file = File(path);

    if (!await file.exists()) {
      log("❌ File does not exist.");
      return false;
    }

    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      log("❌ File size exceeds 10MB: $fileSize bytes.");
      return false;
    }

    final mimeType = lookupMimeType(path);
    if (messageType == 2 && !(mimeType?.startsWith('image/') ?? false)) {
      log("❌ Not a valid image file: $mimeType");
      return false;
    } else if (messageType == 3 && !(mimeType?.startsWith('audio/') ?? false)) {
      log("❌ Not a valid audio file: $mimeType");
      return false;
    }

    return true;
  }

  static String _sanitizeFileName(String filePath) {
    final ext = filePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp.$ext';
  }
}

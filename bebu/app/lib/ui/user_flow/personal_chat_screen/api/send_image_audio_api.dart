// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart' as http;
// import 'package:talk_in/ui/user_flow/personal_chat_screen/model/send_image_audio_model.dart';
// import 'package:talk_in/utils/api.dart';
// import 'package:talk_in/utils/api_params.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/firebse_access_token.dart';
// import 'package:talk_in/utils/utils.dart';
//
// class SendImageAudioApi {
//   static Future<SendImageAudioModel?> callApi({
//     required int messageType,
//     required String chatTopicId,
//     required String receiverId,
//     String? imagePath, // full file path of image
//     String? filePath, // full file path of image
//   }) async {
//     final token = await FirebaseAccessToken.onGet();
//
//     Utils.showLog(" Send Image or Audio Api Calling...");
//
//     try {
//       final uri = Uri.parse(Api.sendImageAudioApi);
//       final request = http.MultipartRequest('POST', uri);
//
//       Utils.showLog(" Send Image or Audio URL => ${request.url}");
//
//       final headers = {
//         ApiParams.key: Api.secretKey,
//         ApiParams.authToken: 'Bearer $token',
//         ApiParams.authUid: Database.loginUserFirebaseId,
//       };
//
//       Utils.showLog(" Send Image or Audio Api headers :: $headers");
//
//       // Attach image file
//       request.fields.addAll({
//         ApiParams.chatTopicId: chatTopicId,
//         ApiParams.receiverId: receiverId,
//         ApiParams.messageType: messageType.toString(),
//         ApiParams.image: imagePath ?? '',
//         ApiParams.audio: filePath ?? '',
//       });
//
//       if (messageType == 2) {
//         request.files.add(await http.MultipartFile.fromPath('image', imagePath ?? '')); // Message Type Image => 2
//       } else {
//         request.files.add(await http.MultipartFile.fromPath('audio', filePath ?? '')); // Message Type Audio => 3
//       }
//
//       request.headers.addAll(headers);
//
//       log(" Send Image or Audio Api Request => ${request.fields}");
//
//       final response = await request.send();
//       log(' Send Image or Audio  API STATUS CODE :: ${response.statusCode} ');
//
//       final responseBody = await response.stream.bytesToString();
//       final jsonResult = jsonDecode(responseBody);
//       Utils.showLog(" Send Image or Audio Api Response => $jsonResult");
//       return SendImageAudioModel.fromJson(jsonResult);
//     } catch (e) {
//       log(" Send Image or Audio API error: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/send_image_audio_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class SendImageAudioApi {
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  static Future<SendImageAudioModel?> callApi({
    required int messageType,
    required String chatTopicId,
    required String receiverId,
    String? imagePath, // full path
    String? filePath, // full path
  }) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("Send Image or Audio API Calling...");

    try {
      final uri = Uri.parse(Api.sendImageAudioApi);
      final request = http.MultipartRequest('POST', uri);

      final headers = {
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: 'Bearer $token',
        ApiParams.authUid: Database.loginUserFirebaseId,
      };

      request.headers.addAll(headers);

      // Determine which file is being uploaded
      final fileToSend = messageType == 2 ? imagePath : filePath;
      if (fileToSend == null || fileToSend.isEmpty) {
        log("❌ File path is missing.");
        return null;
      }

      // File validation
      if (!await _isValidFile(fileToSend, messageType)) {
        log("❌ File failed validation checks.");
        return null;
      }

      final sanitizedFileName = _sanitizeFileName(fileToSend);

      request.fields.addAll({
        ApiParams.chatTopicId: chatTopicId,
        ApiParams.receiverId: receiverId,
        ApiParams.messageType: messageType.toString(),
      });

      request.files.add(await http.MultipartFile.fromPath(
        messageType == 2 ? 'image' : 'audio',
        fileToSend,
        filename: sanitizedFileName,
      ));

      log("Send Image/Audio Api Request => ${request.fields}");

      final response = await request.send();
      log('Send Image/Audio API STATUS CODE :: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Send Image or Audio API Response => $jsonResult");

      return SendImageAudioModel.fromJson(jsonResult);
    } catch (e) {
      log("Send Image or Audio API error: $e");
      return null;
    }
  }

  static Future<bool> _isValidFile(String path, int messageType) async {
    final file = File(path);

    // 1. File exists
    if (!await file.exists()) {
      log("❌ File does not exist.");
      return false;
    }

    // 2. Size check
    final size = await file.length();
    if (size > maxFileSize) {
      log("❌ File too large: $size bytes");
      return false;
    }

    // 3. MIME type check
    final mimeType = lookupMimeType(path);
    if (messageType == 2 && !(mimeType?.startsWith('image/') ?? false)) {
      log("❌ Invalid image MIME type: $mimeType");
      return false;
    }
    // else if (messageType == 3 && !(mimeType?.startsWith('audio/') ?? false)) {
    //   log("❌ Invalid audio MIME type: $mimeType");
    //   return false;
    // }

    return true;
  }

  static String _sanitizeFileName(String originalPath) {
    final ext = originalPath.split('.').last;
    final safeName = DateTime.now().millisecondsSinceEpoch.toString();
    return '$safeName.$ext';
  }
}

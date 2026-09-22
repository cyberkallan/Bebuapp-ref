import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/gifts/model/gift_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class GiftApi {
  static String get _base => '${Api.baseUrl}api/user/gift';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();
    return {
      'key': Api.secretKey,
      'Content-Type': 'application/json',
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<GiftCatalog?> list() async {
    try {
      final res = await http.get(Uri.parse('$_base/list'), headers: await _headers());
      Utils.showLog('Gift list => ${res.statusCode} ${res.body.length} bytes');
      if (res.statusCode != 200) return null;
      final j = json.decode(res.body);
      if (j['status'] != true || j['data'] == null) return null;
      return GiftCatalog.fromJson(Map<String, dynamic>.from(j['data'] as Map));
    } catch (e) {
      Utils.showLog('Gift list error => $e');
      return null;
    }
  }

  static Future<GiftSendResult> send({required String giftId, required String listenerId, String? chatTopicId, required String context, String? callId}) async {
    try {
      final body = json.encode({
        'giftId': giftId,
        'listenerId': listenerId,
        if (chatTopicId != null && chatTopicId.isNotEmpty) 'chatTopicId': chatTopicId,
        'context': context,
        if (callId != null && callId.isNotEmpty) 'callId': callId,
      });
      final res = await http.post(Uri.parse('$_base/send'), headers: await _headers(), body: body);
      Utils.showLog('Gift send => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return GiftSendResult(ok: false, message: 'Server error (${res.statusCode})');
      final j = Map<String, dynamic>.from(json.decode(res.body) as Map);
      final data = j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : const <String, dynamic>{};
      if (j['status'] == true) {
        return GiftSendResult(
          ok: true,
          message: j['message']?.toString() ?? 'Sent',
          balance: (data['balance'] as num?)?.toInt(),
          hostCoins: (data['hostCoins'] as num?)?.toInt() ?? 0,
          chatMessage: data['message'] is Map ? Map<String, dynamic>.from(data['message'] as Map) : null,
          chatTopicId: data['chatTopicId']?.toString(),
        );
      }
      return GiftSendResult(
        ok: false,
        message: j['message']?.toString() ?? 'Could not send the gift',
        insufficient: j['code'] == 'INSUFFICIENT_COINS',
        balance: (data['balance'] as num?)?.toInt(),
        need: (data['need'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      Utils.showLog('Gift send error => $e');
      return const GiftSendResult(ok: false, message: 'You seem to be offline. Try again in a moment.');
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/daily_reward/model/daily_reward_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class DailyRewardApi {
  static String get _base => '${Api.baseUrl}api/user/dailyReward';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();
    return {
      'key': Api.secretKey,
      'Content-Type': 'application/json',
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<DailyRewardStatus?> status() async {
    try {
      final res = await http.get(Uri.parse('$_base/status'), headers: await _headers());
      Utils.showLog('Daily reward status => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return null;
      final j = json.decode(res.body);
      if (j['status'] != true || j['data'] == null) return null;
      return DailyRewardStatus.fromJson(Map<String, dynamic>.from(j['data'] as Map));
    } catch (e) {
      Utils.showLog('Daily reward status error => $e');
      return null;
    }
  }

  /// Returns the new status on success, or a status with [DailyRewardStatus.error]
  /// set when the server refused (already claimed, disabled, offline).
  static Future<DailyRewardStatus> claim() async {
    try {
      final res = await http.post(Uri.parse('$_base/claim'), headers: await _headers(), body: '{}');
      Utils.showLog('Daily reward claim => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return DailyRewardStatus.failed('Server error (${res.statusCode})');
      final j = Map<String, dynamic>.from(json.decode(res.body) as Map);
      final data = j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : null;
      if (j['status'] == true && data != null) return DailyRewardStatus.fromJson(data);
      return DailyRewardStatus.failed(j['message']?.toString() ?? 'Could not collect the reward', fallback: data);
    } catch (e) {
      Utils.showLog('Daily reward claim error => $e');
      return DailyRewardStatus.failed('You seem to be offline. Try again in a moment.');
    }
  }
}

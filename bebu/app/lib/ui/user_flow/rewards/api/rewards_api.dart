import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/rewards/model/rewards_hub_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

/// Outcome of a claim / apply call.
class RewardResult {
  const RewardResult({required this.ok, this.message = '', this.code, this.reward, this.balance, this.data});
  final bool ok;
  final String message;
  final String? code; // CLAIMED | INCOMPLETE
  final GrantedReward? reward;
  final int? balance;
  final Map<String, dynamic>? data;
}

class RewardsApi {
  static String get _base => '${Api.baseUrl}api/user/rewards';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();
    return {
      'key': Api.secretKey,
      'Content-Type': 'application/json',
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<RewardsHub?> hub() async {
    try {
      final res = await http.get(Uri.parse('$_base/hub'), headers: await _headers());
      Utils.showLog('Rewards hub => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return null;
      final j = json.decode(res.body);
      if (j['status'] != true || j['data'] == null) return null;
      return RewardsHub.fromJson(Map<String, dynamic>.from(j['data'] as Map));
    } catch (e) {
      Utils.showLog('Rewards hub error => $e');
      return null;
    }
  }

  static Future<RewardResult> claimProfile() => _post('profile/claim', const {});

  static Future<RewardResult> applyReferral(String code) => _post('referral/apply', {'code': code});

  static Future<RewardResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$_base/$path'), headers: await _headers(), body: json.encode(body));
      Utils.showLog('Rewards $path => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return RewardResult(ok: false, message: 'Server error (${res.statusCode})');
      final j = Map<String, dynamic>.from(json.decode(res.body) as Map);
      final data = j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : null;
      final ok = j['status'] == true;
      GrantedReward? reward;
      if (ok && data != null) {
        reward = GrantedReward.fromJson(data) ??
            (data['inviteeCoins'] is num && (data['inviteeCoins'] as num) > 0
                ? GrantedReward(kind: 'referral', coins: (data['inviteeCoins'] as num).toInt(), balance: data['balance'] is num ? (data['balance'] as num).toInt() : null)
                : null);
      }
      return RewardResult(
        ok: ok,
        message: j['message']?.toString() ?? '',
        code: j['code']?.toString(),
        reward: reward,
        balance: data?['balance'] is num ? (data!['balance'] as num).toInt() : null,
        data: data,
      );
    } catch (e) {
      Utils.showLog('Rewards $path error => $e');
      return const RewardResult(ok: false, message: 'You seem to be offline. Try again in a moment.');
    }
  }
}

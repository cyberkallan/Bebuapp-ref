import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

/// Outcome of a buy / unlock / apply call.
class PremiumResult {
  const PremiumResult({required this.ok, this.message = '', this.code, this.data});
  final bool ok;
  final String message;
  final String? code; // INSUFFICIENT_COINS | PRO_REQUIRED | LOCKED
  final Map<String, dynamic>? data;

  int? get coins => data?['coins'] is num ? (data!['coins'] as num).toInt() : null;
  int? get price => data?['price'] is num ? (data!['price'] as num).toInt() : null;
  int? get need => data?['need'] is num ? (data!['need'] as num).toInt() : null;
  ProStatus? get status => data?['premium'] is Map ? ProStatus.fromJson(Map<String, dynamic>.from(data!['premium'] as Map)) : null;
  ActiveStyle? get style => data?['style'] is Map ? ActiveStyle.fromJson(Map<String, dynamic>.from(data!['style'] as Map)) : null;
}

class PremiumApi {
  static String get _base => '${Api.baseUrl}api/user/premium';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();
    return {
      'key': Api.secretKey,
      'Content-Type': 'application/json',
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<PremiumStatus?> status() async {
    final j = await _get('status');
    return j == null ? null : PremiumStatus.fromJson(j);
  }

  static Future<StudioCatalog?> studio() async {
    final j = await _get('studio');
    return j == null ? null : StudioCatalog.fromJson(j);
  }

  static Future<PremiumResult> buy(String passKey) => _post('buy', {'passKey': passKey});
  static Future<PremiumResult> badge(bool enabled) => _post('badge', {'enabled': enabled});
  static Future<PremiumResult> unlock(String key) => _post('unlock', {'key': key});
  static Future<PremiumResult> apply(StyleType type, String key) => _post('apply', {'type': type.apiName, 'key': key});

  static Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$_base/$path'), headers: await _headers());
      Utils.showLog('Premium $path => ${res.statusCode} ${res.body.length > 600 ? res.body.substring(0, 600) : res.body}');
      if (res.statusCode != 200) return null;
      final j = json.decode(res.body);
      if (j['status'] != true || j['data'] == null) return null;
      return Map<String, dynamic>.from(j['data'] as Map);
    } catch (e) {
      Utils.showLog('Premium $path error => $e');
      return null;
    }
  }

  static Future<PremiumResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$_base/$path'), headers: await _headers(), body: json.encode(body));
      Utils.showLog('Premium $path => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return PremiumResult(ok: false, message: 'Server error (${res.statusCode})');
      final j = Map<String, dynamic>.from(json.decode(res.body) as Map);
      return PremiumResult(
        ok: j['status'] == true,
        message: j['message']?.toString() ?? '',
        code: j['code']?.toString(),
        data: j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : null,
      );
    } catch (e) {
      Utils.showLog('Premium $path error => $e');
      return const PremiumResult(ok: false, message: 'You seem to be offline. Try again in a moment.');
    }
  }
}

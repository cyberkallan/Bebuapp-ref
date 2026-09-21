import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

/// Result of a coin unlock or an equip call.
class StudioResult {
  const StudioResult({required this.ok, this.message = '', this.code, this.coins, this.data});
  final bool ok;
  final String message;
  final String? code; // INSUFFICIENT_COINS | LOCKED
  final int? coins;
  final Map<String, dynamic>? data;
}

class AvatarStudioApi {
  static String get _base => '${Api.baseUrl}api/user/avatar';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();
    return {
      'key': Api.secretKey,
      'Content-Type': 'application/json',
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<StudioData?> fetchStudio() async {
    try {
      final res = await http.get(Uri.parse('$_base/studio'), headers: await _headers());
      Utils.showLog('Avatar studio => ${res.statusCode}');
      if (res.statusCode != 200) return null;
      final j = json.decode(res.body);
      if (j['status'] != true) return null;
      return StudioData.fromJson(Map<String, dynamic>.from(j['data'] as Map));
    } catch (e) {
      Utils.showLog('Avatar studio error => $e');
      return null;
    }
  }

  static Future<StudioResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$_base/$path'), headers: await _headers(), body: json.encode(body));
      Utils.showLog('Avatar $path => ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) return StudioResult(ok: false, message: 'Server error (${res.statusCode})');
      final j = Map<String, dynamic>.from(json.decode(res.body) as Map);
      return StudioResult(
        ok: j['status'] == true,
        message: j['message']?.toString() ?? '',
        code: j['code']?.toString(),
        coins: j['coins'] is num ? (j['coins'] as num).toInt() : null,
        data: j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : j,
      );
    } catch (e) {
      Utils.showLog('Avatar $path error => $e');
      return const StudioResult(ok: false, message: 'Could not reach the server');
    }
  }

  static Future<StudioResult> unlock(String itemId) => _post('unlock', {'itemId': itemId});

  static Future<StudioResult> equip(Map<StudioSlot, String?> slots, {required bool active}) =>
      _post('equip', {for (final e in slots.entries) e.key.key: e.value, 'active': active});

  static Future<StudioResult> usePreset(String key) => _post('preset', {'key': key});
}

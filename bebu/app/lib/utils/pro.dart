import 'dart:convert';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';

/// bebu Pro state shared by every screen: the admin config (is Pro on, what is
/// it called, which perks), this user's entitlement, and the applied Style
/// Studio look. Everything is cached in local storage so the first frame after
/// launch already shows the right tick, font and wallpaper.
class Pro {
  Pro._();

  static ProConfig config = const ProConfig();
  static ProStatus status = ProStatus.none;
  static ActiveStyle style = ActiveStyle.none;

  static const _kConfig = 'proConfig';
  static const _kStatus = 'proStatus';
  static const _kStyle = 'proStyle';

  /// Whether anything Pro-related may be shown at all.
  static bool get enabled => config.enabled;
  static String get name => config.name.isEmpty ? 'bebu Pro' : config.name;
  static bool get isActive => enabled && status.active;
  static bool get showBadge => enabled && config.features.goldenTick && status.active && status.badge;
  static ProFeatures get features => config.features;
  static bool get studioEnabled => enabled && config.features.styleStudio;

  /// Restore the cached state before the first frame.
  static void init() {
    config = ProConfig.fromJson(_read(_kConfig));
    status = ProStatus.fromJson(_read(_kStatus));
    style = ActiveStyle.fromJson(_read(_kStyle));
    _applyFont(rebuild: false);
  }

  static Map<String, dynamic>? _read(String k) {
    final raw = Database.localStorage.read(k);
    if (raw is String && raw.isNotEmpty) {
      try {
        return Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }
    return null;
  }

  /// `premium` object from the settings / app configuration API.
  static void rememberConfig(Map<String, dynamic>? json) {
    if (json == null) return;
    final next = ProConfig.fromJson(json);
    final changed = jsonEncode(next.toJson()) != jsonEncode(config.toJson());
    config = next;
    Database.localStorage.write(_kConfig, jsonEncode(next.toJson()));
    if (changed) _applyFont(rebuild: true);
  }

  /// `premiumStatus` + `activeStyle` from the user profile API.
  static void rememberUser(Map<String, dynamic>? premiumStatus, Map<String, dynamic>? activeStyle) {
    if (premiumStatus != null) rememberStatus(ProStatus.fromJson(premiumStatus));
    if (activeStyle != null) rememberStyle(ActiveStyle.fromJson(activeStyle));
  }

  static void rememberStatus(ProStatus s) {
    final changed = jsonEncode(s.toJson()) != jsonEncode(status.toJson());
    status = s;
    Database.localStorage.write(_kStatus, jsonEncode(s.toJson()));
    if (changed) Get.forceAppUpdate();
  }

  static void rememberStyle(ActiveStyle s) {
    final changed = s.encode() != style.encode();
    style = s;
    Database.localStorage.write(_kStyle, s.encode());
    if (changed) _applyFont(rebuild: true);
  }

  /// Local-only update after apply/reset so the UI reacts before the refetch.
  static void setSlot(StyleType t, ActiveStyleItem? v) => rememberStyle(style.withSlot(t, v));

  static void _applyFont({required bool rebuild}) {
    final fam = enabled && config.features.styleStudio ? style.font?.data['family']?.toString() : null;
    final before = BebuTheme.fontFamily;
    BebuTheme.configureFont(fam);
    if (rebuild || before != BebuTheme.fontFamily) {
      if (rebuild) Get.forceAppUpdate();
    }
  }

  /// Forget everything on logout.
  static void clear() {
    status = ProStatus.none;
    style = ActiveStyle.none;
    Database.localStorage.remove(_kStatus);
    Database.localStorage.remove(_kStyle);
    _applyFont(rebuild: false);
  }

  // ── convenience for the themed surfaces ────────────────────────────────────

  /// Absolute URL for a server-relative asset path (wallpapers).
  static String assetUrl(String path) {
    if (path.isEmpty || path.startsWith('http')) return path;
    return '${Api.baseUrl}${path.replaceAll('\\', '/')}';
  }

  static Map<String, dynamic>? get chatThemeData => studioEnabled ? style.chatTheme?.data : null;
  static Map<String, dynamic>? get callThemeData => studioEnabled ? style.callTheme?.data : null;
  static String get wallpaperUrl => studioEnabled && style.wallpaper != null ? assetUrl(style.wallpaper!.image) : '';
}

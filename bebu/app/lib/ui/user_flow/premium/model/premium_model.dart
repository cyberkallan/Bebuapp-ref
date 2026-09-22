import 'dart:convert';

import 'package:flutter/material.dart';

int _int(dynamic v, [int d = 0]) => v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? d : d);
bool _bool(dynamic v, [bool d = false]) => v is bool ? v : (v is String ? v == 'true' : d);
String _str(dynamic v, [String d = '']) => v == null ? d : v.toString();
Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : const {};

Color? parseHex(dynamic v) {
  if (v == null) return null;
  var s = v.toString().trim().replaceFirst('#', '');
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final n = int.tryParse(s, radix: 16);
  return n == null ? null : Color(n);
}

List<Color> parseHexList(dynamic v, List<Color> fallback) {
  if (v is! List) return fallback;
  final out = v.map(parseHex).whereType<Color>().toList();
  return out.length >= 2 ? out : (out.length == 1 ? [out.first, out.first] : fallback);
}

/// One purchasable Pro pass (admin-defined).
class ProPass {
  const ProPass({required this.key, required this.name, required this.days, required this.coins, this.badge = ''});
  final String key;
  final String name;
  final int days; // 0 = lifetime
  final int coins;
  final String badge;

  bool get lifetime => days == 0;

  /// "7 days", "1 month", "Forever"
  String get durationLabel {
    if (lifetime) return 'Forever';
    if (days % 365 == 0) return days == 365 ? '1 year' : '${days ~/ 365} years';
    if (days % 30 == 0) return days == 30 ? '1 month' : '${days ~/ 30} months';
    if (days % 7 == 0) return days == 7 ? '1 week' : '${days ~/ 7} weeks';
    return '$days days';
  }

  /// Coins per day, for the "≈ N coins/day" hint. Null for lifetime.
  double? get perDay => lifetime ? null : coins / days;

  factory ProPass.fromJson(Map<String, dynamic> j) => ProPass(key: _str(j['key']), name: _str(j['name']), days: _int(j['days'], 7), coins: _int(j['coins']), badge: _str(j['badge']));
  Map<String, dynamic> toJson() => {'key': key, 'name': name, 'days': days, 'coins': coins, 'badge': badge};
}

/// Which perks the admin switched on.
class ProFeatures {
  const ProFeatures({
    this.unlimitedRandomMatch = true,
    this.freeRandomMatchesPerDay = 5,
    this.goldenTick = true,
    this.proAvatarItems = true,
    this.proGifts = true,
    this.styleStudio = true,
    this.freeStyleItems = true,
  });
  final bool unlimitedRandomMatch;
  final int freeRandomMatchesPerDay;
  final bool goldenTick;
  final bool proAvatarItems;
  final bool proGifts;
  final bool styleStudio;
  final bool freeStyleItems;

  factory ProFeatures.fromJson(Map<String, dynamic> j) => ProFeatures(
        unlimitedRandomMatch: _bool(j['unlimitedRandomMatch'], true),
        freeRandomMatchesPerDay: _int(j['freeRandomMatchesPerDay'], 5),
        goldenTick: _bool(j['goldenTick'], true),
        proAvatarItems: _bool(j['proAvatarItems'], true),
        proGifts: _bool(j['proGifts'], true),
        styleStudio: _bool(j['styleStudio'], true),
        freeStyleItems: _bool(j['freeStyleItems'], true),
      );
  Map<String, dynamic> toJson() => {
        'unlimitedRandomMatch': unlimitedRandomMatch,
        'freeRandomMatchesPerDay': freeRandomMatchesPerDay,
        'goldenTick': goldenTick,
        'proAvatarItems': proAvatarItems,
        'proGifts': proGifts,
        'styleStudio': styleStudio,
        'freeStyleItems': freeStyleItems,
      };
}

/// Admin configuration of the Pro programme (public part).
class ProConfig {
  const ProConfig({this.enabled = true, this.name = 'bebu Pro', this.tagline = '', this.passes = const [], this.features = const ProFeatures()});
  final bool enabled;
  final String name;
  final String tagline;
  final List<ProPass> passes;
  final ProFeatures features;

  static const off = ProConfig(enabled: false);

  factory ProConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const ProConfig();
    return ProConfig(
      enabled: _bool(j['enabled'], true),
      name: _str(j['name'], 'bebu Pro'),
      tagline: _str(j['tagline']),
      passes: (j['passes'] is List) ? (j['passes'] as List).map((e) => ProPass.fromJson(_map(e))).where((p) => p.key.isNotEmpty).toList() : const [],
      features: ProFeatures.fromJson(_map(j['features'])),
    );
  }
  Map<String, dynamic> toJson() => {'enabled': enabled, 'name': name, 'tagline': tagline, 'passes': passes.map((p) => p.toJson()).toList(), 'features': features.toJson()};
}

/// This user's entitlement.
class ProStatus {
  const ProStatus({this.active = false, this.lifetime = false, this.until, this.planKey = '', this.badge = true, this.showBadge = false, this.since});
  final bool active;
  final bool lifetime;
  final DateTime? until;
  final String planKey;
  final bool badge; // user's own switch
  final bool showBadge; // effective: active && admin allows && badge
  final DateTime? since;

  static const none = ProStatus();

  int get daysLeft => until == null ? 0 : until!.difference(DateTime.now()).inHours.clamp(0, 1 << 30) ~/ 24;
  Duration get timeLeft => until == null ? Duration.zero : until!.difference(DateTime.now());

  factory ProStatus.fromJson(Map<String, dynamic>? j) {
    if (j == null) return none;
    DateTime? d(dynamic v) => v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
    return ProStatus(
      active: _bool(j['active']),
      lifetime: _bool(j['lifetime']),
      until: d(j['until']),
      planKey: _str(j['planKey']),
      badge: _bool(j['badge'], true),
      showBadge: _bool(j['showBadge']),
      since: d(j['since']),
    );
  }
  Map<String, dynamic> toJson() => {'active': active, 'lifetime': lifetime, 'until': until?.toUtc().toIso8601String(), 'planKey': planKey, 'badge': badge, 'showBadge': showBadge, 'since': since?.toUtc().toIso8601String()};
  ProStatus copyWith({bool? badge, bool? showBadge}) => ProStatus(active: active, lifetime: lifetime, until: until, planKey: planKey, badge: badge ?? this.badge, showBadge: showBadge ?? this.showBadge, since: since);
}

/// Daily random-match allowance for free users.
class MatchQuota {
  const MatchQuota({this.unlimited = true, this.pro = false, this.used = 0, this.limit = 0, this.left});
  final bool unlimited;
  final bool pro;
  final int used;
  final int limit;
  final int? left;

  factory MatchQuota.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const MatchQuota();
    return MatchQuota(unlimited: _bool(j['unlimited'], true), pro: _bool(j['pro']), used: _int(j['used']), limit: _int(j['limit']), left: j['left'] == null ? null : _int(j['left']));
  }
}

enum StyleType { wallpaper, font, chatTheme, callTheme }

StyleType? styleTypeFrom(String s) => switch (s) {
      'wallpaper' => StyleType.wallpaper,
      'font' => StyleType.font,
      'chatTheme' => StyleType.chatTheme,
      'callTheme' => StyleType.callTheme,
      _ => null,
    };

extension StyleTypeX on StyleType {
  String get apiName => switch (this) { StyleType.wallpaper => 'wallpaper', StyleType.font => 'font', StyleType.chatTheme => 'chatTheme', StyleType.callTheme => 'callTheme' };
  String get label => switch (this) { StyleType.wallpaper => 'Wallpapers', StyleType.font => 'Fonts', StyleType.chatTheme => 'Chat themes', StyleType.callTheme => 'Call screens' };
  IconData get icon => switch (this) { StyleType.wallpaper => Icons.wallpaper_rounded, StyleType.font => Icons.text_fields_rounded, StyleType.chatTheme => Icons.chat_bubble_rounded, StyleType.callTheme => Icons.phone_in_talk_rounded };
}

/// One Style Studio item, already priced for this user by the server.
class StyleItem {
  const StyleItem({
    required this.id,
    required this.key,
    required this.type,
    required this.name,
    this.tagline = '',
    this.mood = '',
    this.image = '',
    this.thumb = '',
    this.data = const {},
    this.coins = 0,
    this.price = 0,
    this.includedInPro = false,
    this.proOnly = true,
    this.owned = false,
    this.locked = true,
    this.sortOrder = 0,
  });
  final String id;
  final String key;
  final StyleType type;
  final String name;
  final String tagline;
  final String mood;
  final String image;
  final String thumb;
  final Map<String, dynamic> data;
  final int coins;
  final int price;
  final bool includedInPro;
  final bool proOnly;
  final bool owned;
  final bool locked;
  final int sortOrder;

  static StyleItem? fromJson(Map<String, dynamic> j) {
    final t = styleTypeFrom(_str(j['type']));
    if (t == null) return null;
    return StyleItem(
      id: _str(j['_id']),
      key: _str(j['key']),
      type: t,
      name: _str(j['name']),
      tagline: _str(j['tagline']),
      mood: _str(j['mood']),
      image: _str(j['image']),
      thumb: _str(j['thumb']),
      data: _map(j['data']),
      coins: _int(j['coins']),
      price: _int(j['price']),
      includedInPro: _bool(j['includedInPro']),
      proOnly: _bool(j['proOnly'], true),
      owned: _bool(j['owned']),
      locked: _bool(j['locked'], true),
      sortOrder: _int(j['sortOrder']),
    );
  }

  StyleItem copyWith({bool? owned, bool? locked, int? price}) => StyleItem(
        id: id,
        key: key,
        type: type,
        name: name,
        tagline: tagline,
        mood: mood,
        image: image,
        thumb: thumb,
        data: data,
        coins: coins,
        price: price ?? this.price,
        includedInPro: includedInPro,
        proOnly: proOnly,
        owned: owned ?? this.owned,
        locked: locked ?? this.locked,
        sortOrder: sortOrder,
      );

  Map<String, dynamic> toActiveJson() => {'key': key, 'name': name, 'image': image, 'thumb': thumb, 'data': data};
}

/// A resolved style slot as saved by the server (no pricing).
class ActiveStyleItem {
  const ActiveStyleItem({required this.key, required this.name, this.image = '', this.thumb = '', this.data = const {}});
  final String key;
  final String name;
  final String image;
  final String thumb;
  final Map<String, dynamic> data;

  static ActiveStyleItem? fromJson(dynamic v) {
    if (v is! Map) return null;
    final j = Map<String, dynamic>.from(v);
    final key = _str(j['key']);
    if (key.isEmpty) return null;
    return ActiveStyleItem(key: key, name: _str(j['name']), image: _str(j['image']), thumb: _str(j['thumb']), data: _map(j['data']));
  }
  Map<String, dynamic> toJson() => {'key': key, 'name': name, 'image': image, 'thumb': thumb, 'data': data};
}

/// The four style slots currently applied.
class ActiveStyle {
  const ActiveStyle({this.font, this.wallpaper, this.chatTheme, this.callTheme});
  final ActiveStyleItem? font;
  final ActiveStyleItem? wallpaper;
  final ActiveStyleItem? chatTheme;
  final ActiveStyleItem? callTheme;

  static const none = ActiveStyle();
  bool get isDefault => font == null && wallpaper == null && chatTheme == null && callTheme == null;

  factory ActiveStyle.fromJson(Map<String, dynamic>? j) {
    if (j == null) return none;
    return ActiveStyle(font: ActiveStyleItem.fromJson(j['font']), wallpaper: ActiveStyleItem.fromJson(j['wallpaper']), chatTheme: ActiveStyleItem.fromJson(j['chatTheme']), callTheme: ActiveStyleItem.fromJson(j['callTheme']));
  }
  Map<String, dynamic> toJson() => {'font': font?.toJson(), 'wallpaper': wallpaper?.toJson(), 'chatTheme': chatTheme?.toJson(), 'callTheme': callTheme?.toJson()};
  String encode() => jsonEncode(toJson());

  ActiveStyleItem? slot(StyleType t) => switch (t) { StyleType.font => font, StyleType.wallpaper => wallpaper, StyleType.chatTheme => chatTheme, StyleType.callTheme => callTheme };
  ActiveStyle withSlot(StyleType t, ActiveStyleItem? v) => ActiveStyle(
        font: t == StyleType.font ? v : font,
        wallpaper: t == StyleType.wallpaper ? v : wallpaper,
        chatTheme: t == StyleType.chatTheme ? v : chatTheme,
        callTheme: t == StyleType.callTheme ? v : callTheme,
      );
}

/// GET /premium/status
class PremiumStatus {
  const PremiumStatus({required this.config, required this.coins, required this.status, required this.quota, required this.style, this.unlockedStyles = const [], this.styleCount = 0});
  final ProConfig config;
  final int coins;
  final ProStatus status;
  final MatchQuota quota;
  final ActiveStyle style;
  final List<String> unlockedStyles;
  final int styleCount;

  factory PremiumStatus.fromJson(Map<String, dynamic> j) => PremiumStatus(
        config: ProConfig.fromJson(_map(j['config'])),
        coins: _int(j['coins']),
        status: ProStatus.fromJson(_map(j['premium'])),
        quota: MatchQuota.fromJson(_map(j['quota'])),
        style: ActiveStyle.fromJson(_map(j['style'])),
        unlockedStyles: (j['unlockedStyles'] is List) ? (j['unlockedStyles'] as List).map((e) => e.toString()).toList() : const [],
        styleCount: _int(j['styleCount']),
      );
}

/// GET /premium/studio
class StudioCatalog {
  const StudioCatalog({required this.enabled, required this.pro, required this.coins, required this.status, required this.items, required this.keys});
  final bool enabled;
  final bool pro;
  final int coins;
  final ProStatus status;
  final List<StyleItem> items;
  final Map<String, String> keys; // slot → applied key

  factory StudioCatalog.fromJson(Map<String, dynamic> j) => StudioCatalog(
        enabled: _bool(j['enabled'], true),
        pro: _bool(j['pro']),
        coins: _int(j['coins']),
        status: ProStatus.fromJson(_map(j['premium'])),
        items: (j['items'] is List) ? (j['items'] as List).map((e) => StyleItem.fromJson(_map(e))).whereType<StyleItem>().toList() : const [],
        keys: _map(j['style']).map((k, v) => MapEntry(k, _str(v))),
      );
}

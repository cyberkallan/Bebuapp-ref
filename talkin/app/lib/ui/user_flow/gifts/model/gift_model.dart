import 'package:flutter/material.dart';

/// One gift from the admin catalog.
class GiftItem {
  const GiftItem({
    required this.id,
    required this.key,
    required this.name,
    required this.tagline,
    required this.image,
    required this.accent,
    required this.coins,
    required this.sortOrder,
  });

  final String id;
  final String key;
  final String name;
  final String tagline;
  final String image;
  final Color accent;
  final int coins;
  final int sortOrder;

  /// Premium gifts get a richer presentation (glow, badge) in the sheet.
  bool get isPremium => coins >= 500;

  static Color parseAccent(dynamic v, [Color fallback = const Color(0xFFFF4D6D)]) {
    final s = v?.toString().replaceAll('#', '') ?? '';
    if (s.length != 6) return fallback;
    final n = int.tryParse(s, radix: 16);
    return n == null ? fallback : Color(0xFF000000 | n);
  }

  factory GiftItem.fromJson(Map<String, dynamic> j) => GiftItem(
        id: j['_id']?.toString() ?? '',
        key: j['key']?.toString() ?? '',
        name: j['name']?.toString() ?? 'Gift',
        tagline: j['tagline']?.toString() ?? '',
        image: j['image']?.toString() ?? '',
        accent: parseAccent(j['accent']),
        coins: (j['coins'] is num) ? (j['coins'] as num).toInt() : int.tryParse(j['coins']?.toString() ?? '') ?? 0,
        sortOrder: (j['sortOrder'] is num) ? (j['sortOrder'] as num).toInt() : 0,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'key': key,
        'name': name,
        'tagline': tagline,
        'image': image,
        'accent': '#${accent.toARGB32().toRadixString(16).substring(2)}',
        'coins': coins,
        'sortOrder': sortOrder,
      };
}

/// What `/gift/list` returns: the on/off switches plus the catalog.
class GiftCatalog {
  const GiftCatalog({required this.enabled, required this.showInChat, required this.showInCall, required this.minBalanceHint, required this.gifts});

  final bool enabled;
  final bool showInChat;
  final bool showInCall;
  final bool minBalanceHint;
  final List<GiftItem> gifts;

  static const off = GiftCatalog(enabled: false, showInChat: false, showInCall: false, minBalanceHint: false, gifts: []);

  factory GiftCatalog.fromJson(Map<String, dynamic> j) => GiftCatalog(
        enabled: j['enabled'] == true,
        showInChat: j['showInChat'] == true,
        showInCall: j['showInCall'] == true,
        minBalanceHint: j['minBalanceHint'] != false,
        gifts: (j['gifts'] as List? ?? const []).whereType<Map>().map((e) => GiftItem.fromJson(Map<String, dynamic>.from(e))).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      );
}

/// Snapshot of a gift stored on a chat message (messageType 6). Parsed from
/// either the nested `gift` object (REST history) or the flat `giftName`...
/// keys the socket payload carries.
class GiftSnapshot {
  const GiftSnapshot({required this.id, required this.name, required this.image, required this.accent, required this.coins});

  final String id;
  final String name;
  final String image;
  final Color accent;
  final int coins;

  static GiftSnapshot? tryParse(Map<String, dynamic> j) {
    final nested = j['gift'];
    if (nested is Map && (nested['name'] != null || nested['image'] != null)) {
      final m = Map<String, dynamic>.from(nested);
      return GiftSnapshot(
        id: m['giftId']?.toString() ?? '',
        name: m['name']?.toString() ?? 'Gift',
        image: m['image']?.toString() ?? '',
        accent: GiftItem.parseAccent(m['accent']),
        coins: (m['coins'] is num) ? (m['coins'] as num).toInt() : int.tryParse(m['coins']?.toString() ?? '') ?? 0,
      );
    }
    if (j['giftName'] != null || j['giftImage'] != null) {
      return GiftSnapshot(
        id: j['giftId']?.toString() ?? '',
        name: j['giftName']?.toString() ?? 'Gift',
        image: j['giftImage']?.toString() ?? '',
        accent: GiftItem.parseAccent(j['giftAccent']),
        coins: (j['giftCoins'] is num) ? (j['giftCoins'] as num).toInt() : int.tryParse(j['giftCoins']?.toString() ?? '') ?? 0,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'giftId': id, 'name': name, 'image': image, 'coins': coins};
}

/// Result of `/gift/send`.
class GiftSendResult {
  const GiftSendResult({required this.ok, this.message = '', this.balance, this.hostCoins = 0, this.insufficient = false, this.need = 0, this.chatMessage, this.chatTopicId});

  final bool ok;
  final String message;
  final int? balance;
  final int hostCoins;
  final bool insufficient;
  final int need;
  final Map<String, dynamic>? chatMessage;
  final String? chatTopicId;
}

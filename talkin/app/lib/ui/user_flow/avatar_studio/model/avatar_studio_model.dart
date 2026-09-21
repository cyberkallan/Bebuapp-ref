import 'package:flutter/material.dart';

/// The slots a look is made of. Order = tab order in the studio.
enum StudioSlot { avatar, background, accessory, pet, vehicle, home, sky }

extension StudioSlotX on StudioSlot {
  String get key => name;

  String get label => switch (this) {
        StudioSlot.avatar => 'Avatar',
        StudioSlot.background => 'Scene',
        StudioSlot.accessory => 'Style',
        StudioSlot.pet => 'Pet',
        StudioSlot.vehicle => 'Ride',
        StudioSlot.home => 'Home',
        StudioSlot.sky => 'Sky',
      };

  /// Bundled icon shown on the category tab.
  String get iconKey => switch (this) {
        StudioSlot.avatar => 'm_hero',
        StudioSlot.background => 'bg_galaxy',
        StudioSlot.accessory => 'acc_crown',
        StudioSlot.pet => 'pet_dog',
        StudioSlot.vehicle => 'veh_race',
        StudioSlot.home => 'home_villa',
        StudioSlot.sky => 'sky_jet',
      };

  static StudioSlot? parse(String? s) {
    for (final v in StudioSlot.values) {
      if (v.name == s) return v;
    }
    return null;
  }
}

enum Rarity { common, rare, epic, legendary }

extension RarityX on Rarity {
  String get label => switch (this) {
        Rarity.common => 'Common',
        Rarity.rare => 'Rare',
        Rarity.epic => 'Epic',
        Rarity.legendary => 'Legendary',
      };

  Color get color => switch (this) {
        Rarity.common => const Color(0xFF9CA3AF),
        Rarity.rare => const Color(0xFF38BDF8),
        Rarity.epic => const Color(0xFFA855F7),
        Rarity.legendary => const Color(0xFFFBBF24),
      };

  Gradient get gradient => switch (this) {
        Rarity.common => const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)]),
        Rarity.rare => const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF67E8F9)]),
        Rarity.epic => const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
        Rarity.legendary => const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFDE68A), Color(0xFFF59E0B)]),
      };

  static Rarity parse(String? s) {
    for (final v in Rarity.values) {
      if (v.name == s) return v;
    }
    return Rarity.common;
  }
}

class AvatarItem {
  AvatarItem({
    required this.id,
    required this.key,
    required this.slot,
    required this.name,
    required this.image,
    required this.coins,
    required this.rarity,
    required this.gender,
    required this.colors,
    this.sortOrder = 0,
  });

  final String id;
  final String key;
  final StudioSlot slot;
  final String name;
  final String image; // server-relative path (fallback when not bundled)
  final int coins;
  final Rarity rarity;
  final String gender; // any | male | female
  final List<Color> colors; // background gradient
  final int sortOrder;

  bool get isFree => coins <= 0;

  factory AvatarItem.fromJson(Map<String, dynamic> j) {
    final slot = StudioSlotX.parse(j['category']?.toString()) ?? StudioSlot.accessory;
    final colors = <Color>[];
    for (final c in (j['colors'] as List? ?? const [])) {
      final hex = c.toString().replaceFirst('#', '');
      if (hex.length == 6) colors.add(Color(int.parse('FF$hex', radix: 16)));
    }
    return AvatarItem(
      id: j['_id']?.toString() ?? '',
      key: j['key']?.toString() ?? '',
      slot: slot,
      name: j['name']?.toString() ?? '',
      image: j['image']?.toString() ?? '',
      coins: (j['coins'] is num) ? (j['coins'] as num).toInt() : int.tryParse('${j['coins']}') ?? 0,
      rarity: RarityX.parse(j['rarity']?.toString()),
      gender: j['gender']?.toString() ?? 'any',
      colors: colors,
      sortOrder: (j['sortOrder'] is num) ? (j['sortOrder'] as num).toInt() : 0,
    );
  }
}

class StudioSettings {
  const StudioSettings({this.enabled = true, this.allowPhotoUpload = true});
  final bool enabled;
  final bool allowPhotoUpload;

  factory StudioSettings.fromJson(Map<String, dynamic>? j) =>
      StudioSettings(enabled: j?['enabled'] != false, allowPhotoUpload: j?['allowPhotoUpload'] != false);
}

/// Everything `/api/user/avatar/studio` returns.
class StudioData {
  StudioData({
    required this.settings,
    required this.coins,
    required this.gender,
    required this.profilePic,
    required this.active,
    required this.equipped,
    required this.unlocked,
    required this.items,
    required this.presetsMale,
    required this.presetsFemale,
  });

  final StudioSettings settings;
  int coins;
  final String gender;
  final String profilePic;
  bool active;
  final Map<StudioSlot, String?> equipped;
  final Set<String> unlocked;
  final List<AvatarItem> items;
  final List<AvatarItem> presetsMale;
  final List<AvatarItem> presetsFemale;

  AvatarItem? byId(String? id) {
    if (id == null) return null;
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  factory StudioData.fromJson(Map<String, dynamic> j) {
    final eq = <StudioSlot, String?>{};
    final rawEq = (j['equipped'] as Map?) ?? const {};
    for (final s in StudioSlot.values) {
      final v = rawEq[s.key];
      eq[s] = v == null || v.toString().isEmpty ? null : v.toString();
    }
    List<AvatarItem> parseList(dynamic l) => (l as List? ?? const []).map((e) => AvatarItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    final presets = (j['presets'] as Map?) ?? const {};
    return StudioData(
      settings: StudioSettings.fromJson((j['settings'] as Map?)?.cast<String, dynamic>()),
      coins: (j['coins'] is num) ? (j['coins'] as num).toInt() : int.tryParse('${j['coins']}') ?? 0,
      gender: j['gender']?.toString() ?? '',
      profilePic: j['profilePic']?.toString() ?? '',
      active: j['active'] == true,
      equipped: eq,
      unlocked: ((j['unlocked'] as List?) ?? const []).map((e) => e.toString()).toSet(),
      items: parseList(j['items']),
      presetsMale: parseList(presets['male']),
      presetsFemale: parseList(presets['female']),
    );
  }
}

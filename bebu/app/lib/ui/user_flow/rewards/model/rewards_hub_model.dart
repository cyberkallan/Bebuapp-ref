import 'package:talk_in/ui/user_flow/daily_reward/model/daily_reward_model.dart';

int _int(dynamic v, [int d = 0]) => v is num ? v.toInt() : int.tryParse('$v') ?? d;
bool _bool(dynamic v, [bool d = false]) => v is bool ? v : (v == null ? d : '$v' == 'true');
Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : const {};

/// One step of the "complete your profile" checklist.
class ProfileStep {
  const ProfileStep({required this.key, required this.label, required this.done});
  final String key;
  final String label;
  final bool done;

  factory ProfileStep.fromJson(Map<String, dynamic> j) => ProfileStep(key: '${j['key'] ?? ''}', label: '${j['label'] ?? ''}', done: _bool(j['done']));
}

class ProfileReward {
  const ProfileReward({required this.enabled, required this.coins, required this.claimed, required this.canClaim, required this.steps});
  final bool enabled;
  final int coins;
  final bool claimed;
  final bool canClaim;
  final List<ProfileStep> steps;

  int get done => steps.where((s) => s.done).length;
  int get total => steps.length;
  double get progress => total == 0 ? 0 : done / total;

  factory ProfileReward.fromJson(Map<String, dynamic> j) => ProfileReward(
        enabled: _bool(j['enabled'], true),
        coins: _int(j['coins']),
        claimed: _bool(j['claimed']),
        canClaim: _bool(j['canClaim']),
        steps: [for (final s in (j['checklist'] as List? ?? const [])) ProfileStep.fromJson(_map(s))],
      );

  ProfileReward copyWith({bool? claimed, bool? canClaim}) => ProfileReward(enabled: enabled, coins: coins, claimed: claimed ?? this.claimed, canClaim: canClaim ?? this.canClaim, steps: steps);
}

class ReferralReward {
  const ReferralReward({
    required this.enabled,
    required this.code,
    required this.shareUrl,
    required this.inviterCoins,
    required this.inviteeCoins,
    required this.purchaseSharePercent,
    required this.firstPurchaseOnly,
    required this.codeWindowDays,
    required this.canEnterCode,
    required this.applied,
    required this.invited,
    required this.purchases,
    required this.earnedCoins,
  });

  final bool enabled;
  final String code;
  final String shareUrl;
  final int inviterCoins;
  final int inviteeCoins;
  final int purchaseSharePercent;
  final bool firstPurchaseOnly;
  final int codeWindowDays;
  final bool canEnterCode;
  final bool applied;
  final int invited;
  final int purchases;
  final int earnedCoins;

  factory ReferralReward.fromJson(Map<String, dynamic> j) {
    final s = _map(j['stats']);
    return ReferralReward(
      enabled: _bool(j['enabled'], true),
      code: '${j['code'] ?? ''}',
      shareUrl: '${j['shareUrl'] ?? ''}',
      inviterCoins: _int(j['inviterCoins']),
      inviteeCoins: _int(j['inviteeCoins']),
      purchaseSharePercent: _int(j['purchaseSharePercent']),
      firstPurchaseOnly: _bool(j['firstPurchaseOnly'], true),
      codeWindowDays: _int(j['codeWindowDays'], 7),
      canEnterCode: _bool(j['canEnterCode']),
      applied: _bool(j['applied']),
      invited: _int(s['invited']),
      purchases: _int(s['purchases']),
      earnedCoins: _int(s['earnedCoins']),
    );
  }

  ReferralReward copyWith({bool? canEnterCode, bool? applied}) => ReferralReward(
        enabled: enabled,
        code: code,
        shareUrl: shareUrl,
        inviterCoins: inviterCoins,
        inviteeCoins: inviteeCoins,
        purchaseSharePercent: purchaseSharePercent,
        firstPurchaseOnly: firstPurchaseOnly,
        codeWindowDays: codeWindowDays,
        canEnterCode: canEnterCode ?? this.canEnterCode,
        applied: applied ?? this.applied,
        invited: invited,
        purchases: purchases,
        earnedCoins: earnedCoins,
      );
}

class AvatarBonusRule {
  const AvatarBonusRule({required this.enabled, required this.percent, required this.minCoins, required this.maxCoins, this.earned = 0});
  final bool enabled;
  final int percent;
  final int minCoins;
  final int maxCoins;
  final int earned;

  static const off = AvatarBonusRule(enabled: false, percent: 0, minCoins: 0, maxCoins: 0);

  factory AvatarBonusRule.fromJson(Map<String, dynamic> j) => AvatarBonusRule(
        enabled: _bool(j['enabled'], true),
        percent: _int(j['percent']),
        minCoins: _int(j['minCoins']),
        maxCoins: _int(j['maxCoins']),
        earned: _int(j['earned']),
      );

  /// Mirrors the server formula so tiles can show the bonus before buying.
  int bonusFor(int price) {
    if (!enabled || price <= 0 || maxCoins <= 0) return 0;
    final raw = (price * percent / 100).round();
    return raw.clamp(minCoins, maxCoins);
  }
}

/// Everything the Earn coins screen shows, from `GET /user/rewards/hub`.
class RewardsHub {
  const RewardsHub({required this.balance, required this.daily, required this.profile, required this.referral, required this.avatarBonus});
  final int balance;
  final DailyRewardStatus? daily;
  final ProfileReward profile;
  final ReferralReward referral;
  final AvatarBonusRule avatarBonus;

  factory RewardsHub.fromJson(Map<String, dynamic> j) {
    DailyRewardStatus? daily;
    try {
      if (j['daily'] is Map) daily = DailyRewardStatus.fromJson(_map(j['daily']));
    } catch (_) {}
    return RewardsHub(
      balance: _int(j['balance']),
      daily: daily,
      profile: ProfileReward.fromJson(_map(j['profile'])),
      referral: ReferralReward.fromJson(_map(j['referral'])),
      avatarBonus: AvatarBonusRule.fromJson(_map(j['avatarBonus'])),
    );
  }

  RewardsHub copyWith({int? balance, ProfileReward? profile, ReferralReward? referral}) =>
      RewardsHub(balance: balance ?? this.balance, daily: daily, profile: profile ?? this.profile, referral: referral ?? this.referral, avatarBonus: avatarBonus);
}

/// A coin reward the server just granted; drives [RewardBlast].
class GrantedReward {
  const GrantedReward({required this.kind, required this.coins, this.balance, this.title, this.subtitle});
  final String kind; // profile | referral | avatarBonus | custom
  final int coins;
  final int? balance;
  final String? title;
  final String? subtitle;

  static GrantedReward? fromJson(dynamic v) {
    if (v is! Map) return null;
    final j = Map<String, dynamic>.from(v);
    final coins = _int(j['coins']);
    if (coins <= 0) return null;
    return GrantedReward(kind: '${j['type'] ?? 'custom'}', coins: coins, balance: j['balance'] is num ? (j['balance'] as num).toInt() : null);
  }
}

/// Snapshot of the daily streak reward for the signed-in user.
class DailyRewardStatus {
  const DailyRewardStatus({
    required this.enabled,
    required this.canClaim,
    required this.claimedToday,
    required this.streak,
    required this.day,
    required this.coins,
    required this.nextCoins,
    required this.schedule,
    required this.nextClaimAt,
    this.bestStreak = 0,
    this.totalClaims = 0,
    this.autoOpen = true,
    this.balance,
    this.claimed,
    this.error,
  });

  final bool enabled;
  final bool canClaim;
  final bool claimedToday;

  /// Streak length including today's (claimable or claimed) reward.
  final int streak;

  /// 1-based position in [schedule] for today's reward.
  final int day;

  /// Coins for today's reward.
  final int coins;

  /// Coins waiting tomorrow (the curiosity hook).
  final int nextCoins;
  final List<int> schedule;
  final DateTime nextClaimAt;
  final int bestStreak;
  final int totalClaims;
  final bool autoOpen;

  /// Wallet balance after the request, when the server returned it.
  final int? balance;

  /// Coins just credited by a successful claim.
  final int? claimed;

  /// Set when a claim was refused; the other fields describe the current state.
  final String? error;

  bool get ok => error == null;

  factory DailyRewardStatus.fromJson(Map<String, dynamic> j) {
    final sched = j['schedule'] is List ? (j['schedule'] as List).map((e) => (e as num).toInt()).toList() : const <int>[];
    return DailyRewardStatus(
      enabled: j['enabled'] != false,
      canClaim: j['canClaim'] == true,
      claimedToday: j['claimedToday'] == true,
      streak: (j['streak'] as num?)?.toInt() ?? 1,
      day: (j['day'] as num?)?.toInt() ?? 1,
      coins: (j['coins'] as num?)?.toInt() ?? 0,
      nextCoins: (j['nextCoins'] as num?)?.toInt() ?? 0,
      schedule: sched.isEmpty ? const [10, 15, 20, 25, 30, 40, 60] : sched,
      nextClaimAt: DateTime.tryParse(j['nextClaimAt']?.toString() ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
      bestStreak: (j['bestStreak'] as num?)?.toInt() ?? 0,
      totalClaims: (j['totalClaims'] as num?)?.toInt() ?? 0,
      autoOpen: j['autoOpen'] != false,
      balance: (j['balance'] as num?)?.toInt(),
      claimed: (j['claimed'] as num?)?.toInt(),
    );
  }

  factory DailyRewardStatus.failed(String message, {Map<String, dynamic>? fallback}) {
    final base = fallback == null ? null : DailyRewardStatus.fromJson(fallback);
    return DailyRewardStatus(
      enabled: base?.enabled ?? true,
      canClaim: base?.canClaim ?? false,
      claimedToday: base?.claimedToday ?? false,
      streak: base?.streak ?? 1,
      day: base?.day ?? 1,
      coins: base?.coins ?? 0,
      nextCoins: base?.nextCoins ?? 0,
      schedule: base?.schedule ?? const [10, 15, 20, 25, 30, 40, 60],
      nextClaimAt: base?.nextClaimAt ?? DateTime.now().add(const Duration(hours: 24)),
      bestStreak: base?.bestStreak ?? 0,
      totalClaims: base?.totalClaims ?? 0,
      autoOpen: base?.autoOpen ?? true,
      balance: base?.balance,
      error: message,
    );
  }

  DailyRewardStatus copyWith({bool? canClaim, bool? claimedToday, int? balance}) => DailyRewardStatus(
        enabled: enabled,
        canClaim: canClaim ?? this.canClaim,
        claimedToday: claimedToday ?? this.claimedToday,
        streak: streak,
        day: day,
        coins: coins,
        nextCoins: nextCoins,
        schedule: schedule,
        nextClaimAt: nextClaimAt,
        bestStreak: bestStreak,
        totalClaims: totalClaims,
        autoOpen: autoOpen,
        balance: balance ?? this.balance,
        claimed: claimed,
        error: error,
      );
}

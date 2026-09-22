import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/daily_reward/api/daily_reward_api.dart';
import 'package:talk_in/ui/user_flow/daily_reward/model/daily_reward_model.dart';
import 'package:talk_in/ui/user_flow/daily_reward/view/daily_reward_sheet.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

/// App-wide daily reward state: knows whether a gift is waiting, opens the
/// claim sheet (once per day automatically), and keeps the coin balance in
/// sync after a claim. Registered once with `Get.put(..., permanent: true)`.
class DailyRewardController extends GetxController {
  static const idBadge = 'dailyRewardBadge';
  static const _autoKey = 'dailyRewardAutoOpenedFor';
  static const _welcomeKey = 'dailyRewardPendingWelcome';

  DailyRewardStatus? status;
  bool loading = false;
  bool _sheetOpen = false;

  static DailyRewardController get to => Get.isRegistered<DailyRewardController>() ? Get.find<DailyRewardController>() : Get.put(DailyRewardController(), permanent: true);

  bool get canClaim => status?.canClaim == true;
  bool get enabled => status?.enabled != false;

  /// Set right after a brand-new account is created so the first reward sheet
  /// can also celebrate the welcome bonus.
  static void markWelcomePending() => Database.localStorage.write(_welcomeKey, true);
  bool get welcomePending => Database.localStorage.read(_welcomeKey) == true;
  void consumeWelcome() => Database.localStorage.remove(_welcomeKey);

  Future<DailyRewardStatus?> load() async {
    if (Database.loginUserFirebaseId.isEmpty) return null;
    loading = true;
    update([idBadge]);
    status = await DailyRewardApi.status();
    loading = false;
    update([idBadge]);
    return status;
  }

  /// Fetches the status and pops the sheet if a reward is waiting and it has
  /// not been shown automatically for this reward window yet.
  Future<void> checkAndMaybeOpen() async {
    final s = await load();
    if (s == null || !s.enabled || !s.canClaim) return;
    final windowKey = s.nextClaimAt.toIso8601String();
    final shownFor = Database.localStorage.read(_autoKey);
    if (!s.autoOpen && !welcomePending) return;
    if (shownFor == windowKey) return;
    Database.localStorage.write(_autoKey, windowKey);
    // Let the home deck settle first so the sheet feels like a reveal, not a blocker.
    await Future.delayed(const Duration(milliseconds: 650));
    await open();
  }

  /// Opens the sheet over whatever is on screen (uses the root navigator).
  Future<void> open([BuildContext? context]) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    try {
      status ??= await DailyRewardApi.status();
      final ctx = context ?? Get.context;
      if (ctx == null || !ctx.mounted) return;
      await DailyRewardSheet.show(ctx, this);
    } finally {
      _sheetOpen = false;
    }
  }

  Future<DailyRewardStatus> claim() async {
    final result = await DailyRewardApi.claim();
    if (result.ok || result.claimedToday) {
      status = result.ok ? result : result.copyWith(canClaim: false);
      if (result.balance != null) {
        Database.onSetUserCoin(result.balance.toString());
        if (Get.isRegistered<HomeScreenController>()) Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
      }
      update([idBadge]);
    }
    return result;
  }

  /// Time left until the next reward window opens, clamped at zero.
  Duration get untilNext {
    final at = status?.nextClaimAt;
    if (at == null) return Duration.zero;
    final d = at.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }
}

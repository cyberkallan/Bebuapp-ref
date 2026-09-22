import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/rewards/api/rewards_api.dart';
import 'package:talk_in/ui/user_flow/rewards/model/rewards_hub_model.dart';
import 'package:talk_in/ui/user_flow/rewards/view/reward_blast.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

/// Earn-coins hub state: profile completion, invite friends, avatar bonus.
/// Also the single place that turns a server-granted reward into a wallet
/// update plus the celebration overlay, so every entry point behaves alike.
class RewardsController extends GetxController {
  static const idHub = 'rewardsHub';

  RewardsHub? hub;
  bool loading = false;
  bool claiming = false;
  bool applying = false;
  String? error;

  static RewardsController get to => Get.isRegistered<RewardsController>() ? Get.find<RewardsController>() : Get.put(RewardsController(), permanent: true);

  /// Bonus rule for the Avatar Studio tiles; falls back to "off" until loaded.
  AvatarBonusRule get avatarBonus => hub?.avatarBonus ?? AvatarBonusRule.off;

  /// Number of tasks with something to collect right now (badge count).
  int get pendingCount {
    final h = hub;
    if (h == null) return 0;
    var n = 0;
    if (h.daily?.canClaim == true) n++;
    if (h.profile.enabled && h.profile.canClaim) n++;
    return n;
  }

  Future<RewardsHub?> load() async {
    if (Database.loginUserFirebaseId.isEmpty) return null;
    loading = true;
    error = null;
    update([idHub]);
    final h = await RewardsApi.hub();
    if (h == null) {
      error = 'Could not load rewards. Pull to retry.';
    } else {
      hub = h;
    }
    loading = false;
    update([idHub]);
    return h;
  }

  Future<RewardResult> claimProfile(BuildContext context) async {
    if (claiming) return const RewardResult(ok: false);
    claiming = true;
    update([idHub]);
    final r = await RewardsApi.claimProfile();
    claiming = false;
    if (r.ok && r.reward != null) {
      hub = hub?.copyWith(profile: hub!.profile.copyWith(claimed: true, canClaim: false), balance: r.reward!.balance ?? hub!.balance);
      if (context.mounted) celebrate(context, r.reward!);
    } else if (r.code == 'CLAIMED') {
      hub = hub?.copyWith(profile: hub!.profile.copyWith(claimed: true, canClaim: false));
    } else {
      Sfx.deny();
    }
    update([idHub]);
    return r;
  }

  Future<RewardResult> applyReferral(BuildContext context, String code) async {
    if (applying) return const RewardResult(ok: false);
    applying = true;
    update([idHub]);
    final r = await RewardsApi.applyReferral(code);
    applying = false;
    if (r.ok) {
      hub = hub?.copyWith(referral: hub!.referral.copyWith(applied: true, canEnterCode: false), balance: r.balance ?? hub!.balance);
      if (r.reward != null) {
        if (context.mounted) celebrate(context, r.reward!);
      } else {
        Sfx.pop();
      }
    } else {
      Sfx.deny();
    }
    update([idHub]);
    return r;
  }

  String shareText() {
    final ref = hub?.referral;
    if (ref == null || ref.code.isEmpty) return '';
    final bonus = ref.inviteeCoins > 0 ? ' You get ${ref.inviteeCoins} coins on your first sign-in.' : '';
    final link = ref.shareUrl.isNotEmpty ? '\n${ref.shareUrl}' : '';
    return 'Join me on bebu — voice & video calls with real people. Use my invite code ${ref.code} when you sign up.$bonus$link';
  }

  Future<void> share(BuildContext context) async {
    final text = shareText();
    if (text.isEmpty) return;
    Sfx.lightTap();
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      text: text,
      subject: 'Join me on bebu',
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  Future<void> copyCode() async {
    final code = hub?.referral.code ?? '';
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    Sfx.tick();
  }

  /// Syncs the wallet balance everywhere and plays the celebration.
  void celebrate(BuildContext context, GrantedReward reward) {
    if (reward.balance != null) setBalance(reward.balance!);
    RewardBlast.show(context, reward);
  }

  void setBalance(int balance) {
    Database.onSetUserCoin(balance.toString());
    if (Get.isRegistered<HomeScreenController>()) Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
    if (hub != null) hub = hub!.copyWith(balance: balance);
    update([idHub]);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/premium/api/premium_api.dart';
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/ui/user_flow/premium/view/pro_widgets.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/pro.dart';
import 'package:talk_in/utils/utils.dart';

/// bebu Pro screen state: passes, entitlement, quota, badge switch.
class PremiumController extends GetxController {
  static const idPro = 'proScreen';

  PremiumStatus? data;
  bool loading = false;
  bool buying = false;
  String? error;
  String? selectedPass;

  static PremiumController get to => Get.isRegistered<PremiumController>() ? Get.find<PremiumController>() : Get.put(PremiumController(), permanent: true);

  List<ProPass> get passes => data?.config.passes ?? Pro.config.passes;
  ProPass? get selected => passes.firstWhereOrNull((p) => p.key == selectedPass) ?? _defaultPass();

  ProPass? _defaultPass() {
    if (passes.isEmpty) return null;
    return passes.firstWhereOrNull((p) => p.badge.toLowerCase().contains('popular')) ?? passes[passes.length > 1 ? 1 : 0];
  }

  Future<PremiumStatus?> load() async {
    if (Database.loginUserFirebaseId.isEmpty) return null;
    loading = true;
    error = null;
    update([idPro]);
    final s = await PremiumApi.status();
    if (s == null) {
      error = 'Could not load ${Pro.name}. Pull to retry.';
    } else {
      data = s;
      Pro.rememberConfig(s.config.toJson());
      Pro.rememberStatus(s.status);
      Pro.rememberStyle(s.style);
      _syncCoins(s.coins);
      selectedPass ??= _defaultPass()?.key;
    }
    loading = false;
    update([idPro]);
    return s;
  }

  void select(String key) {
    if (selectedPass == key) return;
    selectedPass = key;
    Sfx.tick();
    update([idPro]);
  }

  /// Buy the selected pass. Handles the low-balance path with a top-up prompt.
  Future<bool> buy(BuildContext context) async {
    final pass = selected;
    if (pass == null || buying) return false;
    final coins = int.tryParse(Database.userCoin) ?? data?.coins ?? 0;
    if (coins < pass.coins) {
      Sfx.deny();
      final go = await _confirm(context, title: 'Not enough coins', body: 'You need ${pass.coins - coins} more coins for ${pass.name}.', action: 'Top up');
      if (go) Get.toNamed(AppRoutes.coinPurchaseScreen);
      return false;
    }
    final ok = await _confirm(context, title: 'Unlock ${pass.name}?', body: '${pass.coins} coins will be taken from your wallet. ${pass.lifetime ? 'Pro never expires.' : 'Pro runs for ${pass.durationLabel}${Pro.isActive ? ', added to your current pass' : ''}.'}', action: 'Unlock');
    if (!ok) return false;

    buying = true;
    update([idPro]);
    final r = await PremiumApi.buy(pass.key);
    buying = false;
    if (!r.ok) {
      update([idPro]);
      if (r.code == 'INSUFFICIENT_COINS') {
        if (context.mounted) {
          final go = await _confirm(context, title: 'Not enough coins', body: 'You need ${r.need ?? pass.coins} more coins.', action: 'Top up');
          if (go) Get.toNamed(AppRoutes.coinPurchaseScreen);
        }
      } else if (context.mounted) {
        Utils.showToast(context, r.message.isEmpty ? 'Could not activate the pass.' : r.message);
      }
      return false;
    }
    final st = r.status;
    if (st != null) Pro.rememberStatus(st);
    if (r.coins != null) _syncCoins(r.coins!);
    update([idPro]);
    if (context.mounted) {
      await ProBlast.show(context, passName: pass.name, untilLabel: st == null ? '' : untilLabel(st));
    }
    load();
    return true;
  }

  Future<void> setBadge(bool on) async {
    Pro.rememberStatus(Pro.status.copyWith(badge: on, showBadge: on && Pro.status.active));
    update([idPro]);
    Sfx.tick();
    final r = await PremiumApi.badge(on);
    if (r.ok && r.status != null) {
      Pro.rememberStatus(r.status!);
    } else if (!r.ok) {
      Pro.rememberStatus(Pro.status.copyWith(badge: !on));
    }
    update([idPro]);
  }

  void _syncCoins(int coins) {
    Database.onSetUserCoin(coins.toString());
    if (Get.isRegistered<HomeScreenController>()) Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
  }

  static String untilLabel(ProStatus s) {
    if (!s.active) return 'Not active';
    if (s.lifetime) return 'Lifetime — never expires';
    final u = s.until;
    if (u == null) return 'Active';
    final left = u.difference(DateTime.now());
    if (left.inHours < 24) return 'Ends in ${left.inHours.clamp(1, 23)} h';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Active until ${u.day} ${months[u.month - 1]} ${u.year} · ${left.inDays} days left';
  }

  Future<bool> _confirm(BuildContext context, {required String title, required String body, required String action}) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Get.theme.brightness == Brightness.dark ? const Color(0xFF1A1A1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF5C451), foregroundColor: const Color(0xFF3B2A05)), onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
        ],
      ),
    );
    return r == true;
  }
}

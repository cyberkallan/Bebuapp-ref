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

/// Style Studio: browse wallpapers / fonts / chat themes / call screens,
/// preview one, unlock it with coins (or free with Pro) and apply it.
class StyleStudioController extends GetxController {
  static const idStudio = 'styleStudio';

  StudioCatalog? catalog;
  bool loading = false;
  bool busy = false;
  String? error;
  StyleType tab = StyleType.wallpaper;

  /// Item being previewed per tab (null = the applied one / default).
  final Map<StyleType, String?> preview = {};

  /// Key of the item just unlocked, for the celebration on its tile.
  String? justUnlocked;

  static StyleStudioController get to => Get.isRegistered<StyleStudioController>() ? Get.find<StyleStudioController>() : Get.put(StyleStudioController(), permanent: true);

  List<StyleItem> get items => catalog?.items.where((i) => i.type == tab).toList() ?? const [];
  bool get pro => catalog?.pro ?? Pro.isActive;
  int get coins => catalog?.coins ?? int.tryParse(Database.userCoin) ?? 0;

  /// Key applied on the server for a slot.
  String appliedKey(StyleType t) => catalog?.keys[t.apiName] ?? Pro.style.slot(t)?.key ?? '';

  StyleItem? byKey(String? key) => key == null || key.isEmpty ? null : catalog?.items.firstWhereOrNull((i) => i.key == key);

  /// The item shown in the preview panel for the current tab.
  StyleItem? get previewed => byKey(preview[tab] ?? appliedKey(tab));
  bool get previewingDefault => preview.containsKey(tab) && preview[tab] == null;

  Future<StudioCatalog?> load() async {
    if (Database.loginUserFirebaseId.isEmpty) return null;
    loading = true;
    error = null;
    update([idStudio]);
    final c = await PremiumApi.studio();
    if (c == null) {
      error = 'Could not load the Style Studio. Pull to retry.';
    } else {
      catalog = c;
      Pro.rememberStatus(c.status);
      _syncCoins(c.coins);
    }
    loading = false;
    update([idStudio]);
    return c;
  }

  void setTab(StyleType t) {
    if (tab == t) return;
    tab = t;
    Sfx.tick();
    update([idStudio]);
  }

  void select(StyleItem? item) {
    preview[tab] = item?.key;
    Sfx.lightTap();
    update([idStudio]);
  }

  /// Primary action for the previewed item: unlock, apply, or upsell.
  Future<void> primaryAction(BuildContext context) async {
    if (busy) return;
    final t = tab;
    final item = previewed;
    if (previewingDefault || item == null) {
      await _apply(context, t, '');
      return;
    }
    if (item.key == appliedKey(t) && !item.locked) return;
    if (item.locked) {
      if (item.proOnly && !pro) {
        await ProUpsellSheet.show(context, title: 'Made for ${Pro.name}', body: '${item.name} is a ${Pro.name} look. Members get three of each style free and unlock the rest with coins.', icon: t.icon);
        return;
      }
      if (item.price > 0 && coins < item.price) {
        Sfx.deny();
        if (!context.mounted) return;
        final go = await _confirm(context, title: 'Not enough coins', body: 'You need ${item.price - coins} more coins for ${item.name}.', action: 'Top up');
        if (go) Get.toNamed(AppRoutes.coinPurchaseScreen);
        return;
      }
      if (item.price > 0) {
        final ok = await _confirm(context, title: 'Unlock ${item.name}?', body: '${item.price} coins from your wallet. Yours to apply any time after.', action: 'Unlock');
        if (!ok) return;
      }
      busy = true;
      update([idStudio]);
      final r = await PremiumApi.unlock(item.key);
      busy = false;
      if (!r.ok) {
        update([idStudio]);
        if (r.code == 'PRO_REQUIRED' && context.mounted) {
          await ProUpsellSheet.show(context, title: 'Made for ${Pro.name}', body: r.message, icon: t.icon);
        } else if (r.code == 'INSUFFICIENT_COINS' && context.mounted) {
          final go = await _confirm(context, title: 'Not enough coins', body: 'You need ${r.need ?? item.price} more coins.', action: 'Top up');
          if (go) Get.toNamed(AppRoutes.coinPurchaseScreen);
        } else if (context.mounted) {
          Utils.showToast(context, r.message.isEmpty ? 'Could not unlock.' : r.message);
        }
        return;
      }
      if (r.coins != null) _syncCoins(r.coins!);
      _mark(item.key, owned: true);
      justUnlocked = item.key;
      Sfx.unlock();
      update([idStudio]);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (justUnlocked == item.key) {
          justUnlocked = null;
          update([idStudio]);
        }
      });
    }
    if (!context.mounted) return;
    await _apply(context, t, item.key);
  }

  Future<void> _apply(BuildContext context, StyleType t, String key) async {
    busy = true;
    update([idStudio]);
    final r = await PremiumApi.apply(t, key);
    busy = false;
    if (!r.ok) {
      update([idStudio]);
      if (context.mounted) Utils.showToast(context, r.message.isEmpty ? 'Could not apply.' : r.message);
      return;
    }
    catalog = catalog == null ? null : StudioCatalog(enabled: catalog!.enabled, pro: catalog!.pro, coins: catalog!.coins, status: catalog!.status, items: catalog!.items, keys: {...catalog!.keys, t.apiName: key});
    final style = r.style;
    if (style != null) {
      Pro.rememberStyle(style);
    } else {
      final it = byKey(key);
      Pro.setSlot(t, it == null ? null : ActiveStyleItem(key: it.key, name: it.name, image: it.image, thumb: it.thumb, data: it.data));
    }
    preview.remove(t);
    Sfx.pop();
    update([idStudio]);
  }

  void _mark(String key, {required bool owned}) {
    final c = catalog;
    if (c == null) return;
    catalog = StudioCatalog(enabled: c.enabled, pro: c.pro, coins: c.coins, status: c.status, keys: c.keys, items: c.items.map((i) => i.key == key ? i.copyWith(owned: owned, locked: !owned, price: 0) : i).toList());
  }

  void _syncCoins(int coins) {
    Database.onSetUserCoin(coins.toString());
    final c = catalog;
    if (c != null) catalog = StudioCatalog(enabled: c.enabled, pro: c.pro, coins: coins, status: c.status, items: c.items, keys: c.keys);
    if (Get.isRegistered<HomeScreenController>()) Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
  }

  Future<bool> _confirm(BuildContext context, {required String title, required String body, required String action}) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
        ],
      ),
    );
    return r == true;
  }
}

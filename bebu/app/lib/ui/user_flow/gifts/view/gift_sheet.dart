import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/gifts/controller/gift_controller.dart';
import 'package:talk_in/ui/user_flow/gifts/model/gift_model.dart';
import 'package:talk_in/ui/user_flow/gifts/view/gift_picture.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Gift picker. Grid of the admin catalog, live balance, one hero button.
/// A gift the user cannot afford is still selectable — the button turns into
/// "Get coins" so the path to the wallet is one tap, never a dead end.
class GiftSheet extends StatefulWidget {
  const GiftSheet({super.key, required this.target, this.onSent});

  final GiftTarget target;
  final void Function(GiftItem gift, GiftSendResult result)? onSent;

  static Future<void> show(BuildContext context, {required GiftTarget target, void Function(GiftItem gift, GiftSendResult result)? onSent}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.5 : 0.7),
      builder: (_) => GiftSheet(target: target, onSent: onSent),
    );
  }

  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> {
  final GiftController c = GiftController.to;
  GiftItem? selected;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final gifts = c.gifts;
    // Pre-select the cheapest gift so a single tap on the button already works.
    if (gifts.isNotEmpty) selected = gifts.reduce((a, b) => a.coins <= b.coins ? a : b);
    c.load();
  }

  bool get affordable => selected != null && c.balance >= selected!.coins;

  void _pick(GiftItem g) {
    if (sending) return;
    g.isPremium ? Sfx.select() : Sfx.tick();
    setState(() {
      selected = g;
      error = null;
    });
  }

  Future<void> _send() async {
    final g = selected;
    if (g == null || sending) return;
    if (!affordable) {
      Sfx.lightTap();
      Navigator.of(context).pop();
      Get.toNamed(AppRoutes.myWalletScreen);
      return;
    }
    setState(() {
      sending = true;
      error = null;
    });
    final result = await c.send(g, widget.target);
    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop();
      // The overlay lives in the root navigator, so it survives the pop.
      final overlayCtx = Get.overlayContext ?? Get.context;
      if (overlayCtx != null && overlayCtx.mounted) c.celebrate(overlayCtx, g, toName: widget.target.listenerName);
      widget.onSent?.call(g, result);
      return;
    }
    Sfx.deny();
    setState(() {
      sending = false;
      error = result.insufficient ? 'You need ${result.need} more coins for this one.' : result.message;
    });
    if (result.insufficient) c.load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 600 ? 5 : 4;
    return GetBuilder<GiftController>(
      id: GiftController.idCatalog,
      builder: (c) {
        final gifts = c.gifts;
        return Container(
          decoration: BoxDecoration(
            color: BebuTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)),
            border: Border(top: BorderSide(color: BebuTheme.borderStrong)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.textFaint.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Send a gift', style: BebuTheme.title(size: 20)),
                          const SizedBox(height: 2),
                          Text(
                            widget.target.listenerName.isEmpty ? 'Make their day' : 'Make ${widget.target.listenerName.split(' ').first}\'s day',
                            style: BebuTheme.body(size: 13, color: BebuTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _BalancePill(coins: c.balance, onTap: () {
                      Sfx.tick();
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.myWalletScreen);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (gifts.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                  child: c.loading
                      ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: BebuTheme.violet))
                      : Text('No gifts available right now.', style: BebuTheme.body(size: 14, color: BebuTheme.textMuted)),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.46),
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.74),
                    itemCount: gifts.length,
                    itemBuilder: (_, i) {
                      final g = gifts[i];
                      return _GiftTile(gift: g, selected: selected?.id == g.id, affordable: c.balance >= g.coins, onTap: () => _pick(g));
                    },
                  ),
                ),
              const SizedBox(height: 10),
              AnimatedSize(
                duration: BebuTheme.fast,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    error ?? (selected?.tagline.isNotEmpty == true ? selected!.tagline : 'Delivered instantly, right in your chat.'),
                    key: ValueKey(error ?? selected?.id),
                    textAlign: TextAlign.center,
                    style: BebuTheme.body(size: 12.5, color: error != null ? BebuTheme.red : BebuTheme.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GradientButton(
                  label: selected == null
                      ? 'Pick a gift'
                      : affordable
                          ? 'Send ${selected!.name}  ·  ${selected!.coins} coins'
                          : 'Get coins to send ${selected!.name}',
                  icon: affordable ? Icons.card_giftcard_rounded : Icons.add_circle_outline_rounded,
                  gradient: affordable ? BebuTheme.pinkGradient : BebuTheme.violetGradient,
                  glow: affordable ? BebuTheme.pink : BebuTheme.violet,
                  loading: sending,
                  onTap: selected == null ? null : _send,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.coins, required this.onTap});
  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
        decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
        child: Row(
          children: [
            const Coin3D(size: 18),
            const SizedBox(width: 6),
            Text(Utils.formatCompact(coins), style: BebuTheme.label(size: 13.5, color: BebuTheme.text)),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  const _GiftTile({required this.gift, required this.selected, required this.affordable, required this.onTap});
  final GiftItem gift;
  final bool selected;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = gift.accent;
    return PressScale(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: BebuTheme.isLight ? 0.12 : 0.18) : BebuTheme.surface,
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          border: Border.all(color: selected ? accent : BebuTheme.border, width: selected ? 1.6 : 1),
          boxShadow: selected ? [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    duration: BebuTheme.normal,
                    curve: Curves.easeOutBack,
                    scale: selected ? 1.12 : 1,
                    child: LayoutBuilder(builder: (_, box) => GiftPicture(image: gift.image, size: box.maxHeight, accent: accent, shadow: selected)),
                  ),
                  if (gift.isPremium)
                    Positioned(
                      top: -6,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(gradient: BebuTheme.violetGradient, borderRadius: BorderRadius.circular(6)),
                        child: Text('VIP', style: BebuTheme.label(size: 9, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(fit: BoxFit.scaleDown, child: Text(gift.name, maxLines: 1, style: BebuTheme.label(size: 11.5, color: BebuTheme.text))),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Coin3D(size: 11),
                const SizedBox(width: 3),
                Text(Utils.formatCompact(gift.coins), style: BebuTheme.label(size: 11, color: affordable ? BebuTheme.textMuted : BebuTheme.red.withValues(alpha: 0.9))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

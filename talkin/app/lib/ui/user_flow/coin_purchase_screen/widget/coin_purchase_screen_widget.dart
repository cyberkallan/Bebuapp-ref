import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/coin_burst.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/controller/coin_purchase_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// Big coin that drops in with a bounce, rings pulsing behind it, and the
/// "+N coins" headline counting up underneath.
class PurchaseHero extends StatefulWidget {
  const PurchaseHero({super.key});

  @override
  State<PurchaseHero> createState() => _PurchaseHeroState();
}

class _PurchaseHeroState extends State<PurchaseHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _scale = CurvedAnimation(parent: _c, curve: const Interval(0, 0.7, curve: Curves.elasticOut));
  late final Animation<double> _text = CurvedAnimation(parent: _c, curve: const Interval(0.45, 1, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (BebuTheme.reducedMotion) {
      _c.value = 1;
    } else {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CoinPurchaseScreenController>();
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PulseRings(color: BebuTheme.amber, size: 230),
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [BebuTheme.amber.withValues(alpha: 0.5), BebuTheme.amber.withValues(alpha: 0)])),
              ),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE08A), Color(0xFFFFB020), Color(0xFFE08A00)]),
                    boxShadow: [BoxShadow(color: BebuTheme.amber.withValues(alpha: 0.55), blurRadius: 40, offset: const Offset(0, 14))],
                  ),
                  child: Center(child: Image.asset(AppAsset.starCoin, width: 84, height: 84)),
                ),
              ),
              Positioned(
                bottom: 22,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.green, border: Border.all(color: BebuTheme.bg, width: 3)),
                    child: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        FadeTransition(
          opacity: _text,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(_text),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: c.coinsAdded.toDouble()),
                  duration: const Duration(milliseconds: 1300),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    c.coinsAdded > 0 ? '+${formatCoins(v.round())} coins' : 'Coins added',
                    style: BebuTheme.display(size: 40, color: BebuTheme.isLight ? const Color(0xFF7A4B00) : const Color(0xFFFFD27A)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Payment successful. Your wallet is topped up.', textAlign: TextAlign.center, style: BebuTheme.body(size: 14.5, color: BebuTheme.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// New balance count-up, framed as minutes of conversation.
class PurchaseBalanceCard extends StatelessWidget {
  const PurchaseBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CoinPurchaseScreenController>();
    final rate = Database.settingApiModel?.data?.audioCallRatePrivate ?? 0;
    return FadeSlideIn(
      delayMs: 700,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
          color: BebuTheme.surface,
          border: Border.all(color: BebuTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New balance', style: BebuTheme.label(size: 12, color: BebuTheme.textMuted)),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: c.previousBalance.toDouble(), end: c.newBalance.toDouble()),
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(AppAsset.starCoin, width: 22, height: 22),
                        const SizedBox(width: 8),
                        Text(formatCoins(v.round()), style: BebuTheme.title(size: 26)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (rate > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: BebuTheme.green.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(BebuTheme.radiusSm)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('≈ ${c.newBalance ~/ rate} min', style: BebuTheme.label(size: 15, color: BebuTheme.green)),
                    Text('of voice calls', style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Receipt rows: amount, gateway, transaction id (copyable), date.
class PurchaseReceipt extends StatelessWidget {
  const PurchaseReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CoinPurchaseScreenController>();
    final rows = <(String, String, bool)>[
      if ((c.amountPaid ?? '').isNotEmpty) ('Amount paid', '$currencySymbol${formatPrice(double.tryParse(c.amountPaid!) ?? 0)}', false),
      if ((c.paymentMode ?? '').isNotEmpty) ('Paid with', c.paymentMode!, false),
      if ((c.transactionId ?? '').isNotEmpty) ('Transaction ID', c.transactionId!, true),
      if ((c.date ?? '').isNotEmpty) ('Date', c.date!, false),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return FadeSlideIn(
      delayMs: 850,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusLg), color: BebuTheme.surface, border: Border.all(color: BebuTheme.border)),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Text(rows[i].$1, style: BebuTheme.body(size: 13, color: BebuTheme.textMuted)),
                    const Spacer(),
                    Flexible(
                      child: PressScale(
                        onTap: rows[i].$3
                            ? () {
                                Clipboard.setData(ClipboardData(text: rows[i].$2));
                                HapticFeedback.selectionClick();
                                Utils.showToast(context, 'Transaction ID copied');
                              }
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text(rows[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 13))),
                            if (rows[i].$3) ...[const SizedBox(width: 6), Icon(Icons.copy_rounded, size: 14, color: BebuTheme.textFaint)],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (i != rows.length - 1) Divider(height: 1, color: BebuTheme.border),
            ],
          ],
        ),
      ),
    );
  }
}

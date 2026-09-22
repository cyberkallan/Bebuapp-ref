import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/shimmer/coin_plan_shimmer.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

/// Coin packs as full-width rows so price, size and value line up in
/// columns and can be compared at a glance. Tapping selects; the sticky CTA
/// below confirms. The popular pack is pre-selected and the cheapest-per-coin
/// pack carries a "Best value" ribbon so the comparison is made for the user.
class CoinPlanGrid extends StatelessWidget {
  const CoinPlanGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyWalletController>(
      id: Constant.idGetCoinPlan,
      builder: (c) {
        if (c.isLoading && c.coinPlan.isEmpty) return const CoinPlanShimmer();
        if (c.coinPlan.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(Icons.hourglass_empty_rounded, color: BebuTheme.textMuted),
                const SizedBox(width: 12),
                Expanded(child: Text('Coin packs are being refreshed. Pull down to try again.', style: BebuTheme.body(size: 13))),
              ],
            ),
          );
        }
        final best = c.bestValuePlan;
        // Pile height follows the pack's rank by size, not its absolute count.
        final ranked = [...c.coinPlan]..sort((a, b) => (a.coins ?? 0).compareTo(b.coins ?? 0));
        int tier(CoinPlan p) => 1 + ranked.indexWhere((x) => x.id == p.id).clamp(0, 5);
        return Column(
          children: [
            for (var i = 0; i < c.coinPlan.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == c.coinPlan.length - 1 ? 0 : 12),
                child: FadeSlideIn(
                  delayMs: 40 * i,
                  child: GetBuilder<MyWalletController>(
                    id: MyWalletController.idSelection,
                    builder: (_) => CoinPlanCard(
                      plan: c.coinPlan[i],
                      tier: tier(c.coinPlan[i]),
                      selected: c.selectedCoinPlan?.id == c.coinPlan[i].id,
                      bestValue: best != null && best.id == c.coinPlan[i].id,
                      savings: c.savingsPercent(c.coinPlan[i]),
                      minutes: c.audioMinutes(c.coinPlan[i].coins ?? 0),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        c.selectPlan(c.coinPlan[i]);
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CoinPlanCard extends StatelessWidget {
  const CoinPlanCard({
    super.key,
    required this.plan,
    required this.tier,
    required this.selected,
    required this.bestValue,
    required this.savings,
    required this.minutes,
    required this.onTap,
  });

  final CoinPlan plan;
  final int tier;
  final bool selected;
  final bool bestValue;
  final int savings;
  final int? minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final popular = plan.isPopular == true;
    final ribbon = popular ? EnumLocale.txtMostPopularPlan.name.tr : (bestValue ? 'Best value' : null);
    final ribbonGradient = popular ? BebuTheme.pinkGradient : BebuTheme.violetGradient;
    final radius = BorderRadius.circular(BebuTheme.radiusLg);
    final coins = plan.coins ?? 0;
    final perCoin = coins > 0 && (plan.price ?? 0) > 0 ? (plan.price ?? 0) / coins : null;
    final sub = <String>[
      if (minutes != null && minutes! > 0) '≈ $minutes min',
      if (perCoin != null) '$currencySymbol${perCoin < 1 ? perCoin.toStringAsFixed(2) : perCoin.toStringAsFixed(1)}/coin',
    ].join(' · ');

    return PressScale(
      onTap: onTap,
      scale: 0.98,
      child: Padding(
        // Room for the ribbon that hangs over the top edge.
        padding: EdgeInsets.only(top: ribbon != null ? 8 : 0),
        child: AnimatedContainer(
          duration: BebuTheme.fast,
          curve: BebuTheme.curve,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: selected ? BebuTheme.pinkGradient : null,
            color: selected ? null : BebuTheme.border,
            boxShadow: selected ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.32), blurRadius: 28, offset: const Offset(0, 10))] : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: BebuTheme.fast,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BebuTheme.radiusLg - 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: selected
                        ? (BebuTheme.isLight ? [const Color(0xFFFFF1F7), const Color(0xFFFFF7FB)] : [const Color(0xFF2A1626), const Color(0xFF1B1220)])
                        : [BebuTheme.surface, BebuTheme.surface],
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [BebuTheme.amber.withValues(alpha: selected ? 0.38 : 0.22), BebuTheme.amber.withValues(alpha: 0)])),
                          ),
                          CoinStack(count: tier, width: 52),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(child: Text(formatCoins(coins), maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.display(size: 26))),
                              const SizedBox(width: 5),
                              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('coins', style: BebuTheme.label(size: 12.5, color: BebuTheme.textMuted))),
                            ],
                          ),
                          if (sub.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 12, color: BebuTheme.textMuted)),
                          ],
                          if (savings > 0) ...[
                            const SizedBox(height: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: BebuTheme.green.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text('SAVE $savings%', style: BebuTheme.label(size: 10, color: BebuTheme.isLight ? const Color(0xFF047857) : BebuTheme.green, weight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: BebuTheme.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: selected ? BebuTheme.pinkGradient : null,
                        color: selected ? null : BebuTheme.surface2,
                        border: selected ? null : Border.all(color: BebuTheme.borderStrong),
                        boxShadow: selected ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected) ...[const Icon(Icons.check_rounded, size: 15, color: Colors.white), const SizedBox(width: 5)],
                          Text('$currencySymbol${formatPrice(plan.price)}', style: BebuTheme.title(size: 16, color: selected ? Colors.white : BebuTheme.text)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (ribbon != null)
                Positioned(
                  top: -11,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: ribbonGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(popular ? Icons.local_fire_department_rounded : Icons.workspace_premium_rounded, size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(ribbon.toUpperCase(), style: BebuTheme.label(size: 9.5, color: Colors.white, weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Docked call-to-action that mirrors the selected pack and opens the payment
/// sheet. Sits above the safe area with a gradient fade so content scrolls under it.
class WalletCheckoutBar extends StatelessWidget {
  const WalletCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return GetBuilder<MyWalletController>(
      id: MyWalletController.idSelection,
      builder: (c) {
        final plan = c.selectedCoinPlan;
        return AnimatedSlide(
          duration: BebuTheme.normal,
          curve: BebuTheme.curve,
          offset: plan == null ? const Offset(0, 1.2) : Offset.zero,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 14, 16, bottom + 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [BebuTheme.bg.withValues(alpha: 0), BebuTheme.bg, BebuTheme.bg], stops: const [0, 0.35, 1]),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton(
                  label: plan == null ? 'Choose a pack' : 'Get ${formatCoins(plan.coins ?? 0)} coins · $currencySymbol${formatPrice(plan.price)}',
                  icon: Icons.bolt_rounded,
                  gradient: BebuTheme.pinkGradient,
                  glow: BebuTheme.pink,
                  onTap: plan == null ? null : () => openPaymentSheet(c),
                ),
                const SizedBox(height: 10),
                const WalletTrustStrip(),
              ],
            ),
          ),
        );
      },
    );
  }
}

void openPaymentSheet(MyWalletController c) {
  HapticFeedback.lightImpact();
  // Pre-select when only one gateway is on so "Pay" is a single tap.
  final s = Database.settingApiModel?.data;
  final enabled = <int>[
    if (s?.isRazorpayEnabled == true) 0,
    if (s?.isStripeEnabled == true) 1,
    if (s?.isFlutterwaveEnabled == true) 2,
    if (s?.isGooglePlayEnabled == true) 3,
  ];
  c.selectedPaymentMethod = enabled.length == 1 ? enabled.first : -1;
  c.update([Constant.onChangePaymentMethod]);
  Get.bottomSheet(
    const PaymentOptionBottomSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
  );
}

class PaymentOptionBottomSheet extends StatelessWidget {
  const PaymentOptionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final s = Database.settingApiModel?.data;
    return Container(
      decoration: BoxDecoration(
        color: BebuTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)),
        border: Border(top: BorderSide(color: BebuTheme.borderStrong)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 16),
      child: GetBuilder<MyWalletController>(
        id: Constant.onChangePaymentMethod,
        builder: (c) {
          final plan = c.selectedCoinPlan;
          if (plan == null) return const SizedBox.shrink();
          final ready = c.selectedPaymentMethod != -1;
          final minutes = c.audioMinutes(plan.coins ?? 0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              // Order summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                  gradient: LinearGradient(colors: BebuTheme.isLight ? [const Color(0xFFFFF3D6), const Color(0xFFFFE9F2)] : [const Color(0xFF2B2110), const Color(0xFF241222)]),
                  border: Border.all(color: BebuTheme.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const CoinStack(count: 3, width: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${formatCoins(plan.coins ?? 0)} coins', style: BebuTheme.title(size: 17)),
                          const SizedBox(height: 2),
                          Text(
                            [if (minutes != null && minutes > 0) '≈ $minutes min of voice calls', 'Added instantly'].join(' · '),
                            style: BebuTheme.body(size: 12, color: BebuTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text('$currencySymbol${formatPrice(plan.price)}', style: BebuTheme.title(size: 20, color: BebuTheme.pink)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(EnumLocale.txtPaymentMethod.name.tr, style: BebuTheme.label(size: 13, color: BebuTheme.textMuted)),
              const SizedBox(height: 10),
              if (s?.isRazorpayEnabled == true) PaymentOptionTile(index: 0, title: 'Razorpay', subtitle: 'UPI, cards, net banking', image: AppAsset.razorpay, controller: c),
              if (s?.isStripeEnabled == true) PaymentOptionTile(index: 1, title: 'Stripe', subtitle: 'Credit or debit card', image: AppAsset.stripe, controller: c),
              if (s?.isFlutterwaveEnabled == true) PaymentOptionTile(index: 2, title: 'Flutterwave', subtitle: 'Cards, bank, mobile money', image: AppAsset.flutterWave, controller: c),
              if (s?.isGooglePlayEnabled == true)
                PaymentOptionTile(
                  index: 3,
                  title: Platform.isIOS ? 'App Store' : 'Google Play',
                  subtitle: 'Billed to your store account',
                  image: Platform.isIOS ? AppAsset.appStoreImage : AppAsset.googleIcon,
                  imageSize: 26,
                  controller: c,
                ),
              const SizedBox(height: 14),
              GradientButton(
                label: ready ? '${EnumLocale.txtPay.name.tr} $currencySymbol${formatPrice(plan.price)}' : 'Select a payment method',
                icon: ready ? Icons.lock_rounded : null,
                gradient: BebuTheme.pinkGradient,
                glow: BebuTheme.pink,
                onTap: ready
                    ? () {
                        HapticFeedback.mediumImpact();
                        c.onClickPayNow(id: plan.id ?? '', amount: plan.price ?? 0, productKey: plan.productId ?? '');
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 13, color: BebuTheme.textFaint),
                    const SizedBox(width: 5),
                    Text('Encrypted checkout · charged once, no subscription', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  const PaymentOptionTile({
    super.key,
    required this.index,
    required this.title,
    required this.image,
    required this.controller,
    this.subtitle,
    this.imageSize = 44,
  });

  final int index;
  final String title;
  final String? subtitle;
  final String image;
  final double imageSize;
  final MyWalletController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedPaymentMethod == index;
    return PressScale(
      scale: 0.985,
      onTap: () {
        HapticFeedback.selectionClick();
        controller.onChangePaymentMethod(index);
      },
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? BebuTheme.pink.withValues(alpha: BebuTheme.isLight ? 0.08 : 0.12) : BebuTheme.surface,
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          border: Border.all(color: selected ? BebuTheme.pink : BebuTheme.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(BebuTheme.radiusSm)),
              child: Image.asset(image, width: imageSize, height: imageSize, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BebuTheme.label(size: 14.5)),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint))],
                ],
              ),
            ),
            AnimatedContainer(
              duration: BebuTheme.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? BebuTheme.pinkGradient : null,
                border: selected ? null : Border.all(color: BebuTheme.borderStrong, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

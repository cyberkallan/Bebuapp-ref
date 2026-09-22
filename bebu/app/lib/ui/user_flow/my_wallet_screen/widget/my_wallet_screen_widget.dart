import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/rewards/controller/rewards_controller.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

String get currencySymbol => Database.settingApiModel?.data?.currency?.symbol ?? '₹';

String formatCoins(num n) => NumberFormat.decimalPattern().format(n);

String formatPrice(num? p) {
  if (p == null) return '';
  final v = p.toDouble();
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

/// Back, title, history shortcut.
class WalletHeaderBar extends StatelessWidget {
  const WalletHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          Text(EnumLocale.txtMyWallet.name.tr, style: BebuTheme.title(size: 18)),
          const Spacer(),
          GlassIconButton(
            icon: Icons.receipt_long_rounded,
            size: 42,
            iconSize: 19,
            color: BebuTheme.surface,
            blur: false,
            onTap: () => Get.toNamed(AppRoutes.coinHistoryScreen),
            tooltip: EnumLocale.txtViewCoinHistory.name.tr,
          ),
        ],
      ),
    );
  }
}

/// Balance hero: big animated coin, count-up balance, "≈ minutes of talk"
/// framing and trust line.
class WalletBalanceCard extends StatefulWidget {
  const WalletBalanceCard({super.key});

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void initState() {
    super.initState();
    if (BebuTheme.coinAnimation) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyWalletController>(
      id: Constant.idGetCoinPlan,
      builder: (c) {
        final coins = c.fetchCoinPlan?.userCoin ?? int.tryParse(Database.userCoin) ?? 0;
        final minutes = c.audioMinutes(coins);
        return FadeSlideIn(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: BebuTheme.isLight
                    ? [const Color(0xFFFFF1CC), const Color(0xFFFFE2A6), const Color(0xFFF8EAFE)]
                    : [const Color(0xFF3A2A08), const Color(0xFF1E1A10), BebuTheme.violetDeep.withValues(alpha: 0.45)],
              ),
              border: Border.all(color: BebuTheme.amber.withValues(alpha: 0.35)),
              boxShadow: [BoxShadow(color: BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.25 : 0.18), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(EnumLocale.txtCurrentCoinBalance.name.tr, style: BebuTheme.label(size: 12.5, color: BebuTheme.textMuted)),
                      const SizedBox(height: 6),
                      _BalanceCountUp(from: c.previousCoin, to: coins),
                      const SizedBox(height: 10),
                      if (minutes != null) _TalkTimeChip(minutes: minutes),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 13, color: BebuTheme.textFaint),
                          const SizedBox(width: 5),
                          Text('Coins never expire', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [BebuTheme.amber.withValues(alpha: 0.45), BebuTheme.amber.withValues(alpha: 0)])),
                      ),
                      AnimatedCoin(progress: _loop, size: 68),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Frames the balance as talk time; turns into a gentle "running low" nudge
/// when fewer than three minutes are left.
class _TalkTimeChip extends StatelessWidget {
  const _TalkTimeChip({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final low = minutes < 3;
    final color = low ? BebuTheme.amber : BebuTheme.green;
    final text = minutes == 0
        ? 'Top up to start talking'
        : low
            ? 'Running low · ≈ $minutes min left'
            : '≈ $minutes min of voice calls';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: low ? color.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.22) : BebuTheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: low ? color.withValues(alpha: 0.5) : BebuTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(low ? Icons.hourglass_bottom_rounded : Icons.graphic_eq_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(text, style: BebuTheme.label(size: 11.5, color: low && BebuTheme.isLight ? const Color(0xFF7A4B00) : null)),
        ],
      ),
    );
  }
}

class _BalanceCountUp extends StatelessWidget {
  const _BalanceCountUp({required this.from, required this.to});
  final int from;
  final int to;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(to),
      tween: Tween(begin: from.toDouble(), end: to.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatCoins(v.round()), style: BebuTheme.display(size: 42, color: BebuTheme.isLight ? const Color(0xFF7A4B00) : const Color(0xFFFFD27A))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('coins', style: BebuTheme.label(size: 14, color: BebuTheme.textMuted))),
        ],
      ),
    );
  }
}

/// Three reassurance points under the CTA.
class WalletTrustStrip extends StatelessWidget {
  const WalletTrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.lock_rounded, 'Secure checkout'),
      (Icons.bolt_rounded, 'Instant credit'),
      (Icons.all_inclusive_rounded, 'Never expires'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[i].$1, size: 14, color: BebuTheme.green),
                const SizedBox(width: 5),
                Flexible(child: Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11.5, color: BebuTheme.textMuted))),
              ],
            ),
          ),
          if (i != items.length - 1) Container(width: 1, height: 12, color: BebuTheme.border),
        ],
      ],
    );
  }
}

/// Section header with optional trailing action.
class WalletSectionTitle extends StatelessWidget {
  const WalletSectionTitle({super.key, required this.title, this.subtitle, this.action, this.onAction});
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: BebuTheme.title(size: 19)),
              if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: BebuTheme.body(size: 12.5, color: BebuTheme.textFaint))],
            ],
          ),
        ),
        if (action != null)
          PressScale(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 2),
              child: Row(
                children: [
                  Text(action!, style: BebuTheme.label(size: 13, color: BebuTheme.pink)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: BebuTheme.pink),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Last few coin movements: purchases and bonuses in, calls out.
class WalletRecentActivity extends StatelessWidget {
  const WalletRecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyWalletController>(
      id: MyWalletController.idRecent,
      builder: (c) {
        Widget body;
        if (c.recentLoading && c.recentHistory.isEmpty) {
          body = Shimmer.fromColors(
            baseColor: BebuTheme.surface,
            highlightColor: BebuTheme.surface3,
            child: Column(children: [for (var i = 0; i < 3; i++) Container(height: 62, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd)))]),
          );
        } else if (c.recentHistory.isEmpty) {
          body = GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.violet.withValues(alpha: 0.18)),
                  child: Icon(Icons.auto_awesome_rounded, color: BebuTheme.violet, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No activity yet', style: BebuTheme.label(size: 14)),
                      const SizedBox(height: 2),
                      Text('Your first top-up and calls will show here.', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          body = Column(
            children: [
              for (var i = 0; i < c.recentHistory.length; i++) FadeSlideIn(delayMs: 40 * i, child: WalletActivityRow(item: c.recentHistory[i])),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WalletSectionTitle(title: 'Recent activity', action: c.recentHistory.isEmpty ? null : 'See all', onAction: () => Get.toNamed(AppRoutes.coinHistoryScreen)),
            const SizedBox(height: 12),
            body,
          ],
        );
      },
    );
  }
}

class WalletActivityRow extends StatelessWidget {
  const WalletActivityRow({super.key, required this.item});
  final CoinHistory item;

  @override
  Widget build(BuildContext context) {
    final type = item.type ?? 0;
    final income = item.isIncome ?? (type == 1 || type == 2 || type == 9 || type >= 11);
    final (icon, color, title) = switch (type) {
      1 => (Icons.card_giftcard_rounded, BebuTheme.violet, 'Welcome bonus'),
      2 => (Icons.add_card_rounded, BebuTheme.amber, 'Coins purchased'),
      3 => (Icons.call_rounded, BebuTheme.green, 'Voice call'),
      4 => (Icons.videocam_rounded, BebuTheme.pink, 'Video call'),
      5 => (Icons.shuffle_rounded, BebuTheme.green, 'Random voice call'),
      6 => (Icons.shuffle_rounded, BebuTheme.pink, 'Random video call'),
      8 => (Icons.auto_awesome_rounded, BebuTheme.violet, 'Avatar item unlocked'),
      9 => (Icons.redeem_rounded, BebuTheme.amber, 'Daily streak gift'),
      10 => (Icons.card_giftcard_rounded, BebuTheme.pink, 'Gift sent'),
      11 => (Icons.person_pin_rounded, BebuTheme.violet, 'Profile completed'),
      12 => (Icons.group_add_rounded, BebuTheme.pink, 'Invite reward'),
      13 => (Icons.auto_awesome_rounded, BebuTheme.green, 'Premium avatar bonus'),
      _ => (Icons.swap_horiz_rounded, BebuTheme.blue, 'Coins'),
    };
    final who = (type >= 3 && (item.receiverName ?? '').isNotEmpty) ? ' · ${item.receiverName}' : '';
    final when = item.createdAt == null ? (item.date ?? '') : _relative(item.createdAt!.toLocal());
    final amount = item.userCoin ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: color.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title$who', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 13.5)),
                const SizedBox(height: 2),
                Text([when, if ((item.duration ?? '').isNotEmpty && type >= 3) item.duration!].join(' · '), style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(income ? '+' : '−', style: BebuTheme.label(size: 14, color: income ? BebuTheme.green : BebuTheme.textMuted)),
              Text(formatCoins(amount.abs()), style: BebuTheme.label(size: 14, color: income ? BebuTheme.green : BebuTheme.text)),
              const SizedBox(width: 4),
              const Coin3D(size: 14),
            ],
          ),
        ],
      ),
    );
  }

  static String _relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('d MMM').format(d);
  }
}

/// Entry to the Earn coins hub: what is waiting right now, one tap to open.
class WalletEarnCard extends StatefulWidget {
  const WalletEarnCard({super.key});

  @override
  State<WalletEarnCard> createState() => _WalletEarnCardState();
}

class _WalletEarnCardState extends State<WalletEarnCard> {
  final RewardsController c = RewardsController.to;

  @override
  void initState() {
    super.initState();
    if (c.hub == null) c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RewardsController>(
      id: RewardsController.idHub,
      init: c,
      builder: (c) {
        final hub = c.hub;
        final pending = c.pendingCount;
        var waiting = 0;
        if (hub != null) {
          if (hub.daily?.canClaim == true) waiting += hub.daily!.coins;
          if (hub.profile.enabled && hub.profile.canClaim) waiting += hub.profile.coins;
        }
        final subtitle = hub == null
            ? 'Daily streak, profile, invites and more.'
            : pending > 0
                ? '$pending reward${pending == 1 ? '' : 's'} waiting · +${formatCoins(waiting)} coins'
                : [
                    if (hub.referral.enabled && hub.referral.inviterCoins > 0) 'Invite friends: +${hub.referral.inviterCoins} each',
                    if (hub.profile.enabled && !hub.profile.claimed) 'Finish your profile: +${hub.profile.coins}',
                    if (hub.daily?.enabled ?? false) 'Keep your daily streak going',
                  ].take(2).join(' · ');
        return PressScale(
          scale: 0.985,
          onTap: () {
            Sfx.lightTap();
            Get.toNamed(AppRoutes.earnCoins);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.2 : 0.26), BebuTheme.pink.withValues(alpha: 0.16)]),
              borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
              border: Border.all(color: pending > 0 ? BebuTheme.amber.withValues(alpha: 0.55) : BebuTheme.border),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(BebuTheme.radiusSm)),
                      child: const Center(child: SpinningCoin(size: 28, period: Duration(milliseconds: 7000))),
                    ),
                    if (pending > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: BebuTheme.pink, shape: BoxShape.circle, border: Border.all(color: BebuTheme.bg, width: 2)),
                          child: Text('$pending', style: BebuTheme.label(size: 10.5, color: Colors.white, weight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Earn free coins', style: BebuTheme.title(size: 15.5)),
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 12.5, color: BebuTheme.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: BebuTheme.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "How coins work" — the old wallet guide, collapsed by default.
class WalletGuideView extends StatefulWidget {
  const WalletGuideView({super.key});

  @override
  State<WalletGuideView> createState() => _WalletGuideViewState();
}

class _WalletGuideViewState extends State<WalletGuideView> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.help_outline_rounded, size: 18, color: BebuTheme.textMuted),
                const SizedBox(width: 10),
                Expanded(child: Text('How coins work', style: BebuTheme.label(size: 13.5))),
                AnimatedRotation(turns: _open ? 0.5 : 0, duration: BebuTheme.fast, child: Icon(Icons.expand_more_rounded, color: BebuTheme.textFaint)),
              ],
            ),
            AnimatedSize(
              duration: BebuTheme.normal,
              curve: BebuTheme.curve,
              alignment: Alignment.topCenter,
              child: _open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(EnumLocale.txtUserGuide.name.tr, style: BebuTheme.body(size: 12.5, height: 1.6)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

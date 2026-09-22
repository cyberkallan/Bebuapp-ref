import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/daily_reward/controller/daily_reward_controller.dart';
import 'package:talk_in/ui/user_flow/rewards/controller/rewards_controller.dart';
import 'package:talk_in/ui/user_flow/rewards/model/rewards_hub_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

String _fmt(num n) => NumberFormat.decimalPattern().format(n);

/// "Earn coins": every way to get free coins in one place — daily streak,
/// profile completion, inviting friends and the premium-avatar bonus. Each
/// card shows the reward up front, progress, and a single primary action.
class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  final RewardsController c = RewardsController.to;

  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.7,
        child: SafeArea(
          bottom: false,
          child: GetBuilder<RewardsController>(
            id: RewardsController.idHub,
            init: c,
            builder: (c) {
              final hub = c.hub;
              return Column(
                children: [
                  _HeaderBar(balance: hub?.balance),
                  Expanded(
                    child: RefreshIndicator(
                      color: BebuTheme.pink,
                      backgroundColor: BebuTheme.surface,
                      onRefresh: c.load,
                      child: hub == null
                          ? (c.loading ? const _HubShimmer() : _ErrorState(message: c.error ?? 'Could not load rewards.', onRetry: c.load))
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                              children: [
                                FadeSlideIn(child: _Hero(hub: hub)),
                                const SizedBox(height: 22),
                                if (hub.daily != null && hub.daily!.enabled) ...[
                                  FadeSlideIn(delayMs: 40, child: _DailyCard(hub: hub)),
                                  const SizedBox(height: 14),
                                ],
                                if (hub.profile.enabled) ...[
                                  FadeSlideIn(delayMs: 80, child: _ProfileCard(hub: hub, controller: c)),
                                  const SizedBox(height: 14),
                                ],
                                if (hub.referral.enabled) ...[
                                  FadeSlideIn(delayMs: 120, child: _InviteCard(hub: hub, controller: c)),
                                  const SizedBox(height: 14),
                                ],
                                if (hub.avatarBonus.enabled && hub.avatarBonus.maxCoins > 0) ...[
                                  FadeSlideIn(delayMs: 160, child: _AvatarBonusCard(rule: hub.avatarBonus)),
                                  const SizedBox(height: 14),
                                ],
                                if (!hub.profile.enabled && !hub.referral.enabled && !(hub.daily?.enabled ?? false) && !hub.avatarBonus.enabled)
                                  const _ErrorState(message: 'No rewards are running right now. Check back soon.'),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Rewards are added to your wallet instantly and show up in coin history.',
                                    textAlign: TextAlign.center,
                                    style: BebuTheme.body(size: 12, color: BebuTheme.textFaint),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          Text('Earn coins', style: BebuTheme.title(size: 18)),
          const Spacer(),
          if (balance == null)
            const SizedBox(width: 42)
          else
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Coin3D(size: 18), const SizedBox(width: 6), Text(_fmt(balance!), style: BebuTheme.label(size: 13.5))],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.hub});
  final RewardsHub hub;

  @override
  Widget build(BuildContext context) {
    var potential = 0;
    if (hub.profile.enabled && !hub.profile.claimed) potential += hub.profile.coins;
    if (hub.daily?.canClaim == true) potential += hub.daily!.coins;
    final pending = RewardsController.to.pendingCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.22 : 0.3), BebuTheme.pink.withValues(alpha: 0.18)]),
        borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
        border: Border.all(color: BebuTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free coins, every day', style: BebuTheme.display(size: 24)),
                const SizedBox(height: 6),
                Text(
                  pending > 0
                      ? '$pending reward${pending == 1 ? '' : 's'} ready to collect${potential > 0 ? ' · +${_fmt(potential)} coins' : ''}'
                      : 'Finish small tasks, keep your streak and invite friends to top up without paying.',
                  style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const RepaintBoundary(child: SpinningCoin(size: 64, period: Duration(milliseconds: 6200))),
        ],
      ),
    );
  }
}

/// Shared card chrome: coloured icon tile, title, reward chip, body, action.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.icon, required this.color, required this.title, required this.rewardLabel, required this.child, this.done = false});
  final IconData icon;
  final Color color;
  final String title;
  final String rewardLabel;
  final Widget child;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BebuTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
        border: Border.all(color: done ? BebuTheme.green.withValues(alpha: 0.45) : BebuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: color.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.2)),
                child: Icon(done ? Icons.check_rounded : icon, size: 22, color: done ? BebuTheme.green : color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: BebuTheme.title(size: 16.5))),
              const SizedBox(width: 8),
              _RewardChip(label: rewardLabel, muted: done),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label, this.muted = false});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: muted ? BebuTheme.surface2 : BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Coin3D(size: 14),
          const SizedBox(width: 5),
          Text(label, style: BebuTheme.label(size: 12.5, color: muted ? BebuTheme.textMuted : (BebuTheme.isLight ? const Color(0xFF8A5A00) : BebuTheme.amber), weight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── daily streak ─────────────────────────────────────────────────────────────
class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.hub});
  final RewardsHub hub;

  @override
  Widget build(BuildContext context) {
    final d = hub.daily!;
    final daily = DailyRewardController.to;
    final next = daily.untilNext;
    return _TaskCard(
      icon: Icons.local_fire_department_rounded,
      color: BebuTheme.amber,
      title: 'Daily streak',
      rewardLabel: '+${_fmt(d.canClaim ? d.coins : d.nextCoins)}',
      done: !d.canClaim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.canClaim ? 'Day ${d.day} of your streak is waiting. Collect it before midnight.' : 'Collected today. Day ${d.day + 1} unlocks in ${_hm(next)} for +${_fmt(d.nextCoins)} coins.',
            style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < math.min(7, d.schedule.length); i++) ...[
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i < (d.canClaim ? d.day - 1 : d.day) ? BebuTheme.amber : BebuTheme.surface3,
                    ),
                  ),
                ),
                if (i != math.min(7, d.schedule.length) - 1) const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (d.canClaim)
            GradientButton(label: 'Collect ${_fmt(d.coins)} coins', icon: Icons.redeem_rounded, height: 48, gradient: _amberGradient, glow: BebuTheme.amber, onTap: () async {
              await daily.open(context);
              RewardsController.to.load();
            })
          else
            GhostButton(label: 'Streak: ${d.streak} day${d.streak == 1 ? '' : 's'} · best ${math.max(d.bestStreak, d.streak)}', icon: Icons.local_fire_department_rounded, height: 48, onTap: () => daily.open(context)),
        ],
      ),
    );
  }

  static String _hm(Duration d) {
    if (d.inMinutes < 1) return 'a moment';
    if (d.inHours < 1) return '${d.inMinutes} min';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

final LinearGradient _amberGradient = LinearGradient(colors: [BebuTheme.amber, const Color(0xFFFF8A3D)], begin: Alignment.topLeft, end: Alignment.bottomRight);

// ── complete your profile ────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.hub, required this.controller});
  final RewardsHub hub;
  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    final p = hub.profile;
    return _TaskCard(
      icon: Icons.person_pin_rounded,
      color: BebuTheme.violet,
      title: 'Complete your profile',
      rewardLabel: '+${_fmt(p.coins)}',
      done: p.claimed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProgressRing(progress: p.claimed ? 1 : p.progress, label: '${p.done}/${p.total}', color: BebuTheme.violet),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in p.steps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(s.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 17, color: s.done ? BebuTheme.green : BebuTheme.textFaint),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                style: BebuTheme.body(size: 13.5, color: s.done ? BebuTheme.textMuted : BebuTheme.text).copyWith(decoration: s.done ? TextDecoration.lineThrough : null, decorationColor: BebuTheme.textFaint),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (p.claimed)
            Row(children: [const Icon(Icons.check_rounded, size: 16, color: BebuTheme.green), const SizedBox(width: 6), Text('Collected · +${_fmt(p.coins)} coins', style: BebuTheme.label(size: 13, color: BebuTheme.green))])
          else if (p.canClaim)
            GradientButton(label: 'Claim ${_fmt(p.coins)} coins', icon: Icons.stars_rounded, height: 48, loading: controller.claiming, onTap: () async {
              final r = await controller.claimProfile(context);
              if (!r.ok && context.mounted && r.code != 'CLAIMED') Utils.showToast(context, r.message.isEmpty ? 'Could not claim' : r.message);
            })
          else
            GhostButton(label: 'Finish profile', icon: Icons.edit_rounded, height: 48, onTap: () async {
              await Get.toNamed(AppRoutes.editProfileScreen);
              controller.load();
            }),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.label, required this.color});
  final double progress;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: BebuTheme.reducedMotion ? const Duration(milliseconds: 1) : const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: 64,
        height: 64,
        child: CustomPaint(
          painter: _RingPainter(v, color, BebuTheme.surface3),
          child: Center(child: Text(label, style: BebuTheme.label(size: 14, weight: FontWeight.w800))),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track);
  final double v;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(3), 0, math.pi * 2, false, p..color = track);
    if (v > 0) canvas.drawArc(rect.deflate(3), -math.pi / 2, math.pi * 2 * v, false, p..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.v != v || old.color != color;
}

// ── invite friends ───────────────────────────────────────────────────────────
class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.hub, required this.controller});
  final RewardsHub hub;
  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    final r = hub.referral;
    final rules = <String>[
      if (r.inviterCoins > 0) '+${_fmt(r.inviterCoins)} coins when a friend signs up with your code',
      if (r.purchaseSharePercent > 0) '${r.purchaseSharePercent}% of the coins from their ${r.firstPurchaseOnly ? 'first ' : 'every '}purchase',
      if (r.inviteeCoins > 0) 'Your friend gets +${_fmt(r.inviteeCoins)} coins too',
    ];
    return _TaskCard(
      icon: Icons.group_add_rounded,
      color: BebuTheme.pink,
      title: 'Invite friends',
      rewardLabel: r.inviterCoins > 0 ? '+${_fmt(r.inviterCoins)} each' : '${r.purchaseSharePercent}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.bolt_rounded, size: 15, color: BebuTheme.pink)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(line, style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted, height: 1.3))),
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (r.code.isNotEmpty)
            PressScale(
              scale: 0.985,
              onTap: () async {
                await controller.copyCode();
                if (context.mounted) Utils.showToast(context, 'Code copied');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: BebuTheme.surface2,
                  borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                  border: Border.all(color: BebuTheme.pink.withValues(alpha: 0.45), width: 1.2),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR INVITE CODE', style: BebuTheme.label(size: 10.5, color: BebuTheme.textFaint, weight: FontWeight.w800).copyWith(letterSpacing: 1.4)),
                        const SizedBox(height: 2),
                        Text(r.code, style: BebuTheme.display(size: 24).copyWith(letterSpacing: 3, fontFeatures: const [FontFeature.tabularFigures()])),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.copy_rounded, size: 20, color: BebuTheme.textMuted),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(label: 'Joined', value: _fmt(r.invited)),
              _Stat(label: 'Purchased', value: _fmt(r.purchases)),
              _Stat(label: 'Earned', value: '+${_fmt(r.earnedCoins)}', coin: true),
            ],
          ),
          const SizedBox(height: 14),
          Builder(builder: (ctx) => GradientButton(label: 'Share invite', icon: Icons.ios_share_rounded, height: 48, gradient: BebuTheme.pinkGradient, glow: BebuTheme.pink, onTap: () => controller.share(ctx))),
          if (r.canEnterCode) ...[
            const SizedBox(height: 10),
            GhostButton(label: 'Have an invite code?', icon: Icons.confirmation_number_outlined, height: 46, onTap: () => _EnterCodeSheet.show(context, controller)),
          ] else if (r.applied) ...[
            const SizedBox(height: 10),
            Center(child: Text('You joined with a friend\'s code.', style: BebuTheme.body(size: 12.5, color: BebuTheme.textFaint))),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.coin = false});
  final String label;
  final String value;
  final bool coin;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(BebuTheme.radiusSm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [if (coin) ...[const Coin3D(size: 13), const SizedBox(width: 4)], Text(value, style: BebuTheme.label(size: 15, weight: FontWeight.w800))]),
            const SizedBox(height: 1),
            Text(label, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
          ],
        ),
      ),
    );
  }
}

class _EnterCodeSheet extends StatefulWidget {
  const _EnterCodeSheet({required this.controller});
  final RewardsController controller;

  static Future<void> show(BuildContext context, RewardsController controller) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _EnterCodeSheet(controller: controller),
      );

  @override
  State<_EnterCodeSheet> createState() => _EnterCodeSheetState();
}

class _EnterCodeSheetState extends State<_EnterCodeSheet> {
  final _field = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _field.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _error = 'Codes are 6 characters long.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await widget.controller.applyReferral(context, code);
    if (!mounted) return;
    if (r.ok) {
      Navigator.of(context).pop();
      Utils.showToast(context, r.message.isEmpty ? 'Code accepted' : r.message);
    } else {
      setState(() {
        _busy = false;
        _error = r.message.isEmpty ? 'That code did not work.' : r.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusXl), border: Border.all(color: BebuTheme.border)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.surface3, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Enter an invite code', style: BebuTheme.title(size: 20)),
            const SizedBox(height: 4),
            Text('Got a code from a friend? Type it here so they get their reward.', style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted)),
            const SizedBox(height: 16),
            TextField(
              controller: _field,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')), LengthLimitingTextInputFormatter(12)],
              style: BebuTheme.display(size: 24).copyWith(letterSpacing: 4),
              textAlign: TextAlign.center,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'ABC123',
                hintStyle: BebuTheme.display(size: 24, color: BebuTheme.textFaint).copyWith(letterSpacing: 4),
                filled: true,
                fillColor: BebuTheme.surface2,
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusMd), borderSide: BorderSide(color: BebuTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusMd), borderSide: BorderSide(color: BebuTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusMd), borderSide: BorderSide(color: BebuTheme.pink, width: 1.4)),
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(label: 'Apply code', icon: Icons.check_rounded, loading: _busy, onTap: _busy ? null : _submit),
          ],
        ),
      ),
    );
  }
}

// ── premium avatar bonus ─────────────────────────────────────────────────────
class _AvatarBonusCard extends StatelessWidget {
  const _AvatarBonusCard({required this.rule});
  final AvatarBonusRule rule;

  @override
  Widget build(BuildContext context) {
    final range = rule.minCoins == rule.maxCoins ? '+${_fmt(rule.maxCoins)}' : '+${_fmt(rule.minCoins)}–${_fmt(rule.maxCoins)}';
    return _TaskCard(
      icon: Icons.auto_awesome_rounded,
      color: BebuTheme.blue,
      title: 'Premium avatar bonus',
      rewardLabel: range,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlock any premium item in Avatar Studio and get $range coins back on the spot — pricier items pay back more.${rule.earned > 0 ? ' You have earned +${_fmt(rule.earned)} so far.' : ''}',
            style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted, height: 1.35),
          ),
          const SizedBox(height: 14),
          GhostButton(label: 'Open Avatar Studio', icon: Icons.brush_rounded, height: 48, onTap: () {
            Sfx.lightTap();
            Get.toNamed(AppRoutes.avatarStudio);
          }),
        ],
      ),
    );
  }
}

// ── states ───────────────────────────────────────────────────────────────────
class _HubShimmer extends StatelessWidget {
  const _HubShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
        children: [
          Container(height: 110, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg))),
          const SizedBox(height: 22),
          for (var i = 0; i < 3; i++) ...[
            Container(height: 190, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg))),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 40),
      children: [
        Icon(Icons.cloud_off_rounded, size: 44, color: BebuTheme.textFaint),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center, style: BebuTheme.body(size: 14, color: BebuTheme.textMuted)),
        if (onRetry != null) ...[
          const SizedBox(height: 18),
          Center(child: GhostButton(label: 'Try again', icon: Icons.refresh_rounded, expanded: false, height: 44, onTap: onRetry!)),
        ],
      ],
    );
  }
}

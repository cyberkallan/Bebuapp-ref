import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/premium/controller/premium_controller.dart';
import 'package:talk_in/ui/user_flow/premium/model/premium_model.dart';
import 'package:talk_in/ui/user_flow/premium/view/pro_widgets.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/pro.dart';
import 'package:talk_in/utils/utils.dart';

String _fmt(num n) => NumberFormat.decimalPattern().format(n);

/// bebu Pro: what you get, which pass to pick, and — once active — your
/// status, the golden-tick switch and a shortcut into the Style Studio.
class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  final PremiumController c = PremiumController.to;

  @override
  void initState() {
    super.initState();
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0A0E),
      body: GetBuilder<PremiumController>(
        id: PremiumController.idPro,
        init: c,
        builder: (c) {
          final d = c.data;
          final cfg = d?.config ?? Pro.config;
          final active = Pro.isActive;
          return Stack(
            fit: StackFit.expand,
            children: [
              const _GoldSky(),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _Header(balance: d?.coins ?? int.tryParse(Database.userCoin)),
                    Expanded(
                      child: RefreshIndicator(
                        color: BebuTheme.gold,
                        backgroundColor: const Color(0xFF1A1710),
                        onRefresh: c.load,
                        child: d == null && c.loading
                            ? const _ProShimmer()
                            : !cfg.enabled
                                ? _Unavailable(onRetry: c.load)
                                : ListView(
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                                    children: [
                                      FadeSlideIn(child: _Hero(cfg: cfg, active: active)),
                                      const SizedBox(height: 18),
                                      if (active) ...[
                                        FadeSlideIn(delayMs: 40, child: _StatusCard(c: c)),
                                        const SizedBox(height: 14),
                                      ],
                                      FadeSlideIn(delayMs: 80, child: _Perks(cfg: cfg, quota: d?.quota)),
                                      const SizedBox(height: 22),
                                      FadeSlideIn(
                                        delayMs: 120,
                                        child: Text(active ? 'Extend your pass' : 'Choose a pass', style: BebuTheme.title(size: 18, color: Colors.white)),
                                      ),
                                      const SizedBox(height: 10),
                                      ...List.generate(cfg.passes.length, (i) {
                                        final p = cfg.passes[i];
                                        return FadeSlideIn(
                                          delayMs: 140 + i * 40,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: _PassCard(pass: p, selected: c.selected?.key == p.key, onTap: () => c.select(p.key)),
                                          ),
                                        );
                                      }),
                                      if (c.error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(c.error!, textAlign: TextAlign.center, style: BebuTheme.body(size: 12.5, color: BebuTheme.red))),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Passes are paid with coins from your wallet and start right away. Calls are still charged per minute. Hosts see your golden tick in chat and on calls.',
                                        textAlign: TextAlign.center,
                                        style: BebuTheme.body(size: 11.5, color: Colors.white.withValues(alpha: 0.45)),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              if (cfg.enabled && cfg.passes.isNotEmpty) Positioned(left: 0, right: 0, bottom: 0, child: _BuyBar(c: c)),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _GoldSky extends StatelessWidget {
  const _GoldSky();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF241A08), Color(0xFF0B0A0E), Color(0xFF0B0A0E)], stops: [0, 0.45, 1]),
            ),
          ),
          Positioned(
            top: -120,
            left: -60,
            child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [BebuTheme.gold.withValues(alpha: 0.35), BebuTheme.gold.withValues(alpha: 0)]))),
          ),
          Positioned(
            top: 40,
            right: -100,
            child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFFFF7A45).withValues(alpha: 0.18), const Color(0xFFFF7A45).withValues(alpha: 0)]))),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          const ProPill(),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Coin3D(size: 18), const SizedBox(width: 6), Text(_fmt(balance ?? 0), style: BebuTheme.label(size: 13.5, color: Colors.white))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.cfg, required this.active});
  final ProConfig cfg;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const _FloatingCrest(),
        const SizedBox(height: 18),
        Text(active ? 'You\'re ${cfg.name}' : cfg.name, textAlign: TextAlign.center, style: BebuTheme.display(size: 32, color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          cfg.tagline.isEmpty ? 'Unlimited matching, golden tick, exclusive looks.' : cfg.tagline,
          textAlign: TextAlign.center,
          style: BebuTheme.body(size: 14, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _FloatingCrest extends StatefulWidget {
  const _FloatingCrest();

  @override
  State<_FloatingCrest> createState() => _FloatingCrestState();
}

class _FloatingCrestState extends State<_FloatingCrest> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Transform.translate(
            offset: Offset(0, math.sin(t) * 5),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(math.sin(t) * 0.18)
                ..rotateX(math.cos(t) * 0.06),
              child: const ProCrest(size: 108),
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.c});
  final PremiumController c;

  @override
  Widget build(BuildContext context) {
    final st = Pro.status;
    final goldenAllowed = Pro.features.goldenTick;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF2A2008), const Color(0xFF17140C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
        border: Border.all(color: BebuTheme.gold.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: BebuTheme.gold.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GoldenTick(size: 22, animate: true),
              const SizedBox(width: 8),
              Expanded(child: Text(PremiumController.untilLabel(st), style: BebuTheme.label(size: 13.5, color: Colors.white))),
            ],
          ),
          if (goldenAllowed) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Golden tick', style: BebuTheme.label(size: 14, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Show the tick next to your name in chats and calls.', style: BebuTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: st.badge,
                  activeColor: BebuTheme.gold,
                  activeTrackColor: BebuTheme.gold.withValues(alpha: 0.35),
                  onChanged: (v) => c.setBadge(v),
                ),
              ],
            ),
          ],
          if (Pro.studioEnabled) ...[
            const SizedBox(height: 12),
            PressScale(
              onTap: () {
                Sfx.lightTap();
                Get.toNamed(AppRoutes.styleStudio);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(gradient: BebuTheme.violetGradient, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.palette_rounded, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Style Studio', style: BebuTheme.label(size: 14, color: Colors.white)),
                          Text('4K wallpapers, fonts, chat & call themes', style: BebuTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Perks extends StatelessWidget {
  const _Perks({required this.cfg, this.quota});
  final ProConfig cfg;
  final MatchQuota? quota;

  @override
  Widget build(BuildContext context) {
    final f = cfg.features;
    final perks = <(IconData, String, String, Color)>[
      if (f.unlimitedRandomMatch)
        (
          Icons.all_inclusive_rounded,
          'Unlimited random match',
          f.freeRandomMatchesPerDay > 0 ? 'Free members get ${f.freeRandomMatchesPerDay} matches a day${quota != null && !quota!.unlimited ? ' · ${quota!.used} used today' : ''}.' : 'Match as often as you like, any time.',
          BebuTheme.pink
        ),
      if (f.goldenTick) (Icons.verified_rounded, 'Golden tick', 'A gold verified badge next to your name — switch it on or off any time.', BebuTheme.gold),
      if (f.styleStudio) (Icons.palette_rounded, 'Style Studio', '4K love, friendship and romantic wallpapers, display fonts, chat themes and call screens. Three of each are on us; the rest are coin unlocks.', BebuTheme.violet),
      if (f.proAvatarItems) (Icons.face_retouching_natural_rounded, 'Premium avatar items', 'Selected legendary avatar items and scenes unlock free while you\'re Pro.', BebuTheme.blue),
      if (f.proGifts) (Icons.card_giftcard_rounded, 'Exclusive gifts', 'Send Pro-only gifts hosts can\'t get from anyone else.', const Color(0xFFFF6B4A)),
    ];
    return Column(
      children: [
        for (var i = 0; i < perks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == perks.length - 1 ? 0 : 10),
            child: _PerkRow(icon: perks[i].$1, title: perks[i].$2, body: perks[i].$3, color: perks[i].$4),
          ),
      ],
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({required this.icon, required this.title, required this.body, required this.color});
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BebuTheme.label(size: 14.5, color: Colors.white)),
                const SizedBox(height: 2),
                Text(body, style: BebuTheme.body(size: 12.5, color: Colors.white.withValues(alpha: 0.62))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.pass, required this.selected, required this.onTap});
  final ProPass pass;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final perDay = pass.perDay;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [Color(0xFF3A2C0A), Color(0xFF1E1810)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
          border: Border.all(color: selected ? BebuTheme.gold : Colors.white.withValues(alpha: 0.1), width: selected ? 1.6 : 1),
          boxShadow: selected ? [BoxShadow(color: BebuTheme.gold.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: BebuTheme.fast,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? BebuTheme.goldGradient : null,
                border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3B2A05)) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(pass.name, style: BebuTheme.label(size: 15.5, color: Colors.white)),
                      if (pass.badge.isNotEmpty) ...[const SizedBox(width: 8), ProPill(label: pass.badge.toUpperCase(), dense: true)],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pass.lifetime ? 'One payment, Pro forever' : '${pass.durationLabel}${perDay != null ? ' · ≈ ${perDay < 10 ? perDay.toStringAsFixed(1) : perDay.round()} coins/day' : ''}',
                    style: BebuTheme.body(size: 12.5, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Coin3D(size: 20),
                const SizedBox(width: 6),
                Text(_fmt(pass.coins), style: BebuTheme.title(size: 18, color: selected ? BebuTheme.gold : Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.c});
  final PremiumController c;

  @override
  Widget build(BuildContext context) {
    final pass = c.selected;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF0B0A0E).withValues(alpha: 0), const Color(0xFF0B0A0E), const Color(0xFF0B0A0E)], stops: const [0, 0.35, 1]),
      ),
      child: GradientButton(
        label: pass == null
            ? 'Choose a pass'
            : c.buying
                ? 'Activating…'
                : '${Pro.isActive ? 'Extend' : 'Unlock'} ${pass.name} · ${_fmt(pass.coins)} coins',
        icon: c.buying ? null : Icons.workspace_premium_rounded,
        gradient: BebuTheme.goldGradient,
        glow: BebuTheme.gold,
        height: 58,
        loading: c.buying,
        onTap: pass == null || c.buying ? null : () => c.buy(context),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 40),
      children: [
        const ProCrest(size: 80, glow: false),
        const SizedBox(height: 18),
        Text('${Pro.name} is taking a break', textAlign: TextAlign.center, style: BebuTheme.title(size: 20, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Passes are switched off right now. Everything you already unlocked stays yours.', textAlign: TextAlign.center, style: BebuTheme.body(size: 13.5, color: Colors.white.withValues(alpha: 0.6))),
        const SizedBox(height: 20),
        GhostButton(label: 'Refresh', height: 48, onTap: onRetry),
      ],
    );
  }
}

class _ProShimmer extends StatelessWidget {
  const _ProShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double? w}) => Container(width: w, height: h, decoration: BoxDecoration(color: const Color(0xFF1E1A14), borderRadius: BorderRadius.circular(18)));
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1A14),
      highlightColor: const Color(0xFF3A2F1C),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          Center(child: box(108, w: 108)),
          const SizedBox(height: 18),
          Center(child: box(28, w: 180)),
          const SizedBox(height: 10),
          Center(child: box(14, w: 240)),
          const SizedBox(height: 26),
          for (var i = 0; i < 4; i++) ...[box(70), const SizedBox(height: 10)],
          const SizedBox(height: 10),
          for (var i = 0; i < 3; i++) ...[box(78), const SizedBox(height: 10)],
        ],
      ),
    );
  }
}

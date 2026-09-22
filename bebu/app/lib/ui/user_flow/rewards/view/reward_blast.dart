import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/rewards/model/rewards_hub_model.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Full-screen "reward unlocked" celebration for coin rewards (profile
/// complete, invite bonus, avatar-unlock bonus…). Lives in the root overlay
/// so it plays above whatever screen granted it. About 2.4 s: a gold coin
/// drops in and spins to face you, rays and a coin/star burst bloom behind
/// it, the amount counts up, then everything lifts away. Tap to skip.
///
/// Performance notes: one [AnimationController] drives every layer through a
/// single [AnimatedBuilder]; rays, sparks and the coin are painted with
/// [CustomPainter]s inside [RepaintBoundary]s (no per-frame widget churn, no
/// blur filters); particle state is precomputed once. Reduced motion shortens
/// the whole thing to a fade with no particles.
class RewardBlast extends StatefulWidget {
  const RewardBlast({super.key, required this.reward, required this.onDone});

  final GrantedReward reward;
  final VoidCallback onDone;

  static OverlayEntry? _entry;
  static final Queue<GrantedReward> _queue = Queue();

  /// Shows [reward] now, or right after the one currently playing.
  static void show(BuildContext context, GrantedReward reward) {
    if (_entry != null) {
      _queue.add(reward);
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => RewardBlast(
        reward: reward,
        onDone: () {
          if (_entry == entry) _entry = null;
          entry.remove();
          if (_queue.isNotEmpty && context.mounted) show(context, _queue.removeFirst());
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static bool get isShowing => _entry != null;

  @override
  State<RewardBlast> createState() => _RewardBlastState();
}

class _RewardBlastState extends State<RewardBlast> with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 2450);

  late final AnimationController _c;
  late final List<_Bit> _bits;
  bool _done = false;
  bool _landed = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(widget.reward.coins * 31 + widget.reward.kind.hashCode);
    _bits = List.generate(BebuTheme.reducedMotion ? 0 : 46, (i) => _Bit.random(rnd, i));
    _c = AnimationController(vsync: this, duration: BebuTheme.reducedMotion ? const Duration(milliseconds: 800) : _total)
      ..addListener(_cues)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      })
      ..forward();
    Sfx.unlock();
  }

  // Haptic beats tied to the timeline: coin lands, counter finishes.
  void _cues() {
    final t = _c.value;
    if (!_landed && t >= .30) {
      _landed = true;
      Sfx.mediumTap();
    }
    if (!_counted && t >= .72) {
      _counted = true;
      Sfx.lightTap();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final coinSize = math.min(size.width * 0.40, 168.0);
    final r = widget.reward;
    final title = r.title ?? _titleFor(r.kind);
    final subtitle = r.subtitle ?? _subtitleFor(r.kind);
    final fmt = NumberFormat.decimalPattern();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _c.animateTo(1, duration: const Duration(milliseconds: 220), curve: Curves.easeIn),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final scrim = _seg(t, 0, .16) * (1 - _seg(t, .84, 1));
            final drop = Curves.easeOutBack.transform(_seg(t, .04, .32));
            final spin = Curves.easeOutCubic.transform(_seg(t, .04, .46));
            final count = Curves.easeOutCubic.transform(_seg(t, .38, .72));
            final pop = Curves.easeOutBack.transform(_seg(t, .30, .52));
            final chip = Curves.easeOutBack.transform(_seg(t, .56, .74));
            final out = Curves.easeInCubic.transform(_seg(t, .84, 1));
            final glow = math.sin(math.min(1, _seg(t, .1, .92)) * math.pi);
            final burst = _seg(t, .30, .96);
            final shown = (r.coins * count).round();
            // Yaw: two and a half turns that settle to a near face-on rest.
            final yaw = -0.34 + (1 - spin) * math.pi * 5;
            final shine = _seg(t, .46, .62);

            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: scrim.clamp(0, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.18),
                        radius: 0.95,
                        colors: [BebuTheme.amber.withValues(alpha: 0.38 * glow), Colors.black.withValues(alpha: 0.74), Colors.black.withValues(alpha: 0.84)],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                if (!BebuTheme.reducedMotion)
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _BurstPainter(t: t, rays: _seg(t, .12, .46) * (1 - out), burst: burst, bits: _bits, fade: 1 - out, center: const Alignment(0, -0.18)),
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, -0.18),
                  child: Transform.translate(
                    offset: Offset(0, -(1 - drop) * size.height * 0.5 - out * 140),
                    child: Opacity(
                      opacity: (1 - out).clamp(0, 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CoinHalo(
                            size: coinSize,
                            strength: glow,
                            child: RepaintBoundary(
                              child: CustomPaint(
                                size: Size.square(coinSize),
                                painter: Coin3DPainter(yaw: yaw, pitch: 0.14 + 0.04 * math.sin(t * math.pi * 3), shine: shine),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Transform.translate(
                            offset: Offset(0, (1 - pop) * 22),
                            child: Opacity(
                              opacity: pop.clamp(0, 1),
                              child: Column(
                                children: [
                                  Text(
                                    '+${fmt.format(shown)}',
                                    style: BebuTheme.display(size: 56, color: Colors.white).copyWith(fontFeatures: const [FontFeature.tabularFigures()], height: 1, letterSpacing: -1.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('coins', style: BebuTheme.label(size: 14, color: BebuTheme.amber, weight: FontWeight.w800).copyWith(letterSpacing: 2.4)),
                                  const SizedBox(height: 18),
                                  Text(title, textAlign: TextAlign.center, style: BebuTheme.display(size: 26, color: Colors.white)),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 36),
                                    child: Text(subtitle, textAlign: TextAlign.center, style: BebuTheme.body(size: 14.5, color: Colors.white.withValues(alpha: 0.8))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (r.balance != null) ...[
                            const SizedBox(height: 20),
                            Transform.scale(
                              scale: chip.clamp(0, 1.2),
                              child: Opacity(opacity: chip.clamp(0, 1), child: _BalanceChip(balance: r.balance!)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36 + MediaQuery.paddingOf(context).bottom,
                  child: Opacity(
                    opacity: (scrim * 0.7).clamp(0, 1),
                    child: Text('Tap to continue', textAlign: TextAlign.center, style: BebuTheme.label(size: 12, color: Colors.white.withValues(alpha: 0.6))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _titleFor(String kind) => switch (kind) {
        'profile' => 'Profile complete!',
        'referral' => 'Invite bonus!',
        'avatarBonus' => 'Premium bonus!',
        'daily' => 'Daily reward!',
        _ => 'Reward unlocked!',
      };

  static String _subtitleFor(String kind) => switch (kind) {
        'profile' => 'Thanks for finishing your profile. The coins are in your wallet.',
        'referral' => 'Your invite paid off. Keep sharing your code to earn more.',
        'avatarBonus' => 'A little something back for unlocking a premium item.',
        _ => 'Coins added to your wallet.',
      };
}

class _CoinHalo extends StatelessWidget {
  const _CoinHalo({required this.size, required this.strength, required this.child});
  final double size;
  final double strength;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: BebuTheme.amber.withValues(alpha: 0.55 * strength), blurRadius: size * 0.45, spreadRadius: size * 0.05),
          BoxShadow(color: Colors.white.withValues(alpha: 0.16 * strength), blurRadius: size * 0.2),
        ],
      ),
      child: child,
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.balance});
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Coin3D(size: 20),
          const SizedBox(width: 8),
          Text('Wallet  ${NumberFormat.decimalPattern().format(balance)}', style: BebuTheme.label(size: 14, color: Colors.white)),
        ],
      ),
    );
  }
}

/// One flying particle: a small coin (ellipse whose width follows a spin) or
/// a four-point star. All randomness is fixed at construction.
class _Bit {
  _Bit({required this.angle, required this.speed, required this.size, required this.isCoin, required this.delay, required this.spin, required this.gravity});
  final double angle;
  final double speed;
  final double size;
  final bool isCoin;
  final double delay;
  final double spin;
  final double gravity;

  factory _Bit.random(math.Random r, int i) => _Bit(
        angle: -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 1.7,
        speed: 0.45 + r.nextDouble() * 0.55,
        size: i % 3 == 0 ? 4 + r.nextDouble() * 4 : 7 + r.nextDouble() * 8,
        isCoin: i % 3 != 0,
        delay: r.nextDouble() * 0.14,
        spin: 2 + r.nextDouble() * 6,
        gravity: 0.7 + r.nextDouble() * 0.6,
      );
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.t, required this.rays, required this.burst, required this.bits, required this.fade, required this.center});
  final double t;
  final double rays;
  final double burst;
  final List<_Bit> bits;
  final double fade;
  final Alignment center;

  static final _rayPaint = Paint()..style = PaintingStyle.fill;
  static final _coinFace = Paint()..color = const Color(0xFFFFC53D);
  static final _coinRim = Paint()..color = const Color(0xFFB8781A);
  static final _star = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || fade <= 0) return;
    final c = Offset(size.width / 2 + center.x * size.width / 2, size.height / 2 + center.y * size.height / 2);
    final maxR = size.shortestSide * 0.7;

    // Rotating light rays: 14 thin wedges, alpha rising then falling.
    if (rays > 0) {
      final a = (math.sin(rays * math.pi) * 0.22 * fade).clamp(0.0, 1.0);
      _rayPaint.shader = RadialGradient(colors: [BebuTheme.amber.withValues(alpha: a), BebuTheme.amber.withValues(alpha: 0)], stops: const [0.05, 1]).createShader(Rect.fromCircle(center: c, radius: maxR));
      final rot = t * math.pi * 0.5;
      for (var i = 0; i < 14; i++) {
        final ang = rot + i * math.pi * 2 / 14;
        final w = 0.055 + 0.03 * ((i % 2 == 0) ? 1 : 0);
        final path = Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(ang - w) * maxR, c.dy + math.sin(ang - w) * maxR)
          ..lineTo(c.dx + math.cos(ang + w) * maxR, c.dy + math.sin(ang + w) * maxR)
          ..close();
        canvas.drawPath(path, _rayPaint);
      }
    }

    // Coins + stars flung up and out, falling back under gravity.
    if (burst <= 0) return;
    for (final b in bits) {
      final p = ((burst - b.delay) / (1 - b.delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final ease = 1 - math.pow(1 - p, 2.2).toDouble();
      final dist = ease * maxR * b.speed;
      final x = c.dx + math.cos(b.angle) * dist;
      final y = c.dy + math.sin(b.angle) * dist + p * p * maxR * 0.55 * b.gravity;
      final alpha = ((1 - p) * 1.6).clamp(0.0, 1.0) * fade;
      if (alpha <= 0.01) continue;
      if (b.isCoin) {
        final w = b.size * (0.25 + 0.75 * math.cos(p * b.spin * math.pi).abs());
        _coinRim.color = _coinRim.color.withValues(alpha: alpha);
        _coinFace.color = _coinFace.color.withValues(alpha: alpha);
        canvas.drawOval(Rect.fromCenter(center: Offset(x + 1, y + 1), width: w, height: b.size), _coinRim);
        canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: w, height: b.size), _coinFace);
      } else {
        _star.color = Colors.white.withValues(alpha: alpha);
        final s = b.size * (0.6 + 0.4 * math.sin(p * math.pi));
        final path = Path();
        for (var k = 0; k < 8; k++) {
          final rr = k.isEven ? s : s * 0.38;
          final ang = k * math.pi / 4 + p * b.spin;
          final pt = Offset(x + math.cos(ang) * rr, y + math.sin(ang) * rr);
          k == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(path..close(), _star);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t || old.fade != fade;
}

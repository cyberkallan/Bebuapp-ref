import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Coin balance pill with a slow 3D coin flip, a glossy sweep across the pill
/// and a count-up whenever the balance changes.
///
/// One repeating controller drives everything; the widget is wrapped in a
/// [RepaintBoundary] so the 44px pill is the only thing repainting.
class CoinPill extends StatefulWidget {
  const CoinPill({super.key, required this.coins, required this.onTap, this.loading = false, this.height = 44});

  final int coins;
  final VoidCallback onTap;
  final bool loading;
  final double height;

  @override
  State<CoinPill> createState() => _CoinPillState();
}

class _CoinPillState extends State<CoinPill> with SingleTickerProviderStateMixin {
  static const _period = Duration(milliseconds: 4200);

  late final AnimationController _loop = AnimationController(vsync: this, duration: _period);

  @override
  void initState() {
    super.initState();
    _syncLoop();
  }

  void _syncLoop() {
    if (BebuTheme.coinAnimation) {
      if (!_loop.isAnimating) _loop.repeat();
    } else if (_loop.isAnimating) {
      _loop.stop();
      _loop.value = 0;
    }
  }
  late int _from = widget.coins;
  late int _to = widget.coins;

  @override
  void didUpdateWidget(covariant CoinPill old) {
    super.didUpdateWidget(old);
    _syncLoop();
    if (old.coins != widget.coins) {
      _from = old.coins;
      _to = widget.coins;
    }
  }

  // Get.forceAppUpdate() reassembles the tree after an admin toggle.
  @override
  void reassemble() {
    super.reassemble();
    _syncLoop();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(999);
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: '${widget.coins} coins, open wallet',
        child: PressScale(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: r,
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
              decoration: BoxDecoration(
                borderRadius: r,
                border: Border.all(color: BebuTheme.amber.withValues(alpha: 0.28)),
                gradient: LinearGradient(
                  colors: [BebuTheme.amber.withValues(alpha: 0.16), BebuTheme.surface],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCoin(progress: _loop, size: widget.height - 20),
                      const SizedBox(width: 6),
                      widget.loading
                          ? Shimmer.fromColors(
                              baseColor: BebuTheme.surface3,
                              highlightColor: BebuTheme.textFaint,
                              child: Container(width: 28, height: 12, decoration: BoxDecoration(color: BebuTheme.surface3, borderRadius: BorderRadius.circular(6))),
                            )
                          : _CountUp(from: _from, to: _to),
                    ],
                  ),
                  // Glossy sweep, phase-offset from the flip so they never overlap.
                  Positioned.fill(child: IgnorePointer(child: _Sweep(progress: _loop, start: 0.42, end: 0.62))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The star-coin asset doing a full Y-axis flip during the first ~18% of the
/// loop, then resting. A soft glow breathes underneath it.
class AnimatedCoin extends StatelessWidget {
  const AnimatedCoin({super.key, required this.progress, this.size = 20});

  final Animation<double> progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final t = progress.value;
        final flipT = (t / 0.18).clamp(0.0, 1.0);
        final angle = Curves.easeInOutCubic.transform(flipT) * math.pi * 2;
        // Cosine so the coin looks thin at 90° and full again at 180°/360°.
        final glow = 0.25 + 0.35 * (0.5 - 0.5 * math.cos(t * math.pi * 2));
        return Container(
          width: size + 8,
          height: size + 8,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: BebuTheme.amber.withValues(alpha: glow), blurRadius: 10, spreadRadius: -2)],
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: child,
          ),
        );
      },
      child: Image.asset(AppAsset.starCoin, height: size, width: size),
    );
  }
}

/// A narrow diagonal highlight that travels across the parent once per loop.
class _Sweep extends StatelessWidget {
  const _Sweep({required this.progress, required this.start, required this.end});

  final Animation<double> progress;
  final double start;
  final double end;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        if (t < start || t > end) return const SizedBox.shrink();
        final k = Curves.easeInOut.transform((t - start) / (end - start));
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final x = -w * 0.6 + k * (w * 1.8);
            return Transform.translate(
              offset: Offset(x, 0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.skewX(-0.45),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: w * 0.28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Tweens the displayed number whenever `to` changes and bounces the text once.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.from, required this.to});

  final int from;
  final int to;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(to),
      tween: Tween(begin: from.toDouble(), end: to.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final running = (v - to).abs() > 0.5;
        return AnimatedScale(
          scale: running ? 1.08 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Text(
            _format(v.round()),
            style: BebuTheme.label(size: 14, color: BebuTheme.amber, weight: FontWeight.w700),
          ),
        );
      },
    );
  }

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 100000) return '${(n / 1000).toStringAsFixed(0)}K';
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/coin_burst.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/daily_reward/controller/daily_reward_controller.dart';
import 'package:talk_in/ui/user_flow/daily_reward/model/daily_reward_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/login_config.dart';

String _fmt(num n) => NumberFormat.decimalPattern().format(n);

/// The daily streak gift. Opens as a bottom sheet from Home: shows today's
/// coins on a floating 3D coin, the streak strip, and a single "Collect"
/// action. Claiming plays a spin, a coin burst, a chime and a heavy tap, then
/// flips to a live countdown with tomorrow's amount as the hook.
class DailyRewardSheet extends StatefulWidget {
  const DailyRewardSheet({super.key, required this.controller});

  final DailyRewardController controller;

  static Future<void> show(BuildContext context, DailyRewardController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.55 : 0.72),
      builder: (_) => DailyRewardSheet(controller: controller),
    );
  }

  @override
  State<DailyRewardSheet> createState() => _DailyRewardSheetState();
}

class _DailyRewardSheetState extends State<DailyRewardSheet> with TickerProviderStateMixin {
  late DailyRewardStatus? _status = widget.controller.status;
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
  late final AnimationController _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

  bool _claiming = false;
  bool _burst = false;
  int _shownCoins = 0;
  String? _error;
  Timer? _tick;
  late final bool _welcome = widget.controller.welcomePending;
  final _teaser = RewardTeaser.current;

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) _float.repeat();
    _in.forward();
    _shownCoins = _status?.coins ?? 0;
    if (_status?.claimedToday == true) _startTick();
    if (_welcome) widget.controller.consumeWelcome();
    if (_status == null) _load();
  }

  Future<void> _load() async {
    final s = await widget.controller.load();
    if (!mounted) return;
    setState(() {
      _status = s;
      _shownCoins = s?.coins ?? 0;
    });
    if (s?.claimedToday == true) _startTick();
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _float.dispose();
    _spin.dispose();
    _in.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    if (_claiming || _status == null || !_status!.canClaim) return;
    Sfx.mediumTap();
    setState(() {
      _claiming = true;
      _error = null;
    });
    final result = await widget.controller.claim();
    if (!mounted) return;
    if (!result.ok) {
      Sfx.deny();
      setState(() {
        _claiming = false;
        _error = result.error;
        if (result.claimedToday) _status = result.copyWith(canClaim: false);
      });
      if (result.claimedToday) _startTick();
      return;
    }
    // Reveal: spin the coin, burst, count the number up, then settle into the countdown state.
    unawaited(Sfx.unlock());
    setState(() => _burst = true);
    if (!BebuTheme.reducedMotion) await _spin.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _status = result;
      _shownCoins = result.claimed ?? result.coins;
      _claiming = false;
    });
    _startTick();
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    return AnimatedBuilder(
      animation: _in,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_in.value);
        return Transform.translate(offset: Offset(0, (1 - t) * 40), child: Opacity(opacity: t, child: child));
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: BebuTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)),
          border: Border(top: BorderSide(color: BebuTheme.borderStrong)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)),
          child: Stack(
            children: [
              if (BebuTheme.ambientGlow) Positioned.fill(child: IgnorePointer(child: AuroraBackground(intensity: 0.9))),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.paddingOf(context).bottom),
                child: s == null ? const _Loading() : _body(s),
              ),
              if (_burst)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CoinBurst(coins: 30, confetti: 50, origin: const Alignment(0, -0.45), onDone: () => mounted ? setState(() => _burst = false) : null),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(DailyRewardStatus s) {
    final claimed = s.claimedToday;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 14),
        _Header(status: s, onClose: () => Navigator.of(context).maybePop()),
        const SizedBox(height: 8),
        _Stage(float: _float, spin: _spin, coins: _shownCoins, claimed: claimed, claiming: _claiming),
        const SizedBox(height: 6),
        _StreakStrip(status: s),
        const SizedBox(height: 16),
        if (_welcome && _teaser.welcomeCoins > 0) ...[
          _WelcomeBanner(coins: _teaser.welcomeCoins),
          const SizedBox(height: 12),
        ],
        Text(
          claimed
              ? 'Tomorrow’s gift is ${_fmt(s.nextCoins)} coins. Come back to keep the streak alive — miss a day and it starts over.'
              : 'Collect today, and tomorrow grows to ${_fmt(s.nextCoins)} coins. The longer the streak, the bigger the gift.',
          textAlign: TextAlign.center,
          style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted, height: 1.4),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, textAlign: TextAlign.center, style: BebuTheme.label(size: 12.5, color: BebuTheme.red)),
        ],
        const SizedBox(height: 18),
        if (!claimed)
          GradientButton(
            label: _claiming ? 'Collecting…' : 'Collect ${_fmt(s.coins)} coins',
            icon: _claiming ? null : Icons.redeem_rounded,
            gradient: BebuTheme.pinkGradient,
            glow: BebuTheme.pink,
            loading: _claiming,
            onTap: s.enabled ? _claim : null,
          )
        else ...[
          _Countdown(until: widget.controller.untilNext, next: s.nextCoins),
          const SizedBox(height: 10),
          GradientButton(
            label: 'Start a conversation',
            icon: Icons.call_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).maybePop();
              Get.toNamed(AppRoutes.myWalletScreen);
            },
            child: Text('See my wallet', style: BebuTheme.label(size: 13, color: BebuTheme.textMuted)),
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: BebuTheme.pink))),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status, required this.onClose});
  final DailyRewardStatus status;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final first = status.streak <= 1 && !status.claimedToday && status.totalClaims == 0;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(first ? 'YOUR FIRST GIFT' : 'DAILY GIFT', style: BebuTheme.label(size: 11, color: BebuTheme.pink, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                status.claimedToday ? 'Collected for today' : (first ? 'A little something to start' : 'Your gift is ready'),
                style: BebuTheme.title(size: 22),
              ),
            ],
          ),
        ),
        _StreakChip(streak: status.streak, best: status.bestStreak),
        const SizedBox(width: 8),
        GlassIconButton(icon: Icons.close_rounded, size: 36, color: BebuTheme.surface2, blur: false, onTap: onClose, tooltip: 'Close'),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak, required this.best});
  final int streak;
  final int best;

  @override
  Widget build(BuildContext context) {
    final hot = streak >= 3;
    final color = hot ? const Color(0xFFFF7A3D) : BebuTheme.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text('Day $streak', style: BebuTheme.label(size: 12.5, color: color, weight: FontWeight.w800)),
          if (best > streak) ...[
            const SizedBox(width: 4),
            Text('· best $best', style: BebuTheme.label(size: 11, color: color.withValues(alpha: 0.8))),
          ],
        ],
      ),
    );
  }
}

/// Floating coin with a glow, orbiting sparks and the amount underneath.
class _Stage extends StatelessWidget {
  const _Stage({required this.float, required this.spin, required this.coins, required this.claimed, required this.claiming});
  final AnimationController float;
  final AnimationController spin;
  final int coins;
  final bool claimed;
  final bool claiming;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([float, spin]),
          builder: (context, _) {
            final f = float.value;
            final dy = math.sin(f * math.pi * 2) * 7;
            final wobble = math.sin(f * math.pi * 2 + 0.8) * 0.16;
            final sp = Curves.easeInOutCubic.transform(spin.value);
            final yaw = -0.42 + wobble + sp * math.pi * 2;
            final scale = 1 + math.sin(sp * math.pi) * 0.14;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Positioned(
                  top: 18,
                  child: IgnorePointer(
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.28 : 0.38), BebuTheme.amber.withValues(alpha: 0)]),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 8, child: SizedBox(width: 210, height: 210, child: CustomPaint(painter: _SparkPainter(t: f, color: BebuTheme.amber)))),
                Positioned(
                  top: 62 + dy,
                  child: Transform.scale(
                    scale: scale,
                    child: Coin3D(size: 104, yaw: yaw, pitch: 0.16, shine: claimed ? 0 : ((f * 2) % 1)),
                  ),
                ),
                if (claimed)
                  Positioned(
                    top: 128,
                    right: MediaQuery.sizeOf(context).width / 2 - 72,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.green, border: Border.all(color: BebuTheme.bg, width: 3)),
                      child: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: coins.toDouble()),
                        duration: BebuTheme.reducedMotion ? Duration.zero : const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text('+${_fmt(v.round())}', style: BebuTheme.display(size: 44, color: BebuTheme.text)),
                      ),
                      Text(claimed ? 'coins added to your wallet' : 'coins waiting for you', style: BebuTheme.label(size: 13, color: BebuTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.t, required this.color});
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final c = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 9; i++) {
      final a = t * math.pi * 2 * (i.isEven ? 1 : -0.7) + i * (math.pi * 2 / 9);
      final r = size.width * (0.30 + 0.10 * math.sin(t * math.pi * 2 + i));
      final p = c + Offset(math.cos(a), math.sin(a) * 0.72) * r;
      final tw = 0.5 + 0.5 * math.sin(t * math.pi * 6 + i * 1.7);
      paint.color = color.withValues(alpha: 0.25 + 0.55 * tw);
      canvas.drawCircle(p, 1.4 + 1.6 * tw, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.t != t || old.color != color;
}

/// Day cells. Past days are ticked, today glows, later days show the amount
/// so the user knows exactly what they are coming back for.
class _StreakStrip extends StatelessWidget {
  const _StreakStrip({required this.status});
  final DailyRewardStatus status;

  @override
  Widget build(BuildContext context) {
    final n = status.schedule.length;
    final cells = <Widget>[
      for (var i = 0; i < n; i++)
        _DayCell(
          day: i + 1,
          coins: status.schedule[i],
          state: i + 1 < status.day
              ? _DayState.done
              : i + 1 == status.day
                  ? (status.claimedToday ? _DayState.done : _DayState.today)
                  : _DayState.future,
          isLast: i == n - 1,
          highlightToday: i + 1 == status.day,
        ),
    ];
    if (n <= 7) {
      return Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: cells[i]),
          ],
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [for (final c in cells) Padding(padding: const EdgeInsets.only(right: 6), child: SizedBox(width: 62, child: c))]),
    );
  }
}

enum _DayState { done, today, future }

class _DayCell extends StatefulWidget {
  const _DayCell({required this.day, required this.coins, required this.state, required this.isLast, required this.highlightToday});
  final int day;
  final int coins;
  final _DayState state;
  final bool isLast;
  final bool highlightToday;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    if (widget.state == _DayState.today && !BebuTheme.reducedMotion) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _DayCell old) {
    super.didUpdateWidget(old);
    if (widget.state == _DayState.today && !_pulse.isAnimating && !BebuTheme.reducedMotion) {
      _pulse.repeat(reverse: true);
    } else if (widget.state != _DayState.today && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.state == _DayState.today;
    final done = widget.state == _DayState.done;
    final justDone = done && widget.highlightToday;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final p = today ? _pulse.value : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: today
                ? BebuTheme.pink.withValues(alpha: 0.10 + 0.06 * p)
                : justDone
                    ? BebuTheme.green.withValues(alpha: 0.12)
                    : BebuTheme.surface,
            borderRadius: BorderRadius.circular(BebuTheme.radiusSm + 2),
            border: Border.all(
              color: today
                  ? BebuTheme.pink.withValues(alpha: 0.55 + 0.4 * p)
                  : justDone
                      ? BebuTheme.green.withValues(alpha: 0.6)
                      : BebuTheme.border,
              width: today ? 1.4 : 1,
            ),
            boxShadow: today ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.18 + 0.14 * p), blurRadius: 14)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isLast ? 'BIG' : 'Day ${widget.day}',
                style: BebuTheme.label(size: 9.5, color: widget.isLast ? BebuTheme.amber : (today ? BebuTheme.pink : BebuTheme.textFaint), weight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 20,
                child: done
                    ? Icon(Icons.check_circle_rounded, size: 18, color: justDone ? BebuTheme.green : BebuTheme.textFaint)
                    : Opacity(opacity: today ? 1 : 0.7, child: Coin3D(size: widget.isLast ? 20 : 17, yaw: today ? -0.2 : -0.6)),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt(widget.coins),
                style: BebuTheme.label(size: 11.5, color: done ? BebuTheme.textFaint : BebuTheme.text, weight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      tint: BebuTheme.violet.withValues(alpha: BebuTheme.isLight ? 0.10 : 0.18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), gradient: BebuTheme.violetGradient),
            child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome bonus unlocked', style: BebuTheme.label(size: 13.5)),
                const SizedBox(height: 2),
                Text('+${_fmt(coins)} coins are already in your wallet. Today’s gift comes on top.', style: BebuTheme.body(size: 12, color: BebuTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.until, required this.next});
  final Duration until;
  final int next;

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = until.inHours;
    final m = until.inMinutes % 60;
    final s = until.inSeconds % 60;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.borderStrong)),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 18, color: BebuTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next gift in ', style: BebuTheme.label(size: 13.5, color: BebuTheme.textMuted)),
                  Text('${two(h)}:${two(m)}:${two(s)}', style: BebuTheme.label(size: 15, weight: FontWeight.w800).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: BebuTheme.amber.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Coin3D(size: 12),
                const SizedBox(width: 4),
                Text('+${_fmt(next)}', style: BebuTheme.label(size: 11.5, color: BebuTheme.amber, weight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

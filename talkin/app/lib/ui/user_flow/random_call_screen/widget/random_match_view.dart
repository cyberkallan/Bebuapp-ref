import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/presence_badge.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/model/get_random_available_listener_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Match preview — shown after the backend picks a random available host.
///
/// A full-bleed portrait card with presence, rate and profile facts on the
/// photo; Skip / Say hello / Call below. Call and chat actions are unchanged
/// (fake-host branch, coin check, `SocketEmit.randomCallRinging`, chat route
/// arguments).
class RandomMatchView extends StatefulWidget {
  const RandomMatchView({super.key});

  @override
  State<RandomMatchView> createState() => _RandomMatchViewState();
}

class _RandomMatchViewState extends State<RandomMatchView> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: BebuTheme.isLight ? 0.8 : 1.6,
        child: SafeArea(
          child: GetBuilder<RandomCallController>(
            builder: (controller) {
              final d = controller.randomAvailableListenerModel?.data;
              final isAudio = controller.selectedIndex == 0;
              return Column(
                children: [
                  _TopBar(isAudio: isAudio),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: AnimatedBuilder(
                        animation: _intro,
                        builder: (context, child) {
                          final t = Curves.easeOutBack.transform(_intro.value.clamp(0, 1));
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              _MatchBurst(progress: _intro.value),
                              Transform.scale(scale: 0.86 + 0.14 * t, child: Opacity(opacity: Curves.easeOut.transform(_intro.value.clamp(0, 1)), child: child)),
                            ],
                          );
                        },
                        child: AnimatedSwitcher(
                          duration: BebuTheme.normal,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(a), child: child),
                          ),
                          child: _HostCard(key: ValueKey(d?.id ?? 'none'), d: d, isAudio: isAudio, busy: controller.isSkipping),
                        ),
                      ),
                    ),
                  ),
                  FadeSlideIn(
                    delayMs: 260,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: _Actions(
                        isAudio: isAudio,
                        busy: controller.isSkipping,
                        onSkip: () => _skip(controller),
                        onHello: () => _sayHello(controller),
                        onCall: () => _startCall(controller),
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

  Future<void> _skip(RandomCallController controller) async {
    if (controller.isSkipping) return;
    Sfx.tick();
    final previous = controller.randomAvailableListenerModel?.data?.id;
    final found = await controller.skipMatch();
    if (!mounted) return;
    if (!found) {
      Sfx.deny();
      Utils.showToast(context, 'No one else is free right now. Try again in a moment.');
      return;
    }
    if (controller.randomAvailableListenerModel?.data?.id == previous) {
      Utils.showToast(context, 'Only one host is free right now.');
    } else {
      Sfx.pop();
    }
  }

  void _startCall(RandomCallController controller) {
    final d = controller.randomAvailableListenerModel?.data;
    final isAudio = controller.selectedIndex == 0;
    final requiredCoins = isAudio ? d?.rateRandomAudioCall ?? 0 : d?.rateRandomVideoCall ?? 0;
    Sfx.select();

    if (d?.isFake == true) {
      Utils.showLog("fake call  ${d?.isFake}");
      Get.toNamed(
        AppRoutes.fakeOutgoingCall,
        arguments: [d?.name ?? '', d?.image ?? '', d?.video ?? '', d?.audio ?? '', isAudio ? "audio" : "video"],
      );
      return;
    }
    final coins = int.tryParse(Database.userCoin.toString()) ?? 0;
    if (coins < requiredCoins) {
      log("userCoin $coins < required $requiredCoins");
      Sfx.deny();
      Utils.showToast(Get.context!, "You have not enough coins.");
      Get.toNamed(AppRoutes.myWalletScreen);
      return;
    }
    SocketEmit.randomCallRinging(
      callerId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
      receiverId: d?.id ?? '',
      callType: isAudio ? "audio" : "video",
      callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
      receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
      receiverName: d?.name ?? '',
      receiverImage: d?.image ?? '',
      callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
      callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
    );
  }

  void _sayHello(RandomCallController controller) {
    final d = controller.randomAvailableListenerModel?.data;
    Sfx.tick();
    Get.toNamed(
      AppRoutes.personalChatScreen,
      arguments: [
        d?.id,
        d?.name,
        d?.isOnline,
        d?.image,
        d?.ratePrivateAudioCall,
        d?.ratePrivateVideoCall,
        d?.isFake,
        d?.video,
        d?.isAvailableForPrivateVideoCall,
        d?.isAvailableForPrivateAudioCall,
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isAudio});
  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.close_rounded, color: BebuTheme.surface, onTap: () => Get.back(), tooltip: 'Close'),
          const Spacer(),
          Column(
            children: [
              Text(EnumLocale.txtItsAMatch.name.tr, style: BebuTheme.title(size: 16)),
              const SizedBox(height: 2),
              Text('Someone is ready to talk', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
            ],
          ),
          const Spacer(),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
            child: Row(
              children: [
                Icon(isAudio ? Icons.call_rounded : Icons.videocam_rounded, size: 15, color: BebuTheme.violet),
                const SizedBox(width: 6),
                Text(isAudio ? 'Audio' : 'Video', style: BebuTheme.label(size: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanding rings that play once behind the card when a match lands.
class _MatchBurst extends StatelessWidget {
  const _MatchBurst({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress >= 1 || BebuTheme.reducedMotion) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _BurstPainter(progress: progress, color: BebuTheme.pink)),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = math.max(size.width, size.height) * 0.75;
    for (var i = 0; i < 3; i++) {
      final t = ((progress - i * 0.12) / 0.88).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(
        c,
        maxR * Curves.easeOut.transform(t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 - t
          ..color = color.withValues(alpha: (1 - t) * 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.progress != progress;
}

/// Full-bleed portrait with presence, rate and profile facts over the scrim.
class _HostCard extends StatelessWidget {
  const _HostCard({super.key, required this.d, required this.isAudio, required this.busy});
  final Data? d;
  final bool isAudio;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final rate = isAudio ? d?.rateRandomAudioCall : d?.rateRandomVideoCall;
    final presence = PresenceX.from(online: d?.isOnline ?? true, busy: d?.isBusy);
    final coins = int.tryParse(Database.userCoin) ?? 0;
    final minutes = (rate ?? 0) > 0 ? coins ~/ rate! : null;
    final radius = BorderRadius.circular(BebuTheme.radiusXl);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: BebuTheme.pink.withValues(alpha: BebuTheme.isLight ? 0.22 : 0.35), blurRadius: 40, offset: const Offset(0, 16)),
          BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.12 : 0.5), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ListenerPhoto(image: d?.image, scrim: true),
            // Extra bottom weight so the facts read over any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  PresencePill(presence: presence, onPhoto: true),
                  const Spacer(),
                  if (rate != null) _RateChip(rate: rate, isAudio: isAudio),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          d?.age == null ? (d?.name ?? '') : '${d?.name}, ${d?.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BebuTheme.display(size: 28, color: BebuTheme.onPhoto),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const VerifiedBadge(size: 22),
                    ],
                  ),
                  if ((d?.selfIntro ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(d!.selfIntro!, maxLines: 2, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 13.5, color: BebuTheme.onPhotoMuted, height: 1.35)),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if ((d?.rating ?? 0) > 0) _Fact(icon: Icons.star_rounded, label: d!.rating!.toStringAsFixed(1), tint: BebuTheme.amber),
                      if ((d?.callCount ?? 0) > 0) _Fact(icon: Icons.call_rounded, label: '${d!.callCount} calls'),
                      if ((d?.language ?? []).isNotEmpty) _Fact(icon: Icons.translate_rounded, label: d!.language!.take(2).join(' · ')),
                      for (final t in (d?.talkTopics ?? []).take(3)) _Fact(label: t),
                    ],
                  ),
                  if (minutes != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: minutes == 0 ? BebuTheme.red : BebuTheme.onPhotoMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            minutes == 0 ? 'Not enough coins for this call — top up to connect' : 'Your balance covers about $minutes min',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BebuTheme.body(size: 12, color: minutes == 0 ? BebuTheme.red : BebuTheme.onPhotoMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (busy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(child: SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 2.5, color: BebuTheme.onPhoto))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.rate, required this.isAudio});
  final int rate;
  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, size: 14, color: BebuTheme.amber),
          const SizedBox(width: 5),
          Text('$rate/min', style: BebuTheme.label(size: 12.5, color: BebuTheme.onPhoto)),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, this.icon, this.tint});
  final String label;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: tint ?? BebuTheme.onPhoto), const SizedBox(width: 4)],
          Text(label, style: BebuTheme.label(size: 11.5, color: BebuTheme.onPhoto)),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.isAudio, required this.busy, required this.onSkip, required this.onHello, required this.onCall});
  final bool isAudio;
  final bool busy;
  final VoidCallback onSkip;
  final VoidCallback onHello;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundAction(icon: Icons.refresh_rounded, label: 'Skip', onTap: busy ? null : onSkip),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: GhostButton(label: EnumLocale.txtsayHello.name.tr, icon: Icons.chat_bubble_outline_rounded, height: 54, onTap: onHello),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: GradientButton(
            label: isAudio ? EnumLocale.txtAudioCall.name.tr : EnumLocale.txtVideoCall.name.tr,
            icon: isAudio ? Icons.call_rounded : Icons.videocam_rounded,
            height: 54,
            gradient: BebuTheme.pinkGradient,
            glow: BebuTheme.pink,
            onTap: onCall,
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.92,
      onTap: onTap,
      child: Tooltip(
        message: label,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BebuTheme.surface,
            border: Border.all(color: BebuTheme.border),
          ),
          child: Icon(icon, size: 24, color: onTap == null ? BebuTheme.textFaint : BebuTheme.text),
        ),
      ),
    );
  }
}

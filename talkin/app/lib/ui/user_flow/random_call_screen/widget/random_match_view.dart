import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// "It's a match" — shown after the backend picks a random available caller.
///
/// Call and chat actions are unchanged from the original screen (fake-caller
/// branch, coin check, `SocketEmit.randomCallRinging`, chat route arguments).
class RandomMatchView extends StatefulWidget {
  const RandomMatchView({super.key});

  @override
  State<RandomMatchView> createState() => _RandomMatchViewState();
}

class _RandomMatchViewState extends State<RandomMatchView> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 1.6,
        child: SafeArea(
          child: GetBuilder<RandomCallController>(
            builder: (controller) {
              final d = controller.randomAvailableListenerModel?.data;
              final isAudio = controller.selectedIndex == 0;
              final rate = isAudio ? d?.rateRandomAudioCall : d?.rateRandomVideoCall;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        GlassIconButton(icon: Icons.close_rounded, color: BebuTheme.surface, onTap: () => Get.back(), tooltip: 'Close'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
                          child: Row(
                            children: [
                              Icon(isAudio ? Icons.call_rounded : Icons.videocam_rounded, size: 15, color: BebuTheme.violet),
                              const SizedBox(width: 6),
                              Text(isAudio ? EnumLocale.txtAudioCall.name.tr : EnumLocale.txtVideoCall.name.tr, style: BebuTheme.label(size: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _intro,
                        builder: (context, _) {
                          final t = Curves.easeOutBack.transform(_intro.value.clamp(0, 1));
                          return Transform.scale(
                            scale: 0.7 + 0.3 * t,
                            child: Opacity(opacity: _intro.value.clamp(0, 1), child: _MatchPortrait(image: d?.image, online: d?.isOnline ?? true)),
                          );
                        },
                      ),
                    ),
                  ),
                  FadeSlideIn(
                    delayMs: 250,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: GlassCard(
                        radius: BebuTheme.radiusLg,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(EnumLocale.txtItsAMatch.name.tr, style: BebuTheme.label(size: 12, color: BebuTheme.pink, weight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    d?.age == null ? (d?.name ?? '') : '${d?.name}, ${d?.age}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: BebuTheme.display(size: 26),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const VerifiedBadge(size: 20),
                              ],
                            ),
                            if ((d?.selfIntro ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(d!.selfIntro!, maxLines: 2, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 13)),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final t in (d?.talkTopics ?? []).take(3)) BebuChip(label: t, dense: true),
                                if ((d?.language ?? []).isNotEmpty) BebuChip(label: d!.language!.join(', '), dense: true, icon: Icons.translate_rounded),
                                if (rate != null) BebuChip(label: '$rate coins/min', dense: true, icon: Icons.monetization_on_rounded, foreground: BebuTheme.amber),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: GhostButton(
                                    label: EnumLocale.txtsayHello.name.tr,
                                    icon: Icons.chat_bubble_outline_rounded,
                                    height: 52,
                                    onTap: () => _sayHello(controller),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: GradientButton(
                                    label: isAudio ? EnumLocale.txtAudioCall.name.tr : EnumLocale.txtVideoCall.name.tr,
                                    icon: isAudio ? Icons.call_rounded : Icons.videocam_rounded,
                                    height: 52,
                                    gradient: BebuTheme.pinkGradient,
                                    glow: BebuTheme.pink,
                                    onTap: () => _startCall(controller),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  void _startCall(RandomCallController controller) {
    final d = controller.randomAvailableListenerModel?.data;
    final isAudio = controller.selectedIndex == 0;
    final requiredCoins = isAudio ? d?.rateRandomAudioCall ?? 0 : d?.rateRandomVideoCall ?? 0;

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

class _MatchPortrait extends StatefulWidget {
  const _MatchPortrait({required this.image, required this.online});
  final String? image;
  final bool online;

  @override
  State<_MatchPortrait> createState() => _MatchPortraitState();
}

class _MatchPortraitState extends State<_MatchPortrait> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.5).clamp(160.0, 240.0);
    return SizedBox(
      width: size * 1.9,
      height: size * 1.9,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Builder(builder: (_) {
                  final t = ((_c.value + i / 3) % 1.0);
                  return Container(
                    width: size + size * 0.9 * t,
                    height: size + size * 0.9 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BebuTheme.pink.withValues(alpha: (1 - t) * 0.5), width: 1.5),
                    ),
                  );
                }),
              child!,
            ],
          );
        },
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.45), blurRadius: 50)]),
          child: BebuAvatar(size: size, ring: true, online: widget.online, child: ListenerPhoto(image: widget.image, scrim: false)),
        ),
      ),
    );
  }
}

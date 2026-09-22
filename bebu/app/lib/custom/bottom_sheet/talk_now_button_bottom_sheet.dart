import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// "How do you want to connect?" — voice / video / message chooser shown
/// over a host card. The visual layer is on the design system; the three
/// actions keep the exact permission, coin-check and socket behaviour of the
/// original sheet.
class TalkNowButtonBottomSheet extends StatelessWidget {
  final String callerId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String callerName;
  final String receiverRole;
  final String callerRole;
  final String callerImage;
  final String audioCallRatePrivate;
  final String videoCallRatePrivate;
  final bool? isFake;
  final List fakeVideo;
  final String fakeAudio;
  final bool? availableForPrivateAudioCall;
  final bool? availableForPrivateVideoCall;
  final VoidCallback? chatOnTap;
  final bool showMessage;

  const TalkNowButtonBottomSheet({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.callerName,
    required this.receiverRole,
    required this.callerRole,
    required this.callerImage,
    required this.audioCallRatePrivate,
    required this.videoCallRatePrivate,
    this.isFake,
    required this.fakeVideo,
    this.availableForPrivateAudioCall,
    this.availableForPrivateVideoCall,
    required this.fakeAudio,
    this.chatOnTap,
    this.showMessage = true,
  });

  bool get _isUser => callerRole == "user";
  int get _balance => int.tryParse(Database.userCoin.toString()) ?? 0;
  int get _audioRate => int.tryParse(audioCallRatePrivate) ?? 0;
  int get _videoRate => int.tryParse(videoCallRatePrivate) ?? 0;
  bool get _showsRates => _isUser || Database.fetchLoginUserProfileModel?.user?.isListener == false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final showAudio = (availableForPrivateAudioCall == true && availableForPrivateVideoCall == true) || isFake == true || availableForPrivateAudioCall == true;
    final showVideo = (availableForPrivateAudioCall == true && availableForPrivateVideoCall == true) || isFake == true || availableForPrivateVideoCall == true;
    final canAffordAudio = !_isUser || _audioRate <= 0 || _balance >= _audioRate;
    final canAffordVideo = !_isUser || _videoRate <= 0 || _balance >= _videoRate;

    return Container(
      decoration: BoxDecoration(
        color: BebuTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)),
        border: Border(top: BorderSide(color: BebuTheme.borderStrong)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          _Header(name: receiverName, image: receiverImage, onClose: Get.back),
          const SizedBox(height: 16),
          if (_isUser) ...[
            _BalanceStrip(balance: _balance, audioRate: _audioRate),
            const SizedBox(height: 12),
          ],
          if (showAudio)
            _CallOption(
              icon: Icons.call_rounded,
              gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
              glow: BebuTheme.green,
              title: EnumLocale.txtAudioCall.name.tr,
              rate: _showsRates ? _audioRate : null,
              balance: _balance,
              affordable: canAffordAudio,
              onTap: _startAudio,
            ),
          if (showAudio && showVideo) const SizedBox(height: 10),
          if (showVideo)
            _CallOption(
              icon: Icons.videocam_rounded,
              gradient: BebuTheme.violetGradient,
              glow: BebuTheme.violet,
              title: EnumLocale.txtVideoCall.name.tr,
              rate: _showsRates ? _videoRate : null,
              balance: _balance,
              affordable: canAffordVideo,
              onTap: _startVideo,
            ),
          if (showMessage) ...[
            const SizedBox(height: 10),
            PressScale(
              scale: 0.985,
              onTap: () {
                HapticFeedback.selectionClick();
                chatOnTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: BebuTheme.surface,
                  borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                  border: Border.all(color: BebuTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.blue.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18)),
                      child: Icon(Icons.chat_bubble_rounded, size: 18, color: BebuTheme.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(EnumLocale.txtMessages.name.tr, style: BebuTheme.label(size: 14.5)),
                          const SizedBox(height: 2),
                          Text('Say hi first, no coins needed', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                        ],
                      ),
                    ),
                    BebuChip(label: EnumLocale.txtFreeCoin.name.tr, dense: true, background: BebuTheme.green.withValues(alpha: 0.18), foreground: BebuTheme.green),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: BebuTheme.textFaint),
              const SizedBox(width: 6),
              Expanded(child: Text(EnumLocale.txtSelectCallTypeNote.name.tr, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint))),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- actions

  void _startAudio() {
    Utils.showLog("audio call rate $audioCallRatePrivate video call rate $videoCallRatePrivate");

    if (isFake == true) {
      Get.back();
      Utils.showLog("this is fake Listener>>>>>>>>>");
      Get.toNamed(
        AppRoutes.fakeOutgoingCall,
        arguments: [receiverName, receiverImage, fakeVideo, fakeAudio, "audio"],
      );
      return;
    }

    if (callerRole == "user" && (int.parse(Database.userCoin.toString()) < int.parse(audioCallRatePrivate))) {
      log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()}");
      Get.back();
      Get.toNamed(AppRoutes.myWalletScreen);
      Utils.showToast(Get.context!, "You have not enough coins.");
      return;
    }

    PermissionHandler.onGetMicrophonePermission(
      onGranted: () async {
        SocketEmit.emitCallOutgoingRinging(
          callerId: callerId,
          receiverId: receiverId,
          callType: "audio",
          callerRole: callerRole,
          receiverRole: receiverRole,
          callerImage: callerImage,
          callerName: callerName,
          receiverImage: receiverImage,
          receiverName: receiverName,
        );
      },
    );
  }

  void _startVideo() {
    Utils.showLog("audio call rate $audioCallRatePrivate video call rate $videoCallRatePrivate");

    if (isFake == true) {
      Get.back();
      Utils.showLog("this is fake Listener>>>>>>>>>");
      PermissionHandler.onGetCameraPermission(
        onGranted: () {
          PermissionHandler.onGetMicrophonePermission(
            onGranted: () async {
              Get.toNamed(
                AppRoutes.fakeOutgoingCall,
                arguments: [receiverName, receiverImage, fakeVideo, fakeAudio, "video"],
              );
            },
          );
        },
      );
      return;
    }

    if (callerRole == "user" && (int.parse(Database.userCoin.toString()) < int.parse(videoCallRatePrivate))) {
      log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()} >>>>>>>>>>> $videoCallRatePrivate");
      Get.back();
      Get.toNamed(AppRoutes.myWalletScreen);
      Utils.showToast(Get.context!, "You have not enough coins");
      return;
    }

    PermissionHandler.onGetCameraPermission(
      onGranted: () {
        PermissionHandler.onGetMicrophonePermission(
          onGranted: () async {
            SocketEmit.emitCallOutgoingRinging(
              callerId: callerId,
              receiverId: receiverId,
              callType: "video",
              callerRole: callerRole,
              receiverRole: receiverRole,
              callerImage: callerImage,
              callerName: callerName,
              receiverImage: receiverImage,
              receiverName: receiverName,
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.image, required this.onClose});
  final String name;
  final String image;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BebuAvatar(size: 52, ring: true, child: ListenerPhoto(image: image, scrim: false, cacheWidth: 160)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.isEmpty ? EnumLocale.txtSelectCallType.name.tr : name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.title(size: 18)),
              const SizedBox(height: 2),
              Text('How do you want to connect?', style: BebuTheme.body(size: 12.5, color: BebuTheme.textMuted)),
            ],
          ),
        ),
        GlassIconButton(icon: Icons.close_rounded, size: 38, iconSize: 18, color: BebuTheme.surface, blur: false, onTap: onClose, tooltip: 'Close'),
      ],
    );
  }
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.balance, required this.audioRate});
  final int balance;
  final int audioRate;

  @override
  Widget build(BuildContext context) {
    final minutes = audioRate > 0 ? balance ~/ audioRate : null;
    final low = minutes != null && minutes < 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: low ? BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.16) : BebuTheme.surface,
        borderRadius: BorderRadius.circular(BebuTheme.radiusSm),
        border: Border.all(color: low ? BebuTheme.amber.withValues(alpha: 0.45) : BebuTheme.border),
      ),
      child: Row(
        children: [
          const Coin3D(size: 18),
          const SizedBox(width: 8),
          Text('$balance', style: BebuTheme.label(size: 13.5)),
          const SizedBox(width: 4),
          Text(minutes == null ? 'coins' : (low ? 'coins · running low' : 'coins · ≈ $minutes min of voice'), style: BebuTheme.body(size: 12, color: BebuTheme.textMuted)),
          const Spacer(),
          PressScale(
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.myWalletScreen);
            },
            child: Row(
              children: [
                Text('Top up', style: BebuTheme.label(size: 12.5, color: BebuTheme.pink)),
                Icon(Icons.chevron_right_rounded, size: 16, color: BebuTheme.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallOption extends StatelessWidget {
  const _CallOption({
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.title,
    required this.rate,
    required this.balance,
    required this.affordable,
    required this.onTap,
  });

  final IconData icon;
  final Gradient gradient;
  final Color glow;
  final String title;
  final int? rate; // null → don't show pricing (listener side)
  final int balance;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minutes = rate != null && rate! > 0 ? balance ~/ rate! : null;
    final subtitle = rate == null
        ? 'Start right away'
        : !affordable
            ? 'Not enough coins · tap to top up'
            : rate! <= 0
                ? 'Free'
                : '$rate coins/min${minutes != null ? ' · ≈ $minutes min left' : ''}';
    return PressScale(
      scale: 0.98,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
          gradient: gradient,
          boxShadow: [BoxShadow(color: glow.withValues(alpha: affordable ? 0.38 : 0.15), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        foregroundDecoration: affordable ? null : BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusLg), color: BebuTheme.bg.withValues(alpha: 0.35)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x33000000)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BebuTheme.title(size: 17, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 12.5, color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (rate != null && rate! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Coin3D(size: 14),
                    const SizedBox(width: 5),
                    Text('$rate', style: BebuTheme.label(size: 13, color: Colors.white, weight: FontWeight.w800)),
                    Text('/min', style: BebuTheme.body(size: 11, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              )
            else
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

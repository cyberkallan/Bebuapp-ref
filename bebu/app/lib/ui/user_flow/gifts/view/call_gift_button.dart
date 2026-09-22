import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/gifts/controller/gift_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';

/// Gift control for the voice/video call bars. Renders nothing unless gifts
/// are enabled for calls and the person on this device is the *user* in the
/// call (hosts receive gifts, they don't send them).
class CallGiftButton extends StatelessWidget {
  const CallGiftButton({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.callerRole,
    required this.receiverRole,
    required this.otherName,
    required this.otherImage,
    required this.callId,
    this.label,
  });

  final String? callerId;
  final String? receiverId;
  final String? callerRole;
  final String? receiverRole;
  final String? otherName;
  final String? otherImage;
  final String? callId;

  /// Voice-call bar shows a caption under each control; video bar does not.
  final String? label;

  String? get _listenerId {
    final cr = (callerRole ?? '').toLowerCase();
    final rr = (receiverRole ?? '').toLowerCase();
    if (cr == 'listener') return callerId;
    if (rr == 'listener') return receiverId;
    return null;
  }

  bool get _iAmTheUser {
    final cr = (callerRole ?? '').toLowerCase();
    final rr = (receiverRole ?? '').toLowerCase();
    final me = Database.loginUserId;
    if (cr == 'user' && callerId == me) return true;
    if (rr == 'user' && receiverId == me) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GiftController>(
      id: GiftController.idCatalog,
      init: GiftController.to,
      builder: (g) {
        final listenerId = _listenerId;
        if (!g.showInCall || listenerId == null || listenerId.isEmpty || !_iAmTheUser) return const SizedBox.shrink();
        return _PulseButton(
          label: label,
          onTap: () {
            Sfx.tick();
            g.open(context, GiftTarget(listenerId: listenerId, listenerName: otherName ?? '', listenerImage: otherImage ?? '', context: 'call', callId: callId));
          },
        );
      },
    );
  }
}

class _PulseButton extends StatefulWidget {
  const _PulseButton({required this.onTap, this.label});
  final VoidCallback onTap;
  final String? label;

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

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
    final button = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
          return Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.label == null ? 23 : 12),
              gradient: BebuTheme.pinkGradient,
              boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.25 + 0.3 * pulse), blurRadius: 14 + 6 * pulse, spreadRadius: 1 + 2 * pulse)],
            ),
            child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 24),
          );
        },
      ),
    );
    return PressScale(
      onTap: widget.onTap,
      scale: 0.9,
      child: widget.label == null
          ? button
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                button,
                const SizedBox(height: 6),
                Text(widget.label!, textAlign: TextAlign.center, style: BebuTheme.label(size: 13, color: Colors.white, weight: FontWeight.w500)),
              ],
            ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

bool _isOnline(PersonalChatScreenController c) => c.receiverStatusLabel == "true" || c.receiverStatusLabel == "Available";

bool canCall(PersonalChatScreenController c) => c.availableForPrivateAudioCall == true || c.availableForPrivateVideoCall == true;

void openCallSheet(PersonalChatScreenController c) => ListenerActions.openTalkNow(
      showMessage: false,
      id: c.receiverId,
      name: c.receiverName,
      image: c.receiverImage,
      ratePrivateAudioCall: int.tryParse(c.ratePrivateAudioCall ?? ''),
      ratePrivateVideoCall: int.tryParse(c.ratePrivateVideoCall ?? ''),
      isFake: c.isFake,
      video: (c.fakeVideoUrl ?? []).map((e) => e.toString()).toList(),
      audio: c.fakeAudioUrl,
      isAvailableForPrivateVideoCall: c.availableForPrivateVideoCall,
      isAvailableForPrivateAudioCall: c.availableForPrivateAudioCall,
    );

/// Header: back, avatar, name + presence, call and profile shortcuts.
class DarkChatHeader extends StatelessWidget {
  const DarkChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (c) {
        final online = _isOnline(c);
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Row(
            children: [
              GlassIconButton(icon: Icons.arrow_back_rounded, color: BebuTheme.surface, onTap: () => Get.back(), tooltip: 'Back'),
              const SizedBox(width: 8),
              Expanded(
                child: PressScale(
                  scale: 0.98,
                  onTap: () => Get.toNamed(AppRoutes.profileDetailScreenView, arguments: c.receiverId),
                  child: Row(
                    children: [
                      BebuAvatar(size: 42, online: online, child: ListenerPhoto(image: c.receiverImage, scrim: false)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.receiverName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 16)),
                            const SizedBox(height: 2),
                            Text(
                              online ? EnumLocale.txtOnline.name.tr : EnumLocale.txtOffline.name.tr,
                              style: BebuTheme.body(size: 12, color: online ? BebuTheme.green : BebuTheme.textFaint),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (canCall(c))
                GlassIconButton(
                  icon: Icons.call_rounded,
                  color: BebuTheme.violet.withValues(alpha: 0.35),
                  onTap: () => openCallSheet(c),
                  tooltip: 'Call',
                ),
              const SizedBox(width: 6),
              GlassIconButton(
                icon: Icons.more_horiz_rounded,
                color: BebuTheme.surface,
                onTap: () => Get.toNamed(AppRoutes.profileDetailScreenView, arguments: c.receiverId),
                tooltip: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Centered "Today, Jun 12 2026" style divider.
class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider({super.key, required this.rawDate});
  final String? rawDate;

  static String label(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    DateTime? d;
    try {
      d = DateFormat('M/d/yyyy, hh:mm:ss a').parse(rawDate);
    } catch (_) {
      d = DateTime.tryParse(rawDate);
    }
    if (d == null) return '';
    final now = DateTime.now();
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day;
    final date = DateFormat('MMM d yyyy').format(d);
    if (sameDay) return 'Today, $date';
    if (isYesterday) return 'Yesterday, $date';
    return date;
  }

  /// Day key used to decide where dividers go.
  static String dayKey(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final d = DateFormat('M/d/yyyy, hh:mm:ss a').parse(rawDate);
      return '${d.year}-${d.month}-${d.day}';
    } catch (_) {
      final d = DateTime.tryParse(rawDate);
      return d == null ? '' : '${d.year}-${d.month}-${d.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = label(rawDate);
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
          child: Text(text, style: BebuTheme.label(size: 11.5, color: BebuTheme.textMuted)),
        ),
      ),
    );
  }
}

/// Text bubble: grey for the other person, violet gradient for me.
class DarkTextBubble extends StatelessWidget {
  const DarkTextBubble({super.key, required this.msg, required this.controller, this.isRead = false, this.showAvatar = true});
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final mine = msg.senderId == Database.loginUserId;
    final maxW = MediaQuery.sizeOf(context).width * 0.74;
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          gradient: mine ? const LinearGradient(colors: [Color(0xFFB03DFF), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          color: mine ? null : BebuTheme.surface2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(mine ? 20 : 6),
            bottomRight: Radius.circular(mine ? 6 : 20),
          ),
          boxShadow: mine ? [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Text(msg.message ?? '', style: BebuTheme.body(size: 15, color: BebuTheme.text, height: 1.35)),
      ),
    );
    final meta = Padding(
      padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.failed)
            Text('Not sent · tap to retry', style: BebuTheme.body(size: 10.5, color: BebuTheme.red))
          else
            Text(controller.formatTimeFromDate(msg.date), style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)),
          if (mine) ...[
            const SizedBox(width: 4),
            DeliveryTicks(msg: msg, isRead: isRead),
          ],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            SizedBox(
              width: 30,
              height: 30,
              child: showAvatar ? ClipOval(child: ListenerPhoto(image: controller.receiverImage, scrim: false)) : null,
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: msg.failed ? () => controller.retry(msg) : null,
            child: AnimatedOpacity(
              duration: BebuTheme.fast,
              opacity: msg.pending ? 0.78 : 1,
              child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [bubble, meta]),
            ),
          ),
        ],
      ),
    );
  }
}

/// WhatsApp-style status glyph for my messages: clock while pending, one
/// grey tick when the server stored it, two blue ticks when read, red
/// exclamation when it failed.
class DeliveryTicks extends StatelessWidget {
  const DeliveryTicks({super.key, required this.msg, required this.isRead, this.size = 13, this.color});
  final PersonalChat msg;
  final bool isRead;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color c;
    if (msg.failed) {
      icon = Icons.error_outline_rounded;
      c = BebuTheme.red;
    } else if (msg.pending) {
      icon = Icons.schedule_rounded;
      c = color ?? BebuTheme.textFaint;
    } else if (isRead) {
      icon = Icons.done_all_rounded;
      c = BebuTheme.blue;
    } else {
      icon = Icons.done_rounded;
      c = color ?? BebuTheme.textFaint;
    }
    return AnimatedSwitcher(
      duration: BebuTheme.fast,
      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: child)),
      child: Icon(icon, key: ValueKey('$icon${c.toARGB32()}'), size: size, color: c),
    );
  }
}

/// Compact call log entry (message types 4 and 5).
class DarkCallBubble extends StatelessWidget {
  const DarkCallBubble({super.key, required this.msg, required this.controller, required this.isVideo});
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final mine = msg.senderId == Database.loginUserId;
    final missed = msg.callType == 3;
    final answered = msg.callType == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
            decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: BebuTheme.border)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: (missed ? BebuTheme.red : BebuTheme.violet).withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Icon(
                    missed ? (isVideo ? Icons.missed_video_call_rounded : Icons.phone_missed_rounded) : (isVideo ? Icons.videocam_rounded : Icons.call_rounded),
                    size: 18,
                    color: missed ? BebuTheme.red : BebuTheme.violet,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isVideo ? EnumLocale.txtVideoCall.name.tr : EnumLocale.txtAudioCall.name.tr, style: BebuTheme.label(size: 13.5)),
                    const SizedBox(height: 2),
                    Text(
                      missed ? 'Missed' : (answered ? (msg.callDuration ?? '00:00:00') : 'Declined'),
                      style: BebuTheme.body(size: 11.5, color: missed ? BebuTheme.red : BebuTheme.textFaint),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Text(controller.formatTimeFromDate(msg.date), style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Want to call Sophia? 30 coins/min" card shown above the composer.
class CallPermissionCard extends StatelessWidget {
  const CallPermissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (c) {
        if (!canCall(c)) return const SizedBox.shrink();
        final rate = c.availableForPrivateAudioCall == true ? c.ratePrivateAudioCall : c.ratePrivateVideoCall;
        final rateText = (rate == null || rate == 'null' || rate.isEmpty) ? 'Coins charged per minute' : '$rate coins/min';
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: GlassCard(
            onTap: () => openCallSheet(c),
            radius: BebuTheme.radiusLg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            tint: BebuTheme.violet.withValues(alpha: 0.18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.call_rounded, size: 18, color: BebuTheme.onPhoto),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Want to talk with ${c.receiverName ?? 'them'}?', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 14)),
                      const SizedBox(height: 2),
                      Text(rateText, style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Frosted composer: attach, text, and a single action button that is the
/// mic when the field is empty (hold to record, slide left to cancel) and a
/// gradient send arrow once there is text — the WhatsApp pattern.
class DarkChatComposer extends StatelessWidget {
  const DarkChatComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GetBuilder<PersonalChatScreenController>(
            id: Constant.idChangeAudioRecordingEvent,
            builder: (c) {
              final recording = c.isRecordingAudio;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: BebuTheme.fast,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(position: Tween(begin: const Offset(0, .25), end: Offset.zero).animate(a), child: child),
                      ),
                      child: recording ? const _RecordingBar(key: ValueKey('rec')) : _InputBar(key: const ValueKey('input'), c: c),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _ActionButton(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({super.key, required this.c});
  final PersonalChatScreenController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
      decoration: BoxDecoration(
        color: BebuTheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: BebuTheme.borderStrong),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.08 : 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GlassIconButton(
            icon: Icons.add_photo_alternate_outlined,
            size: 40,
            iconSize: 20,
            blur: false,
            color: BebuTheme.surface3,
            iconColor: BebuTheme.textMuted,
            onTap: () {
              Sfx.tick();
              c.showImagePickerDialog();
            },
            tooltip: 'Send a photo',
          ),
          Expanded(
            child: TextField(
              controller: c.messageController,
              style: BebuTheme.body(size: 15, color: BebuTheme.text),
              cursorColor: BebuTheme.violet,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: BebuTheme.body(size: 15, color: BebuTheme.textFaint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Replaces the input while holding the mic: pulsing red dot, timer, live
/// level bars and the "slide to cancel" hint that turns into a trash cue.
class _RecordingBar extends StatelessWidget {
  const _RecordingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      id: Constant.idChangeAudioRecordingEvent,
      builder: (c) {
        final cancel = c.recordCancelArmed;
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: (cancel ? BebuTheme.red.withValues(alpha: 0.16) : BebuTheme.surface).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: cancel ? BebuTheme.red.withValues(alpha: 0.7) : BebuTheme.red.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const _BlinkDot(),
              const SizedBox(width: 10),
              Text(CustomFormatAudioTime.convert(c.countTime), style: BebuTheme.label(size: 14, color: BebuTheme.text)),
              const SizedBox(width: 12),
              Expanded(
                child: GetBuilder<PersonalChatScreenController>(
                  id: Constant.idRecordLevel,
                  builder: (c) => _LevelBars(level: c.recordLevel, color: cancel ? BebuTheme.red : BebuTheme.violet),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: BebuTheme.fast,
                child: cancel
                    ? Row(
                        key: const ValueKey('trash'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: BebuTheme.red),
                          const SizedBox(width: 4),
                          Text('Release to cancel', style: BebuTheme.label(size: 12, color: BebuTheme.red)),
                        ],
                      )
                    : Row(
                        key: const ValueKey('hint'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left_rounded, size: 18, color: BebuTheme.textFaint),
                          Text('Slide to cancel', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlinkDot extends StatefulWidget {
  const _BlinkDot();
  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.25, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: BebuTheme.red, shape: BoxShape.circle)),
      );
}

/// A row of bars whose heights follow the microphone level.
class _LevelBars extends StatelessWidget {
  const _LevelBars({required this.level, required this.color});
  final double level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const n = 18;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(n, (i) {
        // Bell-shaped envelope so the middle bars move most.
        final env = 0.35 + 0.65 * (1 - ((i - (n - 1) / 2).abs() / ((n - 1) / 2)));
        final h = 4 + 20 * (level * env);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: 3,
          height: h,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.45 + 0.55 * level), borderRadius: BorderRadius.circular(2)),
        );
      }),
    );
  }
}

/// Mic (hold) ↔ send (tap). The mic grows and glows while recording.
class _ActionButton extends StatelessWidget {
  const _ActionButton();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      id: Constant.idSendMsg,
      builder: (c) => GetBuilder<PersonalChatScreenController>(
        id: Constant.idChangeAudioRecordingEvent,
        builder: (c) {
          final showSend = c.hasText && !c.isRecordingAudio;
          final recording = c.isRecordingAudio;
          final cancel = c.recordCancelArmed;
          final size = recording ? 64.0 : 52.0;
          final Widget button = AnimatedContainer(
            duration: BebuTheme.fast,
            curve: Curves.easeOutBack,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: showSend
                  ? BebuTheme.violetGradient
                  : LinearGradient(
                      colors: recording
                          ? (cancel ? [BebuTheme.red, BebuTheme.red] : [const Color(0xFFFF4D6D), BebuTheme.red])
                          : [BebuTheme.surface3, BebuTheme.surface3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                if (showSend || recording)
                  BoxShadow(color: (showSend ? BebuTheme.violet : BebuTheme.red).withValues(alpha: recording ? 0.55 : 0.45), blurRadius: recording ? 26 : 18, offset: const Offset(0, 6)),
              ],
            ),
            child: AnimatedSwitcher(
              duration: BebuTheme.fast,
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: child)),
              child: Icon(
                showSend ? Icons.send_rounded : (recording ? (cancel ? Icons.delete_rounded : Icons.mic_rounded) : Icons.mic_none_rounded),
                key: ValueKey('$showSend$recording$cancel'),
                size: recording ? 28 : 22,
                color: showSend || recording ? BebuTheme.onPhoto : BebuTheme.textMuted,
              ),
            ),
          );
          if (showSend) {
            return PressScale(scale: 0.88, onTap: c.sendMessage, child: button);
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Sfx.tick();
              Utils.showToast(Get.context!, EnumLocale.txtLongPressToEnableAudioRecording.name.tr);
            },
            onLongPressStart: (_) {
              if (!c.isSendingAudioFile) c.onLongPressStartMic();
            },
            onLongPressMoveUpdate: (d) => c.onLongPressMove(d.offsetFromOrigin),
            onLongPressEnd: (_) => c.onLongPressEndMic(),
            onLongPressCancel: () => c.onLongPressEndMic(),
            child: SizedBox(width: 64, height: 64, child: Center(child: button)),
          );
        },
      ),
    );
  }
}

/// Kept for callers; the recording state now lives inside the composer.
class RecordingIndicator extends StatelessWidget {
  const RecordingIndicator({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Voice note on the design system: play / pause, waveform that fills with
/// progress, duration, delivery ticks. Pending notes play the local file.
class DarkVoiceBubble extends StatefulWidget {
  const DarkVoiceBubble({super.key, required this.msg, required this.controller, this.isRead = false, this.showAvatar = true});
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;
  final bool showAvatar;

  @override
  State<DarkVoiceBubble> createState() => _DarkVoiceBubbleState();
}

class _DarkVoiceBubbleState extends State<DarkVoiceBubble> {
  AudioPlayer? _player;
  bool _playing = false;
  bool _loading = false;
  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;
  final List<StreamSubscription> _subs = [];

  static const int _bars = 34;

  late final List<double> _shape = _waveShape(widget.msg.localId ?? widget.msg.id ?? widget.msg.audio ?? '');

  static List<double> _waveShape(String seed) {
    // Deterministic pseudo-waveform per message so it looks like a real note.
    var h = seed.hashCode;
    return List.generate(_bars, (i) {
      h = 1103515245 * h + 12345;
      final r = ((h >> 16) & 0x7fff) / 0x7fff;
      final env = 0.45 + 0.55 * math.sin(math.pi * (i + 0.5) / _bars);
      return (0.18 + 0.82 * r) * env;
    });
  }

  Source get _source {
    final a = (widget.msg.audio ?? '').replaceAll('\\', '/');
    if (a.startsWith('/') || a.startsWith('file:')) return DeviceFileSource(a.replaceFirst('file://', ''));
    if (a.startsWith('http')) return UrlSource(a);
    return UrlSource('${Api.baseUrl}${a.startsWith('/') ? a.substring(1) : a}');
  }

  Future<void> _toggle() async {
    Sfx.tick();
    try {
      if (_player == null) {
        final p = AudioPlayer();
        _player = p;
        _subs.addAll([
          p.onDurationChanged.listen((d) => setState(() => _dur = d)),
          p.onPositionChanged.listen((d) => setState(() => _pos = d)),
          p.onPlayerComplete.listen((_) => setState(() {
                _playing = false;
                _pos = Duration.zero;
              })),
          p.onPlayerStateChanged.listen((s) => setState(() {
                _playing = s == PlayerState.playing;
                if (s == PlayerState.playing) _loading = false;
              })),
        ]);
      }
      if (_playing) {
        await _player!.pause();
      } else {
        setState(() => _loading = true);
        await _player!.play(_source);
      }
    } catch (e) {
      setState(() => _loading = false);
      Utils.showLog('voice play failed: $e');
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(1, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final mine = msg.senderId == Database.loginUserId;
    final progress = _dur.inMilliseconds == 0 ? 0.0 : (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0);
    final fg = mine ? BebuTheme.onPhoto : BebuTheme.text;
    final faint = mine ? BebuTheme.onPhoto.withValues(alpha: 0.7) : BebuTheme.textFaint;
    final width = MediaQuery.sizeOf(context).width * 0.68;

    final bubble = Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        gradient: mine ? const LinearGradient(colors: [Color(0xFFB03DFF), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: mine ? null : BebuTheme.surface2,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(mine ? 20 : 6),
          bottomRight: Radius.circular(mine ? 6 : 20),
        ),
        boxShadow: mine ? [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))] : null,
      ),
      child: Row(
        children: [
          PressScale(
            scale: 0.9,
            onTap: msg.pending || msg.failed ? null : _toggle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fg.withValues(alpha: mine ? 0.2 : 0.08), shape: BoxShape.circle),
              child: msg.pending || _loading
                  ? Padding(padding: const EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                  : Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: fg, size: 24),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: _dur == Duration.zero
                      ? null
                      : (d) {
                          final box = context.findRenderObject() as RenderBox?;
                          if (box == null) return;
                          final local = box.globalToLocal(d.globalPosition);
                          final w = width - 8 - 12 - 40 - 10;
                          final f = ((local.dx - 8 - 40 - 10) / w).clamp(0.0, 1.0);
                          _player?.seek(_dur * f);
                        },
                  child: SizedBox(
                    height: 30,
                    child: CustomPaint(painter: _WavePainter(_shape, progress, fg, faint)),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_playing || _pos > Duration.zero ? _fmt(_pos) : (_dur > Duration.zero ? _fmt(_dur) : 'Voice note'), style: BebuTheme.body(size: 11, color: faint)),
                    const Spacer(),
                    if (msg.failed)
                      Text('Not sent · tap to retry', style: BebuTheme.body(size: 10.5, color: mine ? const Color(0xFFFFD2DA) : BebuTheme.red))
                    else
                      Text(widget.controller.formatTimeFromDate(msg.date), style: BebuTheme.body(size: 10.5, color: faint)),
                    if (mine) ...[
                      const SizedBox(width: 4),
                      DeliveryTicks(msg: msg, isRead: widget.isRead, color: faint),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            SizedBox(
              width: 30,
              height: 30,
              child: widget.showAvatar ? ClipOval(child: ListenerPhoto(image: widget.controller.receiverImage, scrim: false)) : null,
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: msg.failed ? () => widget.controller.retry(msg) : null,
            child: AnimatedOpacity(duration: BebuTheme.fast, opacity: msg.pending ? 0.8 : 1, child: bubble),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.shape, this.progress, this.on, this.off);
  final List<double> shape;
  final double progress;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final n = shape.length;
    final gap = size.width / n;
    final w = math.max(2.0, gap * 0.55);
    final pOn = Paint()
      ..color = on
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w;
    final pOff = Paint()
      ..color = off.withValues(alpha: 0.55)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w;
    final cy = size.height / 2;
    for (var i = 0; i < n; i++) {
      final x = gap * i + gap / 2;
      final h = math.max(3.0, shape[i] * size.height);
      final p = (i + 0.5) / n <= progress ? pOn : pOff;
      canvas.drawLine(Offset(x, cy - h / 2), Offset(x, cy + h / 2), p);
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.progress != progress || o.on != on || o.shape != shape;
}

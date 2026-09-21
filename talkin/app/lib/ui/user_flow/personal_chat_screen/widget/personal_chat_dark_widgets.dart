import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
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
          Text(controller.formatTimeFromDate(msg.date), style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)),
          if (mine) ...[
            const SizedBox(width: 4),
            Icon(isRead ? Icons.done_all_rounded : Icons.done_rounded, size: 13, color: isRead ? BebuTheme.blue : BebuTheme.textFaint),
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
          Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [bubble, meta]),
        ],
      ),
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

/// Frosted composer: attach, text, mic (long-press) and gradient send.
class DarkChatComposer extends StatelessWidget {
  const DarkChatComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                decoration: BoxDecoration(
                  color: BebuTheme.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BebuTheme.borderStrong),
                ),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.add_photo_alternate_outlined,
                      size: 42,
                      iconSize: 20,
                      color: BebuTheme.surface3,
                      iconColor: BebuTheme.textMuted,
                      onTap: c.showImagePickerDialog,
                      tooltip: 'Send a photo',
                    ),
                    Expanded(
                      child: TextField(
                        controller: c.messageController,
                        style: BebuTheme.body(size: 15, color: BebuTheme.text),
                        cursorColor: BebuTheme.violet,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Message…',
                          hintStyle: BebuTheme.body(size: 15, color: BebuTheme.textFaint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    GetBuilder<PersonalChatScreenController>(
                      id: Constant.idChangeAudioRecordingEvent,
                      builder: (c) => GestureDetector(
                        onTap: () => Utils.showToast(Get.context!, EnumLocale.txtLongPressToEnableAudioRecording.name.tr),
                        onLongPressStart: (_) {
                          if (c.isSendingAudioFile == false) c.onLongPressStartMic();
                        },
                        onLongPressEnd: (_) {
                          if (c.isSendingAudioFile == false) c.onLongPressEndMic();
                        },
                        child: AnimatedContainer(
                          duration: BebuTheme.fast,
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.isRecordingAudio ? BebuTheme.red : BebuTheme.surface3,
                            boxShadow: c.isRecordingAudio ? [BoxShadow(color: BebuTheme.red.withValues(alpha: 0.5), blurRadius: 18)] : null,
                          ),
                          child: Icon(c.isRecordingAudio ? Icons.mic_rounded : Icons.mic_none_rounded, size: 20, color: c.isRecordingAudio ? BebuTheme.text : BebuTheme.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GetBuilder<PersonalChatScreenController>(
                      id: Constant.idSendMsg,
                      builder: (c) => PressScale(
                        scale: 0.9,
                        onTap: c.sendMessage,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: BebuTheme.violetGradient,
                            boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 6))],
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, size: 22, color: BebuTheme.onPhoto),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating "recording" pill with the live timer.
class RecordingIndicator extends StatelessWidget {
  const RecordingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      id: Constant.idChangeAudioRecordingEvent,
      builder: (c) => AnimatedSlide(
        duration: BebuTheme.normal,
        curve: BebuTheme.curve,
        offset: c.isRecordingAudio ? Offset.zero : const Offset(0, 1.5),
        child: AnimatedOpacity(
          duration: BebuTheme.fast,
          opacity: c.isRecordingAudio ? 1 : 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.red.withValues(alpha: 0.6))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: BebuTheme.red, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('Recording ${CustomFormatAudioTime.convert(c.countTime)}', style: BebuTheme.label(size: 12.5)),
                const SizedBox(width: 8),
                Text('release to send', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/ringing_call_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/calling_screen/model/calling_history_response_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Direction / outcome of a history row.
enum CallKind {
  missed,
  incoming,
  outgoing;

  static CallKind of(String? statusText) {
    switch (statusText) {
      case 'Missed Call':
        return missed;
      case 'Incoming Call':
        return incoming;
      default:
        return outgoing;
    }
  }

  String get label => switch (this) { missed => 'Missed', incoming => 'Incoming', outgoing => 'Outgoing' };
  IconData get icon => switch (this) { missed => Icons.call_missed_rounded, incoming => Icons.call_received_rounded, outgoing => Icons.call_made_rounded };
  Color get color => switch (this) { missed => BebuTheme.red, incoming => BebuTheme.green, outgoing => BebuTheme.blue };
}

/// Filter chips above the list: all / missed / incoming / outgoing.
class CallFilter {
  const CallFilter(this.kind, this.label);
  final CallKind? kind;
  final String label;

  static const all = [CallFilter(null, 'All'), CallFilter(CallKind.missed, 'Missed'), CallFilter(CallKind.incoming, 'Incoming'), CallFilter(CallKind.outgoing, 'Outgoing')];
}

/// Parses `createdAt` (ISO) or the API's `date` string.
DateTime? callDate(CallHistory h) {
  if (h.createdAt != null) return h.createdAt!.toLocal();
  final raw = h.date?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

/// "Today", "Yesterday", "Mon, 14 Sep" or "14 Sep 2025".
String dayLabel(DateTime? d) {
  if (d == null) return 'Earlier';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return DateFormat('EEEE').format(d);
  if (d.year == now.year) return DateFormat('EEE, d MMM').format(d);
  return DateFormat('d MMM yyyy').format(d);
}

/// "00:04:32" -> "4m 32s", "01:02:03" -> "1h 2m".
String prettyDuration(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final parts = raw.split(':').map((p) => int.tryParse(p) ?? 0).toList();
  if (parts.length != 3) return raw;
  final h = parts[0], m = parts[1], s = parts[2];
  if (h == 0 && m == 0 && s == 0) return '';
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

/// Title, subtitle and (unblurred) notifications shortcut.
class CallsHeader extends StatelessWidget {
  const CallsHeader({required this.count, required this.loading, required this.missed, super.key});
  final int count;
  final bool loading;
  final int missed;

  @override
  Widget build(BuildContext context) {
    final subtitle = loading
        ? 'Loading your calls…'
        : count == 0
            ? 'No calls yet'
            : '$count ${count == 1 ? 'call' : 'calls'}${missed > 0 ? ' · $missed missed' : ''}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(EnumLocale.txtCalling.name.tr, style: BebuTheme.display(size: 30)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: BebuTheme.fast,
                  child: Text(subtitle, key: ValueKey(subtitle), style: BebuTheme.body(size: 13, color: BebuTheme.textFaint)),
                ),
              ],
            ),
          ),
          GlassIconButton(
            icon: Icons.notifications_none_rounded,
            size: 42,
            color: BebuTheme.surface,
            blur: false,
            onTap: () => Get.toNamed(AppRoutes.userNotificationView),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class CallFilterRow extends StatelessWidget {
  const CallFilterRow({required this.selected, required this.onChanged, required this.counts, super.key});
  final CallFilter selected;
  final ValueChanged<CallFilter> onChanged;
  final Map<CallKind?, int> counts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          for (final f in CallFilter.all) ...[
            BebuChip(
              label: counts[f.kind] == null || counts[f.kind] == 0 ? f.label : '${f.label} ${counts[f.kind]}',
              icon: f.kind?.icon,
              dotColor: f.kind == null ? null : f.kind!.color,
              selected: identical(f, selected),
              onTap: () => onChanged(f),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Sticky-looking day divider.
class CallDayHeader extends StatelessWidget {
  const CallDayHeader(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Text(label, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: BebuTheme.border)),
        ],
      ),
    );
  }
}

/// One call: avatar with presence, name, direction + duration, time, coins,
/// and a call button that rings while the host is online.
class CallHistoryRow extends StatelessWidget {
  const CallHistoryRow({required this.item, required this.index, super.key});
  final CallHistory item;
  final int index;

  bool get _canCall => item.isAvailableForPrivateAudioCall == true || item.isAvailableForPrivateVideoCall == true || item.isFake == true;

  @override
  Widget build(BuildContext context) {
    final kind = CallKind.of(item.callStatusText);
    final when = callDate(item);
    final duration = prettyDuration(item.duration);
    final coins = (item.coin ?? 0);
    final online = item.isOnline == true;

    return FadeSlideIn(
      delayMs: (index % 8) * 30,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        onTap: () => openTalkNow(item),
        child: Row(
          children: [
            BebuAvatar(
              size: 54,
              online: online,
              child: ListenerPhoto(image: item.image, scrim: false, cacheWidth: 160),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.title(size: 15.5))),
                      if (coins > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 2, 8, 2),
                          decoration: BoxDecoration(color: BebuTheme.amber.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(AppAsset.starCoin, width: 12, height: 12),
                              const SizedBox(width: 4),
                              Text(coins.toString(), style: BebuTheme.label(size: 11, color: BebuTheme.amber)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(kind.icon, size: 15, color: kind.color),
                      const SizedBox(width: 4),
                      Text(kind.label, style: BebuTheme.label(size: 12, color: kind.color)),
                      if (duration.isNotEmpty) ...[
                        Text('  ·  ', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                        Icon(Icons.timer_outlined, size: 13, color: BebuTheme.textFaint),
                        const SizedBox(width: 3),
                        Text(duration, style: BebuTheme.body(size: 12, color: BebuTheme.textMuted)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    when == null ? (item.date?.toString() ?? '') : DateFormat('h:mm a').format(when),
                    style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RingingCallButton(
              icon: _canCall ? Icons.call_rounded : Icons.chat_bubble_rounded,
              ringing: _canCall && online,
              size: 44,
              iconSize: 20,
              gradient: _canCall ? BebuTheme.pinkGradient : null,
              color: _canCall ? null : BebuTheme.surface2,
              iconColor: _canCall ? BebuTheme.onPhoto : BebuTheme.text,
              ringColor: BebuTheme.pink,
              glow: _canCall && online ? BebuTheme.pink : null,
              onTap: () => openTalkNow(item),
              semanticLabel: _canCall ? 'Call ${item.name}' : 'Message ${item.name}',
            ),
          ],
        ),
      ),
    );
  }

  /// Same audio/video/chat sheet the old row opened; chat if no call is possible.
  static void openTalkNow(CallHistory h) {
    final canCall = h.isAvailableForPrivateAudioCall == true || h.isAvailableForPrivateVideoCall == true || h.isFake == true;
    void openChat() {
      Get.toNamed(
        AppRoutes.personalChatScreen,
        arguments: [h.id, h.name, h.isOnline, h.image, h.ratePrivateAudioCall, h.ratePrivateVideoCall, h.isFake, h.video, h.isAvailableForPrivateVideoCall, h.isAvailableForPrivateAudioCall],
      );
    }

    if (!canCall) {
      if (h.isAvailableForChat == true || h.isFake == true) {
        openChat();
      } else {
        Utils.showToast(Get.context!, 'Listener is not available', toastLength: Toast.LENGTH_SHORT);
      }
      return;
    }

    final me = Database.fetchLoginUserProfileModel?.user;
    Get.bottomSheet(
      TalkNowButtonBottomSheet(
        chatOnTap: openChat,
        availableForPrivateAudioCall: h.isAvailableForPrivateAudioCall ?? false,
        availableForPrivateVideoCall: h.isAvailableForPrivateVideoCall ?? false,
        isFake: h.isFake ?? false,
        fakeVideo: h.video ?? [],
        fakeAudio: h.audio ?? '',
        audioCallRatePrivate: h.ratePrivateAudioCall.toString(),
        videoCallRatePrivate: h.ratePrivateVideoCall.toString(),
        callerId: me?.id ?? '',
        receiverId: h.listenerId ?? '',
        receiverName: h.name ?? '',
        receiverImage: h.image ?? '',
        callerName: me?.fullName ?? '',
        callerImage: me?.profilePic ?? '',
        callerRole: me?.isListener == false ? 'user' : 'listener',
        receiverRole: me?.isListener == false ? 'listener' : 'user',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class CallsShimmer extends StatelessWidget {
  const CallsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: Column(
        children: [
          for (var i = 0; i < 7; i++)
            Container(
              height: 76,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd)),
            ),
        ],
      ),
    );
  }
}

class CallsEmpty extends StatelessWidget {
  const CallsEmpty({required this.filtered, required this.onExplore, super.key});
  final bool filtered;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: BebuTheme.violetGradient, boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.4), blurRadius: 30)]),
            child: const Icon(Icons.call_rounded, size: 36, color: BebuTheme.onPhoto),
          ),
          const SizedBox(height: 22),
          Text(filtered ? 'Nothing here' : 'No calls yet', textAlign: TextAlign.center, style: BebuTheme.title(size: 22)),
          const SizedBox(height: 8),
          Text(
            filtered ? 'Try another filter, or pull down to refresh.' : 'Your voice and video calls will show up here. Find someone you’d like to talk to.',
            textAlign: TextAlign.center,
            style: BebuTheme.body(),
          ),
          const SizedBox(height: 22),
          if (!filtered) GradientButton(label: 'Explore callers', icon: Icons.explore_rounded, expanded: false, height: 50, onTap: onExplore),
        ],
      ),
    );
  }
}

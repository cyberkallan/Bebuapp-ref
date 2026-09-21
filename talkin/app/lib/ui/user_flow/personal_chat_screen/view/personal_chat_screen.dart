import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/widget/personal_chat_dark_widgets.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/widget/personal_chat_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// One-to-one chat. Message rendering for photos and voice notes reuses the
/// existing widgets; text, calls, header and composer are the new dark set.
class PersonalChatScreen extends StatelessWidget {
  const PersonalChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      resizeToAvoidBottomInset: true,
      body: AuroraBackground(
        intensity: 0.8,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GetBuilder<PersonalChatScreenController>(
                id: Constant.idGetOldChat,
                builder: (controller) {
                  return Column(
                    children: [
                      const DarkChatHeader(),
                      GetBuilder<PersonalChatScreenController>(
                        id: Constant.idPagination,
                        builder: (c) => AnimatedSize(
                          duration: BebuTheme.fast,
                          child: c.isPaginationLoading
                              ? const LinearProgressIndicator(minHeight: 2, color: BebuTheme.violet, backgroundColor: Colors.transparent)
                              : const SizedBox(height: 2),
                        ),
                      ),
                      Expanded(
                        child: controller.isLoading
                            ? const _ChatShimmer()
                            : controller.oldChat.isEmpty
                                ? _EmptyConversation(name: controller.receiverName ?? '')
                                : SingleChildScrollView(
                                    controller: controller.scrollController,
                                    child: ListView.builder(
                                      reverse: true,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                      itemCount: controller.oldChat.length,
                                      itemBuilder: (context, index) => _messageAt(controller, index),
                                    ),
                                  ),
                      ),
                      const CallPermissionCard(),
                      const DarkChatComposer(),
                    ],
                  );
                },
              ),
              const Positioned(bottom: 84, child: RecordingIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  /// The list is reversed: index 0 is the newest message. A day divider is
  /// drawn above the first message of each day (i.e. when the *older*
  /// neighbour, index + 1, falls on a different day).
  Widget _messageAt(PersonalChatScreenController controller, int index) {
    final msg = controller.oldChat[index];
    final isLastMessage = index == 0;
    final older = index + 1 < controller.oldChat.length ? controller.oldChat[index + 1] : null;
    final newer = index > 0 ? controller.oldChat[index - 1] : null;
    final startsDay = older == null || ChatDateDivider.dayKey(older.date) != ChatDateDivider.dayKey(msg.date);
    // Show the avatar only on the last bubble of a run from the other person.
    final showAvatar = newer == null || newer.senderId != msg.senderId;

    final body = _bubble(controller, msg, isLastMessage: isLastMessage, showAvatar: showAvatar);
    if (!startsDay) return body;
    return Column(children: [ChatDateDivider(rawDate: msg.date), body]);
  }

  Widget _bubble(PersonalChatScreenController controller, PersonalChat msg, {required bool isLastMessage, required bool showAvatar}) {
    switch (msg.messageType) {
      case 1:
        return DarkTextBubble(msg: msg, controller: controller, isRead: msg.isRead ?? false, showAvatar: showAvatar);
      case 4:
        return DarkCallBubble(msg: msg, controller: controller, isVideo: false);
      case 5:
        return DarkCallBubble(msg: msg, controller: controller, isVideo: true);
      case 2:
        return _aligned(msg, ChatImageWidget(msg: msg, controller: controller, isRead: msg.isRead ?? false));
      case 3:
        final mine = msg.senderId == Database.loginUserId;
        return _aligned(
          msg,
          mine
              ? SenderAudioMessageWidget(audioUrl: msg.audio ?? "", time: msg.date ?? "", id: msg.id ?? "", chat: msg, isLastMessage: isLastMessage)
              : ReceiverAudioMessageWidget(audioUrl: msg.audio ?? "", time: msg.date ?? "", id: msg.id ?? "", chat: msg),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _aligned(PersonalChat msg, Widget child) => Align(
        alignment: msg.senderId == Database.loginUserId ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      );
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();

  @override
  Widget build(BuildContext context) {
    final widths = [0.55, 0.4, 0.65, 0.3, 0.5, 0.45];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      itemCount: widths.length,
      itemBuilder: (context, i) {
        final mine = i.isOdd;
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: BebuTheme.surface,
            highlightColor: BebuTheme.surface3,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: MediaQuery.sizeOf(context).width * widths[i],
              height: 44,
              decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(18)),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
                child: Icon(Icons.waving_hand_rounded, size: 32, color: BebuTheme.text),
              ),
              const SizedBox(height: 18),
              Text('Say hi to ${name.isEmpty ? 'them' : name}', textAlign: TextAlign.center, style: BebuTheme.title(size: 20)),
              const SizedBox(height: 6),
              Text('Start with something simple — a hello goes a long way.', textAlign: TextAlign.center, style: BebuTheme.body(size: 13.5)),
            ],
          ),
        ),
      ),
    );
  }
}

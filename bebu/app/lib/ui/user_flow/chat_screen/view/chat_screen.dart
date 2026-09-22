import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/chat_screen/api/chat_list_api.dart';
import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/model/chat_list_response_model.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Chat list: search field, glass rows with avatar, preview, time and unread.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: AuroraBackground(
          intensity: 0.7,
          child: SafeArea(
            bottom: false,
            child: GetBuilder<ChatScreenController>(
              id: Constant.idChatList,
              builder: (controller) {
                final bottomInset = MediaQuery.paddingOf(context).bottom;
                return RefreshIndicator(
                  color: BebuTheme.pink,
                  backgroundColor: BebuTheme.surface2,
                  onRefresh: () async => controller.onRefresh(),
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(EnumLocale.txtChats.name.tr, style: BebuTheme.display(size: 34)),
                              const SizedBox(height: 14),
                              _SearchField(onTap: () => Get.toNamed(AppRoutes.chatListSearchView)),
                            ],
                          ),
                        ),
                      ),
                      if (controller.isLoading)
                        const SliverPadding(padding: EdgeInsets.symmetric(horizontal: 16), sliver: _ChatListShimmer())
                      else if (controller.chatList.isEmpty)
                        const SliverFillRemaining(hasScrollBody: false, child: _ChatEmpty())
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList.separated(
                            itemCount: controller.chatList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final chat = controller.chatList[index];
                              return FadeSlideIn(
                                delayMs: (index % 8) * 35,
                                child: _ChatRow(chat: chat, onTap: () => _openChat(controller, chat)),
                              );
                            },
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: GetBuilder<ChatScreenController>(
                          id: Constant.idPaginationListener,
                          builder: (c) => AnimatedSize(
                            duration: BebuTheme.normal,
                            child: c.isPaginationLoading
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: BebuTheme.pink))),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 100 + bottomInset)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(ChatScreenController controller, ChatList chat) {
    Utils.showLog("receiver id ${chat.receiverId}");
    ListenerActions.openChat(
      id: chat.receiverId,
      name: chat.name,
      statusLabel: chat.isOnline?.toString(),
      image: chat.image,
      ratePrivateAudioCall: chat.ratePrivateAudioCall,
      ratePrivateVideoCall: chat.ratePrivateVideoCall,
      isFake: chat.isFake,
      video: chat.video,
      isAvailableForPrivateVideoCall: chat.isAvailableForPrivateVideoCall,
      isAvailableForPrivateAudioCall: chat.isAvailableForPrivateAudioCall,
    )?.then((_) {
      // Refresh so previews and unread counts reflect the conversation.
      ChatListApi.startPagination = 0;
      controller.chatList.clear();
      controller.getChatList();
    });
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.985,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: BebuTheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          border: Border.all(color: BebuTheme.border),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: BebuTheme.textFaint),
            const SizedBox(width: 10),
            Expanded(child: Text('Search chats', style: BebuTheme.body(size: 14, color: BebuTheme.textFaint))),
            Icon(Icons.tune_rounded, size: 18, color: BebuTheme.textFaint),
          ],
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.onTap});
  final ChatList chat;
  final VoidCallback onTap;

  String _preview() {
    switch (chat.messageType) {
      case 2:
        return 'Photo';
      case 3:
        return 'Voice message';
      case 4:
        return 'Voice call';
      case 5:
        return 'Video call';
      default:
        return chat.message ?? '';
    }
  }

  IconData? _previewIcon() {
    switch (chat.messageType) {
      case 2:
        return Icons.photo_rounded;
      case 3:
        return Icons.mic_rounded;
      case 4:
        return Icons.call_rounded;
      case 5:
        return Icons.videocam_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = chat.unreadCount ?? 0;
    final icon = _previewIcon();
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      tint: unread > 0 ? BebuTheme.violet.withValues(alpha: 0.16) : null,
      child: Row(
        children: [
          BebuAvatar(size: 50, online: chat.isOnline, child: ListenerPhoto(image: chat.image, scrim: false)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(chat.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 15))),
                    const SizedBox(width: 8),
                    Text(_time(), style: BebuTheme.body(size: 11, color: unread > 0 ? BebuTheme.pink : BebuTheme.textFaint)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (icon != null) ...[Icon(icon, size: 14, color: BebuTheme.textFaint), const SizedBox(width: 4)],
                    Expanded(
                      child: Text(
                        _preview(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BebuTheme.body(size: 13, color: unread > 0 ? BebuTheme.text : BebuTheme.textFaint, weight: unread > 0 ? FontWeight.w500 : FontWeight.w400),
                      ),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(gradient: BebuTheme.pinkGradient, borderRadius: BorderRadius.circular(999)),
                        child: Text(unread > 99 ? '99+' : '$unread', style: BebuTheme.label(size: 11, weight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _time() {
    final t = chat.lastChatMessageTime;
    if (t == null) return chat.time ?? '';
    final local = t.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (now.year == local.year && now.month == local.month && now.day == local.day) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year % 100}';
  }
}

class _ChatListShimmer extends StatelessWidget {
  const _ChatListShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: BebuTheme.surface,
        highlightColor: BebuTheme.surface3,
        child: Container(height: 74, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd))),
      ),
    );
  }
}

class _ChatEmpty extends StatelessWidget {
  const _ChatEmpty();

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 36, color: BebuTheme.text),
            ),
            const SizedBox(height: 22),
            Text('No conversations yet', textAlign: TextAlign.center, style: BebuTheme.title(size: 22)),
            const SizedBox(height: 8),
            Text('Say hello to a caller from Home or Explore and the chat will show up here.', textAlign: TextAlign.center, style: BebuTheme.body()),
          ],
        ),
      ),
    );
  }
}

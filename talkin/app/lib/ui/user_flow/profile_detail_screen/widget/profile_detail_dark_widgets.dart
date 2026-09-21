import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Tall hero photo card with name, verified badge and live status.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.data, required this.heroTag});

  final ListenerData data;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Container(
      height: (h * 0.56).clamp(380.0, 620.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 16))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(tag: heroTag, child: ListenerPhoto(image: data.image)),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.age == null ? (data.name ?? '') : '${data.name}, ${data.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BebuTheme.display(size: 30),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const VerifiedBadge(size: 22),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StatusPill(status: data.statusLabel),
                      const Spacer(),
                      GlassIconButton(
                        icon: Icons.copy_rounded,
                        size: 36,
                        iconSize: 15,
                        tooltip: 'Copy ID',
                        onTap: () {
                          final c = Get.find<ProfileDetailScreenController>();
                          if (c.isToastVisible) return;
                          Utils.copyText(data.uniqueId ?? '');
                          Utils.showToast(context, 'ID copied');
                          c.isToastVisible = true;
                          Future.delayed(const Duration(seconds: 3), () => c.isToastVisible = false);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Media strip: photo, intro videos and a rates tile.
class ProfileMediaStrip extends StatelessWidget {
  const ProfileMediaStrip({super.key, required this.data, required this.onVideoTap});
  final ListenerData data;
  final VoidCallback onVideoTap;

  @override
  Widget build(BuildContext context) {
    final videos = data.video ?? [];
    final tiles = <Widget>[
      _MediaTile(child: ListenerPhoto(image: data.image, scrim: false)),
      for (var i = 0; i < videos.take(2).length; i++)
        _MediaTile(
          onTap: onVideoTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListenerPhoto(image: data.image, scrim: false),
              Container(color: const Color(0x66000000)),
              const Center(child: Icon(Icons.play_arrow_rounded, color: BebuTheme.text, size: 30)),
            ],
          ),
        ),
      _RatesTile(audio: data.ratePrivateAudioCall, video: data.ratePrivateVideoCall),
    ];
    return SizedBox(
      height: 84,
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            Expanded(child: tiles[i]),
            if (i != tiles.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: ClipRRect(borderRadius: BorderRadius.circular(BebuTheme.radiusMd), child: child),
    );
  }
}

class _RatesTile extends StatelessWidget {
  const _RatesTile({required this.audio, required this.video});
  final int? audio;
  final int? video;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(gradient: BebuTheme.violetGradient, borderRadius: BorderRadius.circular(BebuTheme.radiusMd)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rate(Icons.call_rounded, audio),
          const SizedBox(height: 6),
          _rate(Icons.videocam_rounded, video),
        ],
      ),
    );
  }

  Widget _rate(IconData icon, int? rate) => Row(
        children: [
          Icon(icon, size: 14, color: BebuTheme.text),
          const SizedBox(width: 5),
          Text(rate == null ? '—' : '$rate/min', style: BebuTheme.label(size: 12)),
        ],
      );
}

/// Dark rounded section container with a title and optional trailing widget.
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BebuTheme.surface,
        borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
        border: Border.all(color: BebuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: BebuTheme.title(size: 19))),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// "About Me" with an expand/collapse chevron.
class ProfileAbout extends StatefulWidget {
  const ProfileAbout({super.key, required this.text});
  final String text;

  @override
  State<ProfileAbout> createState() => _ProfileAboutState();
}

class _ProfileAboutState extends State<ProfileAbout> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim().isEmpty ? 'This caller has not written an intro yet. Start a chat and say hi.' : widget.text.trim();
    return ProfileSection(
      title: 'About Me',
      trailing: GlassIconButton(
        icon: _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
        size: 34,
        iconSize: 20,
        color: BebuTheme.surface3,
        onTap: () => setState(() => _open = !_open),
      ),
      child: AnimatedSize(
        duration: BebuTheme.normal,
        curve: BebuTheme.curve,
        alignment: Alignment.topCenter,
        child: Text(text, maxLines: _open ? null : 3, overflow: _open ? null : TextOverflow.ellipsis, style: BebuTheme.body(size: 14, height: 1.55)),
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.data});
  final ListenerData data;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.call_rounded, (data.callCount ?? 0).toString(), EnumLocale.txtTotalCall.name.tr),
      (Icons.star_rounded, (data.rating ?? 0).toStringAsFixed(1), EnumLocale.txtRating.name.tr),
      (Icons.workspace_premium_rounded, data.experience == null ? '0+' : '${data.experience}+', EnumLocale.txtExperience.name.tr),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: BebuTheme.surface,
                borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                border: Border.all(color: BebuTheme.border),
              ),
              child: Column(
                children: [
                  Icon(items[i].$1, size: 18, color: i == 1 ? BebuTheme.amber : BebuTheme.violet),
                  const SizedBox(height: 6),
                  Text(items[i].$2, style: BebuTheme.title(size: 18)),
                  const SizedBox(height: 2),
                  Text(items[i].$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                ],
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class ProfileMoreInfo extends StatelessWidget {
  const ProfileMoreInfo({super.key, required this.data});
  final ListenerData data;

  static const _topicIcons = {
    'love': '❤️',
    'relationship': '💞',
    'music': '🎵',
    'movie': '🎬',
    'travel': '✈️',
    'food': '🍜',
    'fitness': '🏋️',
    'gym': '🏋️',
    'career': '💼',
    'study': '📚',
    'stress': '🧘',
    'motivation': '🔥',
    'friend': '🤝',
    'game': '🎮',
    'sport': '⚽',
    'cricket': '🏏',
  };

  String _emoji(String topic) {
    final t = topic.toLowerCase();
    for (final e in _topicIcons.entries) {
      if (t.contains(e.key)) return e.value;
    }
    return '💬';
  }

  @override
  Widget build(BuildContext context) {
    final topics = data.talkTopics ?? [];
    final languages = data.language ?? [];
    if (topics.isEmpty && languages.isEmpty) return const SizedBox.shrink();
    return ProfileSection(
      title: 'More Info',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in topics) BebuChip(label: '${_emoji(t)}  $t', background: BebuTheme.surface2),
          for (final l in languages) BebuChip(label: l, icon: Icons.translate_rounded, background: BebuTheme.surface2),
        ],
      ),
    );
  }
}

class ProfileReviews extends StatelessWidget {
  const ProfileReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.idGetListenerReview,
      builder: (controller) {
        final reviews = controller.reviews ?? [];
        if (reviews.isEmpty) return const SizedBox.shrink();
        return ProfileSection(
          title: EnumLocale.txtReviews.name.tr,
          trailing: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.allReviewScreen, arguments: controller.listenerId),
            child: Text(EnumLocale.txtViewAll.name.tr, style: BebuTheme.label(size: 13, color: BebuTheme.pink)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < reviews.take(3).length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(child: SizedBox(width: 40, height: 40, child: ListenerPhoto(image: reviews[i].profilePic, scrim: false))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(reviews[i].fullName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 14))),
                              Text(reviews[i].time ?? '', style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              for (var s = 0; s < 5; s++)
                                Icon(Icons.star_rounded, size: 14, color: s < (reviews[i].rating ?? 0) ? BebuTheme.amber : BebuTheme.surface3),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(reviews[i].review ?? '', style: BebuTheme.body(size: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i != reviews.take(3).length - 1) const Divider(color: BebuTheme.border, height: 24),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Floating frosted action bar: Chat + Call.
class ProfileActionBar extends StatelessWidget {
  const ProfileActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        final d = controller.listenerProfileModel?.data;
        if (controller.isLoading || d == null) return const SizedBox.shrink();
        final canCall = d.isAvailableForPrivateVideoCall == true || d.isAvailableForPrivateAudioCall == true || d.isFake == true;

        void openChat() => ListenerActions.openChat(
              id: d.id,
              name: d.name,
              statusLabel: d.statusLabel,
              image: d.image,
              ratePrivateAudioCall: d.ratePrivateAudioCall,
              ratePrivateVideoCall: d.ratePrivateVideoCall,
              isFake: d.isFake,
              video: d.video,
              isAvailableForPrivateVideoCall: d.isAvailableForPrivateVideoCall,
              isAvailableForPrivateAudioCall: d.isAvailableForPrivateAudioCall,
            );

        void openCall() => ListenerActions.openTalkNow(
              id: d.id,
              name: d.name,
              image: d.image,
              ratePrivateAudioCall: d.ratePrivateAudioCall,
              ratePrivateVideoCall: d.ratePrivateVideoCall,
              isFake: d.isFake,
              video: d.video,
              audio: d.audio,
              isAvailableForPrivateVideoCall: d.isAvailableForPrivateVideoCall,
              isAvailableForPrivateAudioCall: d.isAvailableForPrivateAudioCall,
            );

        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BebuTheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BebuTheme.border),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 12))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PressScale(
                          onTap: openChat,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(color: BebuTheme.surface3, borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: BebuTheme.text),
                                const SizedBox(width: 8),
                                Text(EnumLocale.txtChatNow.name.tr, style: BebuTheme.label(size: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (canCall) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: PressScale(
                            onTap: openCall,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: BebuTheme.pinkGradient,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.4), blurRadius: 22, offset: const Offset(0, 8))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.call_rounded, size: 18, color: BebuTheme.text),
                                  const SizedBox(width: 8),
                                  Text('Talk now', style: BebuTheme.label(size: 15, weight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileDarkShimmer extends StatelessWidget {
  const ProfileDarkShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double r = BebuTheme.radiusLg}) => Shimmer.fromColors(
          baseColor: BebuTheme.surface,
          highlightColor: BebuTheme.surface3,
          child: Container(height: h, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(r))),
        );
    return Column(
      children: [
        box(MediaQuery.sizeOf(context).height * 0.56, r: BebuTheme.radiusXl),
        const SizedBox(height: 14),
        box(84, r: BebuTheme.radiusMd),
        const SizedBox(height: 14),
        box(140),
        const SizedBox(height: 14),
        box(110),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/app_language_bottom_sheet.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/talk_about_bottom_sheet.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';

/// Explore: a two-column wall of photo cards with quick filters.
class ListenersScreen extends StatelessWidget {
  const ListenersScreen({super.key});

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
        body: SafeArea(
          bottom: false,
          child: GetBuilder<ListenersScreenController>(
            id: Constant.idAllListener,
            builder: (controller) {
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              final listeners = controller.visibleListeners;
              return RefreshIndicator(
                color: BebuTheme.pink,
                backgroundColor: BebuTheme.surface2,
                onRefresh: () => controller.onRefresh(),
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _ExploreHeader(controller: controller)),
                    SliverToBoxAdapter(child: _FilterRow(controller: controller)),
                    if (controller.isLoading)
                      const SliverPadding(padding: EdgeInsets.fromLTRB(16, 8, 16, 0), sliver: _GridShimmer())
                    else if (listeners.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ExploreEmpty(
                          liveOnly: controller.liveOnly,
                          filtered: controller.selectedLanguages.isNotEmpty || controller.selectedTopics.isNotEmpty,
                          onReset: () {
                            controller.liveOnly = false;
                            controller.clearSelectedLanguages();
                            controller.clearSelectedTopics();
                            controller.onRefresh();
                          },
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            childCount: listeners.length,
                            (context, index) {
                              final l = listeners[index];
                              final topic = (l.talkTopics ?? []).isNotEmpty ? l.talkTopics!.first : (l.language ?? []).firstOrNull;
                              return FadeSlideIn(
                                delayMs: (index % 6) * 40,
                                child: ListenerGridCard(
                                  heroTag: 'listener-photo-${l.id}',
                                  name: l.name ?? '',
                                  age: l.age,
                                  image: l.image,
                                  statusLabel: l.statusLabel,
                                  subtitle: topic,
                                  actionIcon: ListenerActions.canCall(l) ? Icons.call_rounded : Icons.chat_bubble_rounded,
                                  onTap: () => ListenerActions.openProfile(l),
                                  onAction: () => ListenerActions.canCall(l) ? ListenerActions.openTalkNowFor(l) : ListenerActions.openChatFor(l),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: GetBuilder<ListenersScreenController>(
                        id: Constant.idPaginationListener,
                        builder: (c) => AnimatedSize(
                          duration: BebuTheme.normal,
                          child: c.isPaginationLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 22),
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
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.controller});
  final ListenersScreenController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.visibleListeners.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore', style: BebuTheme.display(size: 34)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: BebuTheme.fast,
                  child: Text(
                    controller.isLoading ? 'Finding people to talk to…' : '$count ${count == 1 ? 'caller' : 'callers'} ready to talk',
                    key: ValueKey('$count-${controller.isLoading}'),
                    style: BebuTheme.body(size: 13, color: BebuTheme.textFaint),
                  ),
                ),
              ],
            ),
          ),
          GlassIconButton(
            icon: Icons.search_rounded,
            color: BebuTheme.surface,
            onTap: () => Get.toNamed(AppRoutes.searchScreen),
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});
  final ListenersScreenController controller;

  @override
  Widget build(BuildContext context) {
    final languages = controller.selectedLanguages;
    final topics = controller.selectedTopics.where((i) => i < controller.talkTopic.length).map((i) => controller.talkTopic[i].name ?? '').toList();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          BebuChip(
            label: 'Live now',
            icon: Icons.podcasts_rounded,
            selected: controller.liveOnly,
            onTap: controller.toggleLiveOnly,
          ),
          const SizedBox(width: 8),
          BebuChip(
            label: languages.isEmpty ? 'Language' : languages.length == 1 ? languages.first : '${languages.length} languages',
            icon: Icons.translate_rounded,
            selected: languages.isNotEmpty,
            onTap: () => Get.bottomSheet(AppLanguageBottomSheet(), isScrollControlled: true, backgroundColor: Colors.transparent),
            onRemove: languages.isEmpty
                ? null
                : () {
                    controller.clearSelectedLanguages();
                    controller.onRefresh();
                  },
          ),
          const SizedBox(width: 8),
          BebuChip(
            label: topics.isEmpty ? 'Topics' : topics.length == 1 ? topics.first : '${topics.length} topics',
            icon: Icons.forum_outlined,
            selected: topics.isNotEmpty,
            onTap: () => Get.bottomSheet(TalkAboutBottomSheet(), isScrollControlled: true, backgroundColor: Colors.transparent),
            onRemove: topics.isEmpty
                ? null
                : () {
                    controller.clearSelectedTopics();
                    controller.onRefresh();
                  },
          ),
        ],
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: 6,
        (_, __) => Shimmer.fromColors(
          baseColor: BebuTheme.surface,
          highlightColor: BebuTheme.surface3,
          child: Container(decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg))),
        ),
      ),
    );
  }
}

class _ExploreEmpty extends StatelessWidget {
  const _ExploreEmpty({required this.liveOnly, required this.filtered, required this.onReset});
  final bool liveOnly;
  final bool filtered;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final hasFilters = liveOnly || filtered;
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(gradient: BebuTheme.violetGradient, shape: BoxShape.circle),
              child: const Icon(Icons.travel_explore_rounded, size: 38, color: BebuTheme.text),
            ),
            const SizedBox(height: 22),
            Text(hasFilters ? 'No one matches these filters' : 'No callers yet', textAlign: TextAlign.center, style: BebuTheme.title(size: 22)),
            const SizedBox(height: 8),
            Text(
              hasFilters ? 'Try widening your filters, or clear them to see everyone.' : 'Pull down to refresh — new callers join every day.',
              textAlign: TextAlign.center,
              style: BebuTheme.body(),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 22),
              PressScale(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(color: BebuTheme.text, borderRadius: BorderRadius.circular(999)),
                  child: Text('Clear filters', style: BebuTheme.label(size: 14, color: BebuTheme.bg)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';
import 'package:talk_in/ui/user_flow/calling_screen/model/calling_history_response_model.dart';
import 'package:talk_in/ui/user_flow/calling_screen/widget/calling_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

/// Calls tab: themed call history grouped by day with direction filters.
/// Data loading and pagination stay in [CallingScreenController].
class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  CallFilter _filter = CallFilter.all.first;

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
          intensity: 0.6,
          child: SafeArea(
            bottom: false,
            child: GetBuilder<CallingScreenController>(
              id: Constant.idCallingHistory,
              builder: (controller) {
                final all = controller.callingHistory;
                final counts = <CallKind?, int>{null: all.length};
                for (final h in all) {
                  final k = CallKind.of(h.callStatusText);
                  counts[k] = (counts[k] ?? 0) + 1;
                }
                final visible = _filter.kind == null ? all : all.where((h) => CallKind.of(h.callStatusText) == _filter.kind).toList();

                return RefreshIndicator(
                  color: BebuTheme.pink,
                  backgroundColor: BebuTheme.surface2,
                  onRefresh: () async => controller.onRefresh(),
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: CallsHeader(count: all.length, loading: controller.isLoading, missed: counts[CallKind.missed] ?? 0)),
                      if (all.isNotEmpty || controller.isLoading)
                        SliverToBoxAdapter(child: CallFilterRow(selected: _filter, counts: counts, onChanged: (f) => setState(() => _filter = f))),
                      if (controller.isLoading)
                        const SliverPadding(padding: EdgeInsets.fromLTRB(20, 14, 20, 0), sliver: SliverToBoxAdapter(child: CallsShimmer()))
                      else if (visible.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: CallsEmpty(
                            filtered: all.isNotEmpty,
                            onExplore: () => Get.find<BottomBarController>().onClick(1),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          sliver: SliverList.builder(
                            itemCount: _rows(visible).length,
                            itemBuilder: (context, i) {
                              final row = _rows(visible)[i];
                              if (row is String) return CallDayHeader(row);
                              final h = row as CallHistory;
                              return Padding(padding: const EdgeInsets.only(bottom: 10), child: CallHistoryRow(item: h, index: i));
                            },
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: GetBuilder<CallingScreenController>(
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
                      // room for the floating nav bar
                      SliverToBoxAdapter(child: SizedBox(height: 96 + bottomInset)),
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

  /// Interleaves day labels (String) with rows (CallHistory). Cheap enough to
  /// recompute per build for a few hundred items.
  List<Object> _rows(List<CallHistory> items) {
    final out = <Object>[];
    String? last;
    for (final h in items) {
      final label = dayLabel(callDate(h));
      if (label != last) {
        out.add(label);
        last = label;
      }
      out.add(h);
    }
    return out;
  }
}

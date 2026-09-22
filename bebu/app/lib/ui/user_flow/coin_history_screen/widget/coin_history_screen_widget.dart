import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/range_picker/custom_range_picker.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/controller/coin_history_screen_controller.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Title bar with back button and the date-range filter chip.
class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (c) {
        final range = c.tabIndex == 0 ? c.selectedPaymentDateRange : c.selectedCoinDateRange;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
              const SizedBox(width: 12),
              Expanded(child: Text(EnumLocale.txtHistory.name.tr, style: BebuTheme.title(size: 20))),
              PressScale(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final picked = await CustomRangePicker.onShow(context, range);
                  if (picked != null) c.applyDateFilter(picked.start, picked.end);
                },
                child: Container(
                  height: 42,
                  padding: EdgeInsets.only(left: 12, right: range == null ? 12 : 4),
                  decoration: BoxDecoration(
                    color: range == null ? BebuTheme.surface : BebuTheme.pink.withValues(alpha: BebuTheme.isLight ? 0.1 : 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: range == null ? BebuTheme.border : BebuTheme.pink.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 17, color: range == null ? BebuTheme.textMuted : BebuTheme.pink),
                      const SizedBox(width: 6),
                      Text(
                        range == null ? 'All time' : '${Utils.formatShortDate(range.start)} – ${Utils.formatShortDate(range.end)}',
                        style: BebuTheme.label(size: 12.5, color: range == null ? BebuTheme.text : BebuTheme.pink),
                      ),
                      if (range != null)
                        GestureDetector(
                          onTap: c.clearDateFilter,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(padding: const EdgeInsets.all(8), child: Icon(Icons.close_rounded, size: 16, color: BebuTheme.pink)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Coins / Payments segmented switch.
class HistoryTabs extends StatelessWidget {
  const HistoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedPill(
            index: c.tabIndex == 0 ? 1 : 0,
            onChanged: (i) {
              HapticFeedback.selectionClick();
              c.changeTab(i == 0 ? 1 : 0);
            },
            segments: [
              SegmentItem(EnumLocale.txtCoin.name.tr, Icons.swap_vert_rounded),
              SegmentItem(EnumLocale.txtPayment.name.tr, Icons.receipt_long_rounded),
            ],
          ),
        );
      },
    );
  }
}

/// Body for the current tab: shimmer, empty state, or the grouped list.
class HistoryBody extends StatelessWidget {
  const HistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (c) {
        final payments = c.tabIndex == 0;
        if (c.isLoading && (payments ? c.purchaseCoinList.isEmpty : c.coinHistoryList.isEmpty)) return const _HistoryShimmer();

        if (payments) {
          if (c.purchaseCoinList.isEmpty) {
            return _HistoryEmpty(
              icon: Icons.receipt_long_rounded,
              title: 'No payments yet',
              body: c.selectedPaymentDateRange == null ? 'Your coin purchases and receipts will show here.' : 'Nothing in this date range.',
            );
          }
          return RefreshIndicator(
            color: BebuTheme.pink,
            backgroundColor: BebuTheme.surface,
            onRefresh: c.onPaymentRefresh,
            child: ListView.builder(
              controller: c.scrollController1,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: c.purchaseCoinList.length + (c.isPaginationLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= c.purchaseCoinList.length) return const _PagingSpinner();
                final item = c.purchaseCoinList[i];
                final prev = i == 0 ? null : c.purchaseCoinList[i - 1];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (prev == null || !_sameDay(prev.createdAt, item.createdAt)) _DayHeader(_dayLabel(item.createdAt)),
                    PaymentRow(item: item),
                  ],
                );
              },
            ),
          );
        }

        if (c.coinHistoryList.isEmpty) {
          return _HistoryEmpty(
            icon: Icons.swap_vert_rounded,
            title: 'No coin activity yet',
            body: c.selectedCoinDateRange == null ? 'Top-ups, bonuses and calls will appear here.' : 'Nothing in this date range.',
          );
        }
        return RefreshIndicator(
          color: BebuTheme.pink,
          backgroundColor: BebuTheme.surface,
          onRefresh: c.onRefresh,
          child: ListView.builder(
            controller: c.scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: c.coinHistoryList.length + (c.isPaginationLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= c.coinHistoryList.length) return const _PagingSpinner();
              final item = c.coinHistoryList[i];
              final prev = i == 0 ? null : c.coinHistoryList[i - 1];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prev == null || !_sameDay(prev.createdAt, item.createdAt)) _DayHeader(_dayLabel(item.createdAt)),
                  WalletActivityRow(item: item),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    final la = a.toLocal(), lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static String _dayLabel(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(l.year, l.month, l.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(l);
    return DateFormat(l.year == now.year ? 'd MMMM' : 'd MMM yyyy').format(l);
  }
}

/// One purchase: pack size, gateway, amount, receipt id (copyable).
class PaymentRow extends StatelessWidget {
  const PaymentRow({super.key, required this.item});
  final Datum item;

  @override
  Widget build(BuildContext context) {
    final time = item.createdAt == null ? (item.date ?? '') : DateFormat('h:mm a').format(item.createdAt!.toLocal());
    final id = item.uniqueId ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.16)),
            child: const CoinStack(count: 2, width: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('+${formatCoins(item.userCoin ?? 0)}', style: BebuTheme.label(size: 14, color: BebuTheme.green)),
                    const SizedBox(width: 4),
                    Text('coins', style: BebuTheme.label(size: 13.5)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [if ((item.paymentGateway ?? '').isNotEmpty) item.paymentGateway!, time].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$currencySymbol${formatPrice(item.price)}', style: BebuTheme.title(size: 15)),
              if (id.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: id));
                    HapticFeedback.selectionClick();
                    Utils.showToast(context, 'Receipt ID copied');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('#${id.length > 10 ? id.substring(id.length - 10) : id}', style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)),
                        const SizedBox(width: 3),
                        Icon(Icons.copy_rounded, size: 11, color: BebuTheme.textFaint),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 0, 8),
      child: Text(label.toUpperCase(), style: BebuTheme.label(size: 11, color: BebuTheme.textFaint, weight: FontWeight.w700)),
    );
  }
}

class _PagingSpinner extends StatelessWidget {
  const _PagingSpinner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: BebuTheme.pink))),
    );
  }
}

class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        children: [
          for (var i = 0; i < 7; i++)
            Container(height: 66, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd))),
        ],
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.violet.withValues(alpha: 0.16)),
              child: Icon(icon, size: 36, color: BebuTheme.violet),
            ),
            const SizedBox(height: 18),
            Text(title, style: BebuTheme.title(size: 18)),
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: BebuTheme.body(size: 13.5)),
          ],
        ),
      ),
    );
  }
}

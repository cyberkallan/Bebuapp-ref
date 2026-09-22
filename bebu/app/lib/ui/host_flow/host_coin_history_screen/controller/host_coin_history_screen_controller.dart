import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/api/host_coin_history_api.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/api/withdrawal_record_api.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/model/withdrawal_record_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class HostCoinHistoryScreenController extends GetxController {
  int tabIndex = 0;
  bool isLoading = false;
  HostCoinHistoryModel? coinHistoryModel;
  List<HostCoinHistory> hostCoinHistoryList = [];
  bool isPaginationLoading = false;

  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();
  WithdrawalRecordModel? withdrawalRecordModel;
  List<Datum> withdrawalRecordList = [];
  List<bool> isExpandedList = [];
  DateTimeRange? selectedCoinDateRange;
  DateTimeRange? selectedWithdrawDateRange;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    scrollController.addListener(onCoinHistoryPagination);
    scrollController1.addListener(onWithdrawalHistoryPagination);

    WithdrawalRecordApi.startPagination = 0;
    HostCoinHistoryApi.startPagination = 0;

    coinHistory();
    withdrawalRecord();
  }

  void changeTab(int index) {
    tabIndex = index;
    update([Constant.idTabChange]);
  }

  /// get coin history
  coinHistory() async {
    isLoading = true;
    update([Constant.idTabChange]);

    coinHistoryModel = await HostCoinHistoryApi.callApi(endDate: "All", startDate: "All");
    hostCoinHistoryList.clear();
    hostCoinHistoryList.addAll((coinHistoryModel?.data ?? []));

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// get withdrawal record
  withdrawalRecord() async {
    isLoading = true;
    update([Constant.idTabChange]);
    withdrawalRecordModel = await WithdrawalRecordApi.callApi(endDate: "All", startDate: "All");
    withdrawalRecordList.clear();
    withdrawalRecordList.addAll((withdrawalRecordModel?.data ?? []));

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// WithdrawalRecordApi refresh
  onRefresh() async {
    WithdrawalRecordApi.startPagination = 0;
    final range = selectedWithdrawDateRange;

    withdrawalRecordModel = await WithdrawalRecordApi.callApi(
      startDate: range != null ? Utils.formatDateToApi(range.start) : "All",
      endDate: range != null ? Utils.formatDateToApi(range.end) : "All",
    );
    withdrawalRecordList.clear();
    withdrawalRecordList.addAll((withdrawalRecordModel?.data ?? []));
    update([Constant.idTabChange]);
  }

  /// host coin history refresh
  refreshHostCoinHistory() async {
    HostCoinHistoryApi.startPagination = 0;
    final range = selectedCoinDateRange;
    coinHistoryModel = await HostCoinHistoryApi.callApi(
      startDate: range != null ? Utils.formatDateToApi(range.start) : "All",
      endDate: range != null ? Utils.formatDateToApi(range.end) : "All",
    );
    hostCoinHistoryList.clear();
    hostCoinHistoryList.addAll((coinHistoryModel?.data ?? []));
    update([Constant.idTabChange]);
  }

  /// coin history pagination
  Future<void> onCoinHistoryPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      final result = await HostCoinHistoryApi.callApi(
        endDate: selectedCoinDateRange != null ? Utils.formatDateToApi(selectedCoinDateRange!.end) : "All",
        startDate: selectedCoinDateRange != null ? Utils.formatDateToApi(selectedCoinDateRange!.start) : "All",
      );

      final newItems = result?.data ?? [];
      if (newItems.isNotEmpty) {
        hostCoinHistoryList.addAll(newItems);
      }

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idTabChange]);
    }
  }

  /// withdrawal history pagination
  Future<void> onWithdrawalHistoryPagination() async {
    if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      final result = await WithdrawalRecordApi.callApi(
        endDate: selectedWithdrawDateRange != null ? Utils.formatDateToApi(selectedWithdrawDateRange!.end) : "All",
        startDate: selectedWithdrawDateRange != null ? Utils.formatDateToApi(selectedWithdrawDateRange!.start) : "All",
      );
      final newItems = result?.data ?? [];
      if (newItems.isNotEmpty) {
        withdrawalRecordList.addAll(newItems);
      }

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idTabChange]);
    }
  }

  /// apply date filter
  Future<void> applyDateFilter(DateTime startDate, DateTime endDate) async {
    if (tabIndex == 1) {
      selectedWithdrawDateRange = DateTimeRange(start: startDate, end: endDate);
      withdrawalRecordList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      WithdrawalRecordApi.startPagination = 0;

      withdrawalRecordModel = await WithdrawalRecordApi.callApi(
        startDate: Utils.formatDateToApi(startDate),
        endDate: Utils.formatDateToApi(endDate),
      );
      withdrawalRecordList.addAll((withdrawalRecordModel?.data ?? []));
    } else {
      selectedCoinDateRange = DateTimeRange(start: startDate, end: endDate);
      hostCoinHistoryList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      HostCoinHistoryApi.startPagination = 0;

      coinHistoryModel = await HostCoinHistoryApi.callApi(
        startDate: Utils.formatDateToApi(startDate),
        endDate: Utils.formatDateToApi(endDate),
      );
      hostCoinHistoryList.addAll((coinHistoryModel?.data ?? []));
    }

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// clear filter
  void clearDateFilter() async {
    isLoading = true;
    if (tabIndex == 1) {
      selectedWithdrawDateRange = null;
      withdrawalRecordList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      WithdrawalRecordApi.startPagination = 0;

      withdrawalRecordModel = await WithdrawalRecordApi.callApi(
        startDate: "All",
        endDate: "All",
      );
      withdrawalRecordList.addAll((withdrawalRecordModel?.data ?? []));
    } else {
      // Clear coin date filter
      selectedCoinDateRange = null;
      hostCoinHistoryList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      HostCoinHistoryApi.startPagination = 0;

      coinHistoryModel = await HostCoinHistoryApi.callApi(
        startDate: "All",
        endDate: "All",
      );
      hostCoinHistoryList.addAll((coinHistoryModel?.data ?? []));
    }

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// Function to initialize the expansion state
  void initializeExpansionState(int itemCount) {
    Future.delayed(Duration.zero, () {
      if (isExpandedList.length != itemCount) {
        isExpandedList = List.generate(itemCount, (index) => false);
        update([Constant.idTabChange]); // Ensure this is called after the current build phase
      }
    });
  }

  /// Toggle the expanded/collapsed state for a particular item
  void toggleExpanded(int index) {
    if (index >= 0 && index < isExpandedList.length) {
      isExpandedList[index] = !isExpandedList[index];
      update([Constant.idTabChange]); // Update the UI after toggling the state
    }
  }
}

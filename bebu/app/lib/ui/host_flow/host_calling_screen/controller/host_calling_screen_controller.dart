import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/api/host_calling_history_api.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/model/host_calling_history_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class HostCallingScreenController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  HostCallingHistoryModel? hostCallingHistoryModel;
  List<HostCallHistory> callingHistory = [];
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    scrollController.addListener(onTopListenersPagination);

    HostCallingHistoryApi.startPagination = 0;
    await getCallingHistory();
  }

  /// get listener call history
  getCallingHistory() async {
    isLoading = true;
    update([Constant.idCallingHistory]);

    hostCallingHistoryModel =
        await HostCallingHistoryApi.callApi(endDate: "All", startDate: "All", listenerId: Database.fetchListenerProfileModel?.data?.id ?? '');
    callingHistory.addAll(hostCallingHistoryModel?.data ?? []);

    log("callingHistory.length ::::::  ${callingHistory.length}");

    log(" ::::: $callingHistory");
    log(" ::::: ${hostCallingHistoryModel?.data?.length}");

    isLoading = false;
    update([Constant.idCallingHistory]);
  }

  /// listener call history refresh
  onRefresh() async {
    HostCallingHistoryApi.startPagination = 0;
    callingHistory.clear();
    await getCallingHistory();
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      hostCallingHistoryModel =
          await HostCallingHistoryApi.callApi(endDate: "All", startDate: "All", listenerId: Database.fetchListenerProfileModel?.data?.id ?? '');
      callingHistory.addAll(hostCallingHistoryModel?.data ?? []);

      log("callingHistory.addAll :: ${callingHistory.length}");

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idCallingHistory]);
    }
  }
}

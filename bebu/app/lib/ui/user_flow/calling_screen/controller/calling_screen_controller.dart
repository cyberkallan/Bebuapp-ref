import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/calling_screen/api/calling_history_api.dart';
import 'package:talk_in/ui/user_flow/calling_screen/model/calling_history_response_model.dart';
import 'package:talk_in/utils/constant.dart';

class CallingScreenController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  CallingHistoryModel? callingHistoryResponseModel;
  List<CallHistory> callingHistory = [];
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    scrollController.addListener(onTopListenersPagination);

    CallingHistoryApi.startPagination = 0;
    await getCallingHistory();
  }

  /// get user call history
  getCallingHistory() async {
    isLoading = true;
    update([Constant.idCallingHistory]);

    callingHistoryResponseModel = await CallingHistoryApi.callApi(endDate: "All", startDate: "All");
    callingHistory.addAll(callingHistoryResponseModel?.data ?? []);

    log(" ::::: $callingHistory");
    log("callingHistory.addAll11111 :: ${callingHistory.length}");

    isLoading = false;
    update([Constant.idCallingHistory]);
  }

  onRefresh() async {
    CallingHistoryApi.startPagination = 0;
    callingHistory.clear();
    await getCallingHistory();
  }

  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      callingHistoryResponseModel = await CallingHistoryApi.callApi(endDate: "All", startDate: "All");
      callingHistory.addAll(callingHistoryResponseModel?.data ?? []);

      log("callingHistory.addAll :: ${callingHistory.length}");

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idCallingHistory]);
    }
  }
}

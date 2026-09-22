import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/constant.dart';

class AllListenersController extends GetxController {
  bool isLoading = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> allListener = [];
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;
  bool isBackProfile = false;

  @override
  void onInit() async {
    init();

    super.onInit();
  }

  init() async {
    log("Enter In all listener screen Controller");
    scrollController.addListener(onTopListenersPagination);

    AllListenersApi.startPagination = 0;
    await allListeners();
  }

  /// all listener api
  allListeners() async {
    isLoading = true;
    update([Constant.idGetListener]);

    topListenersModel = await AllListenersApi.callApi(searchString: "All");
    allListener.addAll(topListenersModel?.data ?? []);
    log("topListenersModel ::::: $allListener");

    isLoading = false;
    update([Constant.idGetListener]);
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      topListenersModel = await AllListenersApi.callApi(searchString: "All");
      allListener.addAll(topListenersModel?.data ?? []);
      log("topListenersModel ::::: $allListener");

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  /// refresh
  Future<void> onRefresh() async {
    AllListenersApi.startPagination = 0;
    allListener.clear();
    await allListeners();
  }
}

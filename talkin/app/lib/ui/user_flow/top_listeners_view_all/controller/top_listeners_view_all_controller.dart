import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';

class TopListenersViewAllController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> topListeners = [];
  TextEditingController allListenersSearch = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    log("Enter top all listener controller");
    getTopListeners();
    init();
    super.onInit();
  }

  @override
  void onClose() {
    log("close top all listener controller");
    TopListenersApi.startPagination = 0;
    super.onClose();
  }

  init() async {
    scrollController.addListener(onTopListenersPagination);
    TopListenersApi.startPagination = 0;
    // await getTopListeners();
  }

  /// get top listeners
  getTopListeners() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    isLoading = true;
    update([Constant.idGetListener]);

    topListenersModel = await TopListenersApi.callApi(token: token, uid: uid, searchString: "All");
    topListeners.addAll(topListenersModel?.data ?? []);

    isLoading = false;
    update([Constant.idGetListener]);
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      topListenersModel = await TopListenersApi.callApi(token: token, uid: uid, searchString: "All");
      topListeners.addAll(topListenersModel?.data ?? []);

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  /// refresh
  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();

    await getTopListeners();
  }
}

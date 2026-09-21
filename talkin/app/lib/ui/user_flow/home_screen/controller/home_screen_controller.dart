import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';

class HomeScreenController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> topListeners = [];
  TextEditingController allListenersSearch = TextEditingController();
  ScrollController scrollController = ScrollController();
  UserCoinModel? userCoinModel;
  bool isToastVisible = false;
  bool isCoinLoading = false;

  @override
  void onInit() {
    TopListenersApi.startPagination = 0;

    log("Enter home screen controller");
    getTopListeners();

    init();
    super.onInit();
  }

  init() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);

    log("Enter In Home screen Controller");
    scrollController.addListener(onTopListenersPagination);

    log("Enter In Home screen startPagination ${TopListenersApi.startPagination} ");
  }

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

  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
    update([Constant.idCoinUpdate]);

    await getTopListeners();
  }
}

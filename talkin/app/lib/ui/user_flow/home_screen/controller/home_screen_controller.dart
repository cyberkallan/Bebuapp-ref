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

  /// ---- Card deck state (redesigned home) ----

  /// 0 = For You (everyone), 1 = Live now (only "Available").
  int feedIndex = 0;

  /// Ids the user has swiped away in this session; they come back on refresh.
  final Set<String> dismissedIds = {};

  List<TopListeners> get deckListeners {
    final source = feedIndex == 1 ? topListeners.where((l) => l.statusLabel == "Available") : topListeners;
    return source.where((l) => !dismissedIds.contains(l.id ?? '')).toList();
  }

  void setFeed(int index) {
    if (feedIndex == index) return;
    feedIndex = index;
    update([Constant.idGetListener]);
  }

  void dismissListener(TopListeners l) {
    dismissedIds.add(l.id ?? '');
    update([Constant.idGetListener]);
    if (deckListeners.length < 4) loadMore();
  }

  /// Fetches the next page without depending on a scroll position.
  Future<void> loadMore() async {
    if (isPaginationLoading || isLoading) return;
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";
    isPaginationLoading = true;
    update([Constant.idPaginationListener]);
    final page = await TopListenersApi.callApi(token: token, uid: uid, searchString: "All");
    final known = topListeners.map((e) => e.id).toSet();
    final fresh = (page?.data ?? []).where((e) => !known.contains(e.id)).toList();
    if (fresh.isNotEmpty) {
      topListenersModel = page;
      topListeners.addAll(fresh);
    }
    isPaginationLoading = false;
    update([Constant.idPaginationListener, Constant.idGetListener]);
  }

  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    dismissedIds.clear();
    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
    update([Constant.idCoinUpdate]);

    await getTopListeners();
  }
}

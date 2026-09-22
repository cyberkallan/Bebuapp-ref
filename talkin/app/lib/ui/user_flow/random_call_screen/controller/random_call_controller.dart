import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/api/get_random_available_listener_api.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/model/get_random_available_listener_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class RandomCallController extends GetxController {
  int selectedIndex = 0;
  RandomAvailableListenerModel? randomAvailableListenerModel;
  bool isLoading = false;
  bool isBackProfile = false;
  UserCoinModel? userCoinModel;
  TopListenersModel? topListenersModel;
  List<TopListeners> allListener = [];
  List<TopListeners> randomDisplayList = [];
  final Random _random = Random();
  // bool randomCall = false;

  List<Duration> fadeDurations = [];
  List<Duration> delays = [];
  @override
  void onInit() {
    // randomCall = false;
    // Utils.showLog("Random call ============= $randomCall");

    super.onInit();
    init();
  }

  init() async {
    Utils.showLog("random screen controller");
    AllListenersApi.startPagination = 0;
    await allListeners();
    _initializeRandomListeners(); // ⬅️ Initialize after fetching

    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
    update([Constant.idCoinUpdate]);

    // Load listeners and shuffle them once at the beginning
    // shuffleAndUpdate();
  }

  getaAvailableListener() async {
    isLoading = true;
    update();

    randomAvailableListenerModel = await GetRandomAvailableListenerApi.callApi(callType: selectedIndex == 0 ? "audio" : "video", callMode: "random");

    Utils.showLog("randomAvailableListenerModel?.data   ::::${randomAvailableListenerModel?.data}");
    isLoading = false;
    update();
  }

  /// From the match preview: throw this one back and ask for another
  /// available host. Returns whether someone else was found.
  Future<bool> skipMatch() async {
    final previous = randomAvailableListenerModel?.data?.id;
    isSkipping = true;
    update();
    for (var attempt = 0; attempt < 2; attempt++) {
      randomAvailableListenerModel = await GetRandomAvailableListenerApi.callApi(callType: selectedIndex == 0 ? "audio" : "video", callMode: "random");
      final d = randomAvailableListenerModel?.data;
      if (d != null && (d.id != previous || attempt == 1)) break;
    }
    isSkipping = false;
    update();
    return randomAvailableListenerModel?.data != null;
  }

  bool isSkipping = false;

  int get liveCount => allListener.where((l) => l.statusLabel == 'Available' || l.isOnline == true).length;

  void selectCallType(int index) {
    selectedIndex = index;
    update();
    Utils.showLog("call type controller  ::::: ${selectedIndex == 0 ? "Audio" : "Video"}");
  }

  Future<void> allListeners() async {
    update([Constant.idGetListener]);

    topListenersModel = await AllListenersApi.callApi(searchString: "All");
    allListener = topListenersModel?.data ?? [];
    update([Constant.idGetListener]);
  }

  void _initializeRandomListeners() {
    final shuffled = List<TopListeners>.from(allListener)..shuffle();
    randomDisplayList = shuffled.take(4).toList();

    fadeDurations = List.generate(4, (_) => Duration(seconds: 3 + _random.nextInt(2)));
    delays = List.generate(4, (_) => Duration(milliseconds: 200 + _random.nextInt(1000)));

    update([Constant.idGetListener]);
  }

  void replaceListenerAt(int index) {
    final usedIds = randomDisplayList.map((e) => e.id).toSet();
    final available = allListener.where((e) => !usedIds.contains(e.id)).toList();
    if (available.isEmpty) return;

    final newListener = available[_random.nextInt(available.length)];

    randomDisplayList[index] = newListener;
    fadeDurations[index] = Duration(seconds: 3 + _random.nextInt(2));
    delays[index] = Duration(milliseconds: 200 + _random.nextInt(1000));

    update([Constant.idGetListener]);
  }
}

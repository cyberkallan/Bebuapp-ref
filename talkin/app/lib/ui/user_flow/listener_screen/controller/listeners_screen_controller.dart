import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/constant.dart';

class ListenersScreenController extends GetxController {
  int selectedIndex = 0;
  // int selectedTopic = 0;
  List<int> selectedTopics = [];

  List<TalkTopic> talkTopic = [];
  List<TopListeners> allListener = [];
  List<String> allLanguages = [];
  List<String> selectedLanguages = [];
  TalkTopicsModel? talkTopicsModel;
  TopListenersModel? topListenersModel;
  String languageSearchQuery = '';
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;
  bool isBackProfile = false;

  bool isLoading = false;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() {
    log("Enter In  listeners screen Controller");
    scrollController.addListener(onTopListenersPagination);

    AllListenersApi.startPagination = 0;
    allListeners();
    loadAllLanguages();
    getTalkTopic();
  }

  /// all listeners get
  allListeners() async {
    isLoading = true;
    update([Constant.idAllListener]);

    topListenersModel = await AllListenersApi.callApi(searchString: "All");
    allListener.addAll(topListenersModel?.data ?? []);
    log(" ::::: $allListener");

    isLoading = false;
    update([Constant.idAllListener]);
  }

  /// all language get
  Future<void> loadAllLanguages() async {
    try {
      final String response = await rootBundle.loadString('assets/all_language.json');
      final Map<String, dynamic> data = json.decode(response);

      allLanguages = data.values.map<String>((e) => e.toString()).toList();

      update();
    } catch (e, st) {
      log('Error loading languages: $e\n$st');
    }
  }

  /// selected language
  bool isSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// selected ui update
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
    update();
  }

  /// search language
  List<String> get filteredLanguages {
    if (languageSearchQuery.isEmpty) return allLanguages;
    return allLanguages.where((lang) => lang.toLowerCase().contains(languageSearchQuery.toLowerCase())).toList();
  }

  void updateLanguageSearchQuery(String query) {
    languageSearchQuery = query;
    update();
  }

  void clearSelectedLanguages() {
    selectedLanguages.clear();
    update();
  }

  /// filter by language api
  void filterListenerByLanguage() async {
    try {
      isLoading = true;
      update([Constant.idAllListener]);

      log('Selected Languages: ${selectedLanguages.join(', ')}');
      AllListenersApi.startPagination = 0;

      var data = await AllListenersApi.callApi(
        language: selectedLanguages.join(', '),
      );

      topListenersModel = data;
      allListener = data?.data ?? [];
      log("language filter  :: $allListener");
      for (var listener in allListener) {
        log('language filter Listener: ${listener.name}');
      }

      update([Constant.idAllListener]);
    } catch (e, st) {
      log('filter Listener By Listener error: $e\n$st');
    } finally {
      isLoading = false;
      update();
      log('filter Listener By Listener finally');
    }
  }

  /// get talk topic
  void getTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.talkAboutTopic]);
      var data = await TalkTopicApi.callApi();
      talkTopicsModel = data;

      talkTopic = data?.talkTopics ?? [];

      update([Constant.talkAboutTopic]);
    } catch (e, st) {
      log('getTalkTopicApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.talkAboutTopic]);
      log('getTalkTopicApi finally');
    }
  }

  /// select talk topic
  // void selectTopic(int index) {
  //   selectedTopic = index;
  //   log("talkTopic[selectedTopic].name  :: ${talkTopic[selectedTopic].name}");
  //   update([Constant.talkAboutTopic]);
  // }

  void selectTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
    update([Constant.talkAboutTopic]);
  }

  void clearSelectedTopics() {
    selectedTopics.clear();
    update([Constant.talkAboutTopic]);
  }

  /// filter by talk topic api
  // void filterListenerByTalkTopic() async {
  //   try {
  //     isLoading = true;
  //     update([Constant.idAllListener]);
  //     AllListenersApi.startPagination = 0;
  //
  //     var data = await AllListenersApi.callApi(
  //       talkTopic: talkTopic[selectedTopic].name,
  //     );
  //
  //     topListenersModel = data;
  //     allListener = data?.data ?? [];
  //     log('talk about filter Listener: $allListener');
  //
  //     for (var listener in allListener) {
  //       log('talk about filter Listener: ${listener.name}');
  //     }
  //   } catch (e, st) {
  //     log('filterListenerByTalkTopic error: $e\n$st');
  //   } finally {
  //     isLoading = false; // <-- Make sure to set loading false here
  //     update([Constant.idAllListener]);
  //     log('filterListenerByTalkTopic finally');
  //   }
  // }

  void filterListenerByTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.idAllListener]);

      AllListenersApi.startPagination = 0;

      // Collect topic names
      List<String> selectedTopicNames = selectedTopics.map((i) => talkTopic[i].name).whereType<String>().toList();

      var data = await AllListenersApi.callApi(
        talkTopic: selectedTopicNames.join(', '), // Send as comma-separated
      );

      topListenersModel = data;
      allListener = data?.data ?? [];

      log('Talk topic filter result: $allListener');
    } catch (e, st) {
      log('filterListenerByTalkTopic error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.idAllListener]);
    }
  }

  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      topListenersModel = await AllListenersApi.callApi(searchString: "All");
      allListener.addAll(topListenersModel?.data ?? []);
      log(" ::::: $allListener");

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idAllListener]);
    }
  }

  /// ---- Explore (redesigned) client-side filter ----
  bool liveOnly = false;

  List<TopListeners> get visibleListeners => liveOnly ? allListener.where((l) => l.statusLabel == "Available").toList() : allListener;

  void toggleLiveOnly() {
    liveOnly = !liveOnly;
    update([Constant.idAllListener]);
  }

  Future<void> onRefresh() async {
    AllListenersApi.startPagination = 0;
    allListener.clear(); // Clear the old data
    update([Constant.idAllListener]); // Notify UI
    await allListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/api/host_chat_list_search_api.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/model/host_chat_list_search_model.dart';

class HostChatListSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  bool hasText = false;
  bool isLoading = false;
  HostChatListSearchModel? hostChatListSearchModel;
  List<HostSearchChatList> displayedListeners = [];

  @override
  void onInit() {
    searchController.addListener(() {
      hasText = searchController.text.isNotEmpty;
      if (hasText) {
        searchChatUser(searchController.text);
      } else {
        displayedListeners.clear();
      }
      update();
    });
    super.onInit();
  }

  void clearText() {
    searchController.clear();
    hasText = false;
    displayedListeners.clear();
    update();
  }

  /// chat list search user api
  void searchChatUser(String query) async {
    if (query.isEmpty) {
      displayedListeners.clear();
      update();
      return;
    }

    isLoading = true;
    update();

    hostChatListSearchModel = await HostChatListSearchApi.callApi(searchString: query);

    if (hostChatListSearchModel != null && hostChatListSearchModel?.data != null) {
      displayedListeners = hostChatListSearchModel?.data ?? [];
    } else {
      displayedListeners.clear();
    }

    isLoading = false;
    update();
  }
}

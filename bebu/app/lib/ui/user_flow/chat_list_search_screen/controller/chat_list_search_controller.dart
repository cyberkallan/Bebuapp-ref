import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/chat_screen/api/chat_list_search_api.dart';
import 'package:talk_in/ui/user_flow/chat_screen/model/chat_list_search_model.dart';

class ChatListSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  bool hasText = false;
  bool isLoading = false;
  ChatListSearchModel? chatListSearchModel;
  List<ChatListSearch> displayedListeners = [];

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

  /// search text clear
  void clearText() {
    searchController.clear();
    hasText = false;
    displayedListeners.clear();
    update();
  }

  /// search chat list user api
  void searchChatUser(String query) async {
    if (query.isEmpty) {
      displayedListeners.clear();
      update();
      return;
    }

    isLoading = true;
    update();

    chatListSearchModel = await ChatListSearchApi.callApi(searchString: query);

    if (chatListSearchModel != null && chatListSearchModel?.data != null) {
      displayedListeners = chatListSearchModel?.data ?? [];
    } else {
      displayedListeners.clear();
    }

    isLoading = false;
    update();
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/chat_screen/api/chat_list_api.dart';
import 'package:talk_in/ui/user_flow/chat_screen/model/chat_list_response_model.dart';
import 'package:talk_in/utils/constant.dart';

class ChatScreenController extends GetxController {
  ChatListResponseModel? chatListResponseModel;
  bool isLoading = false;
  List<ChatList> chatList = [];

  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    log("Enter chat screen Controller");
    scrollController.addListener(onTopListenersPagination);
    ChatListApi.startPagination = 0;

    getChatList(); // Initial load of chat list
  }

  /// chat list user

  getChatList() async {
    isLoading = true;
    update([Constant.idChatList]);

    chatListResponseModel = await ChatListApi.callApi();
    chatList.addAll(chatListResponseModel?.chatList ?? []);
    log("Chat List Loaded: $chatList");

    isLoading = false;
    update([Constant.idChatList]);
  }

  onRefresh() async {
    ChatListApi.startPagination = 0;
    chatList.clear();
    await getChatList();
  }

  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);
      await getChatList();
      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }
}

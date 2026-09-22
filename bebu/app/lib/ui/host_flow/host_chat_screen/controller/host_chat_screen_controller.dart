import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/api/listener_chat_list_api.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/model/listener_chat_list_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class HostChatScreenController extends GetxController {
  ListenerChatListModel? listenerChatListModel;
  bool isLoading = false;
  List<ListenerChatList> listenerChatList = [];
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    log("Enter host chat screen Controller");
    scrollController.addListener(onTopListenersPagination);
    ListenerChatListApi.startPagination = 0;

    await getListenerChatList();
  }

  void clearChatList() {
    listenerChatList.clear();
    update([Constant.idChatList]);
  }

  /// listener chat list
  Future<void> getListenerChatList() async {
    isLoading = true;
    update([Constant.idChatList]);

    listenerChatListModel = await ListenerChatListApi.callApi(
      listenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
    );
    listenerChatList.addAll(listenerChatListModel?.chatList ?? []);

    isLoading = false;
    update([Constant.idChatList]);
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      await getListenerChatList();

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  /// refresh data
  Future<void> onRefresh() async {
    ListenerChatListApi.startPagination = 0;
    listenerChatList.clear();
    await getListenerChatList();
  }

}

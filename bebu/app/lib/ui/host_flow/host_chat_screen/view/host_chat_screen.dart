import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/api/listener_chat_list_api.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/controller/host_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/widget/host_chat_screen_widget.dart';
import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class HostChatScreen extends StatelessWidget {
  const HostChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const HostChatScreenAppBarView(),
        ),
        body: GetBuilder<HostChatScreenController>(
          id: Constant.idChatList,
          builder: (controller) {
            return controller.isLoading
                ? ChatListShimmer()
                : RefreshIndicator(
                    onRefresh: () async => controller.onRefresh(),
                    child: controller.listenerChatList.isEmpty
                        ? SizedBox(
                            height: Get.height,
                            child: Center(
                              child: Image.asset(
                                AppAsset.noChatFound,
                                height: 250,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.listenerChatList.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  HostChatViewItem(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.hostPersonalChatScreen,
                                        arguments: [
                                          controller.listenerChatList[index].id,
                                          controller.listenerChatList[index].fullName,
                                          controller.listenerChatList[index].isOnline,
                                          controller.listenerChatList[index].profilePic,
                                        ],
                                      )?.then(
                                        (value) async {
                                          ListenerChatListApi.startPagination = 0;
                                          controller.listenerChatList.clear();
                                          controller.getListenerChatList();
                                        },
                                      );
                                    },
                                    lastMsg: controller.listenerChatList[index].message ?? '',
                                    index: index,
                                    name: controller.listenerChatList[index].fullName ?? '',
                                    image: controller.listenerChatList[index].profilePic ?? '',
                                    unReadCount: controller.listenerChatList[index].unreadCount ?? 0,
                                    lastMsgTime: controller.listenerChatList[index].lastChatMessageTime.toString(),
                                  ).paddingOnly(left: 14, right: 14),
                                  Divider(
                                    color: AppColors.lightGrey,
                                    height: 0,
                                  )
                                ],
                              );
                            },
                          ),
                  );
          },
        ),
      ),
    );
  }
}

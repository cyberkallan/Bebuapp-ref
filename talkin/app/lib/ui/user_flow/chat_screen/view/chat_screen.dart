// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
// import 'package:talk_in/routes/app_routes.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
// import 'package:talk_in/utils/app_asset.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/constant.dart';
//
// class ChatScreen extends StatelessWidget {
//   const ChatScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (bool didPop) {
//         Get.dialog(
//           barrierColor: AppColors.black.withValues(alpha: 0.8),
//           Dialog(
//             backgroundColor: AppColors.transparent,
//             shadowColor: Colors.transparent,
//             surfaceTintColor: Colors.transparent,
//             elevation: 0,
//             child: const ExitAppDialog(),
//           ),
//         );
//         if (didPop) {
//           return;
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           flexibleSpace: const ChatScreenAppBarView(),
//         ),
//         body: GetBuilder<ChatScreenController>(
//           id: Constant.idChatList,
//           builder: (controller) {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   controller.isLoading
//                       ? ChatListShimmer()
//                       : controller.chatList.isEmpty
//                           ? Center(
//                               child: Image.asset(AppAsset.noChatFound, height: 300),
//                             )
//                           : ListView.builder(
//                               itemCount: controller.chatList.length,
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return Column(
//                                   children: [
//                                     ChatViewItem(
//                                       onTap: () {
//                                         Get.toNamed(AppRoutes.personalChatScreen, arguments: [
//                                           controller.chatList[index].receiverId,
//                                           controller.chatList[index].name,
//                                           controller.chatList[index].isOnline,
//                                           controller.chatList[index].image,
//                                         ]);
//                                       },
//                                       index: index,
//                                       name: controller.chatList[index].name ?? '',
//                                       lastMsg: controller.chatList[index].message ?? '',
//                                       image: controller.chatList[index].image ?? '',
//                                       unReadCount: controller.chatList[index].unreadCount ?? 0,
//                                       lastMsgTime: controller.chatList[index].lastChatMessageTime.toString(),
//                                     ).paddingOnly(left: 14, right: 14),
//                                     Divider(
//                                       color: AppColors.lightGrey,
//                                       height: 0,
//                                     )
//                                   ],
//                                 );
//                               },
//                             )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/chat_screen/api/chat_list_api.dart';
import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const ChatScreenAppBarView(),
        ),
        body: GetBuilder<ChatScreenController>(
          id: Constant.idChatList,
          builder: (controller) {
            return controller.isLoading
                ? ChatListShimmer()
                : RefreshIndicator(
                    onRefresh: () async => controller.onRefresh(),
                    child: controller.chatList.isEmpty
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
                            itemCount: controller.chatList.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ChatViewItem(
                                    onTap: () {
                                      Utils.showLog("receiver id ${controller.chatList[index].receiverId}");
                                      Utils.showLog("receiver name ${controller.chatList[index].name}");

                                      Get.toNamed(
                                        AppRoutes.personalChatScreen,
                                        arguments: [
                                          controller.chatList[index].receiverId,
                                          controller.chatList[index].name,
                                          controller.chatList[index].isOnline,
                                          controller.chatList[index].image,
                                          controller.chatList[index].ratePrivateAudioCall,
                                          controller.chatList[index].ratePrivateVideoCall,
                                          controller.chatList[index].isFake,
                                          controller.chatList[index].video,
                                          controller.chatList[index].isAvailableForPrivateVideoCall,
                                          controller.chatList[index].isAvailableForPrivateAudioCall,
                                        ],
                                      )?.then(
                                        (value) async {
                                          ChatListApi.startPagination = 0;
                                          controller.chatList.clear();
                                          controller.getChatList();
                                        },
                                      );
                                    },
                                    index: index,
                                    name: controller.chatList[index].name ?? '',
                                    lastMsg: controller.chatList[index].message ?? '',
                                    image: controller.chatList[index].image ?? '',
                                    unReadCount: controller.chatList[index].unreadCount ?? 0,
                                    lastMsgTime: controller.chatList[index].lastChatMessageTime.toString(),
                                  ).paddingOnly(left: 14, right: 14),
                                  Divider(
                                    color: AppColors.lightGrey,
                                    height: 0,
                                  ),
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

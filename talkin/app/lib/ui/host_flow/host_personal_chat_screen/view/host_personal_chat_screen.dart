import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/widget/host_personal_chat_screen_widget.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/shimmer/personal_chat_screen_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostPersonalChatScreen extends StatelessWidget {
  const HostPersonalChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GetBuilder<HostPersonalChatScreenController>(
            id: Constant.idGetOldChat,
            builder: (controller) {
              return Column(
                children: [
                  HostChatScreenAppBar(),
                  GetBuilder<HostPersonalChatScreenController>(
                    id: Constant.idPagination,
                    builder: (controller) => Visibility(
                      visible: controller.isPaginationLoading,
                      child: LinearProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppAsset.chatBackGround), fit: BoxFit.cover)),
                      child: SizedBox(
                        height: Get.height,
                        child: controller.isLoading
                            ? PersonalChatScreenShimmer()
                            : SingleChildScrollView(
                                controller: controller.scrollController,
                                child: ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    // controller: controller.scrollController,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    itemCount: controller.oldChatListener.length,
                                    itemBuilder: (context, index) {
                                      final msg = controller.oldChatListener[index];
                                      final isLastMessage = index == 0;

                                      Widget messageWidget = msg.messageType == 1
                                          ? HostChatTextWidget(msg: msg, controller: controller, isRead: msg.isRead ?? false)
                                          : msg.messageType == 4
                                              ? HostChatAudioCallWidget(
                                                  msg: msg,
                                                  controller: controller,
                                                  audioCallDuration: msg.callDuration ?? "00:00:00",
                                                )
                                              : msg.messageType == 5
                                                  ? HostChatVideoCallWidget(
                                                      msg: msg,
                                                      controller: controller,
                                                      callDuration: msg.callDuration ?? "00:00:00",
                                                    )
                                                  : msg.messageType == 2
                                                      ? HostChatImageWidget(msg: msg, controller: controller, isRead: msg.isRead ?? false)
                                                      : msg.messageType == 3
                                                          ? msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
                                                              ? SenderAudioMessageWidget(
                                                                  audioUrl: msg.audio ?? "",
                                                                  time: msg.date ?? "",
                                                                  id: msg.id ?? "",
                                                                  chat: msg,
                                                                  isLastMessage: isLastMessage,
                                                                )
                                                              : ReceiverAudioMessageWidget(
                                                                  audioUrl: msg.audio ?? "",
                                                                  time: msg.date ?? "",
                                                                  id: msg.id ?? "",
                                                                  chat: msg,
                                                                )
                                                          : SizedBox();

                                      // Widget messageWidget;
                                      //
                                      // if (msg.messageType == 1) {
                                      //   messageWidget = hostTextBubble(msg, controller, isRead: msg.isRead ?? false);
                                      // } else if (msg.messageType == 2) {
                                      //   messageWidget = hostImageBubble(msg, controller, isRead: msg.isRead ?? false);
                                      // } else if (msg.messageType == 3) {
                                      //   messageWidget = msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
                                      //       ? SenderAudioUi(
                                      //           id: msg.id ?? "",
                                      //           audio: Api.baseUrl + (msg.audio ?? ""),
                                      //           time: CustomFormatChatTime.convert((msg.createdAt ?? DateTime.now()).toString()),
                                      //         )
                                      //       : ReceiverAudioUi(
                                      //           id: msg.id ?? "",
                                      //           audio: Api.baseUrl + (msg.audio ?? ""),
                                      //           time: CustomFormatChatTime.convert((msg.createdAt ?? DateTime.now()).toString()),
                                      //         );
                                      // } else if (msg.messageType == 0) {
                                      //   messageWidget = UploadAudioUi(); // TEMP UI
                                      // } else {
                                      //   messageWidget = Text("Unsupported message type");
                                      // }

                                      return Align(
                                        alignment: msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: messageWidget,
                                      );
                                    }),
                              ),
                      ),
                    ),
                  ),
                  HostPersonalChatBottomView(),
                ],
              );
            },
          ),
          Positioned(
            bottom: 80,
            child: GetBuilder<HostPersonalChatScreenController>(
              id: Constant.idChangeAudioRecordingEvent,
              builder: (controller) => Visibility(
                visible: controller.isRecordingAudio,
                child: Container(
                  height: 40,
                  width: 110,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAsset.microPhoneIcon,
                        color: AppColors.primary,
                        width: 20,
                      ),
                      5.width,
                      Text(
                        CustomFormatAudioTime.convert(controller.countTime),
                        style: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 13),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talk_in/custom/custom_format_audio_time.dart';
// import 'package:talk_in/custom/custom_format_chat_time.dart';
// import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
// import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
// import 'package:talk_in/ui/host_flow/host_personal_chat_screen/widget/host_personal_chat_screen_widget.dart';
// import 'package:talk_in/utils/api.dart';
// import 'package:talk_in/utils/app_asset.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/constant.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/font_style.dart';
// import 'package:talk_in/utils/utils.dart';
//
// class HostPersonalChatScreen extends StatelessWidget {
//   const HostPersonalChatScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Stack(
//       alignment: Alignment.center,
//       children: [
//         GetBuilder<HostPersonalChatScreenController>(
//           id: Constant.idGetOldChat,
//           builder: (controller) {
//             return Column(
//               children: [
//                 HostChatScreenAppBar(),
//                 controller.isLoading
//                     ? Expanded(
//                         child: Container(
//                             width: Get.width,
//                             decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppAsset.chatBackGround), fit: BoxFit.cover)),
//                             child: Column(
//                               children: [
//                                 CircularProgressIndicator(),
//                               ],
//                             )))
//                     : Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppAsset.chatBackGround), fit: BoxFit.cover)),
//                           child: ListView.builder(
//                               reverse: true,
//                               // controller: controller.scrollController,
//                               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                               itemCount: controller.oldChatListener.length,
//                               itemBuilder: (context, index) {
//                                 final msg = controller.oldChatListener[index];
//                                 Widget messageWidget = msg.messageType == 2
//                                     ? hostImageBubble(msg, controller)
//                                     : msg.messageType == 3
//                                         ? msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
//                                             ? SenderAudioUi(
//                                                 id: msg.id ?? "",
//                                                 audio: Api.baseUrl + (msg.audio ?? ""),
//                                                 time: CustomFormatChatTime.convert(
//                                                   (msg.createdAt ?? DateTime.now()).toString(),
//                                                 ))
//                                             : ReceiverAudioUi(
//                                                 id: msg.id ?? "",
//                                                 audio: Api.baseUrl + (msg.audio ?? ""),
//                                                 time: CustomFormatChatTime.convert(
//                                                   (msg.createdAt ?? DateTime.now()).toString(),
//                                                 ))
//                                         : hostTextBubble(msg, controller);
//
//                                 return Align(
//                                   alignment: msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
//                                       ? Alignment.centerRight
//                                       : Alignment.centerLeft,
//                                   child: messageWidget,
//                                 );
//                               }),
//                         ),
//                       ),
//                 HostPersonalChatBottomView(),
//               ],
//             );
//           },
//         ),
//         SizedBox(
//           height: Get.height,
//           width: Get.width,
//           child: Column(
//             children: [
//               GetBuilder<HostPersonalChatScreenController>(
//                 id: Constant.idPagination,
//                 builder: (controller) => Visibility(
//                   visible: controller.isPaginationLoading,
//                   child: LinearProgressIndicator(color: AppColors.primary),
//                 ),
//               ),
//               Expanded(
//                 child: SizedBox(
//                   height: Get.height,
//                   width: Get.width,
//                   child: Stack(
//                     children: [
//                       Image.asset(AppAsset.chatBackGround, fit: BoxFit.cover, width: Get.width),
//                       SizedBox(
//                         height: Get.height,
//                         width: Get.width,
//                         child: GetBuilder<HostPersonalChatScreenController>(
//                           id: Constant.idGetOldChat,
//                           builder: (controller) => controller.isLoading
//                               ? LoadingWidget()
//                               : SingleChildScrollView(
//                                   controller: controller.scrollController,
//                                   padding: EdgeInsets.only(left: 15, right: 15, top: 15),
//                                   child: ListView.builder(
//                                       reverse: true,
//                                       // controller: controller.scrollController,
//                                       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                                       itemCount: controller.oldChatListener.length,
//                                       itemBuilder: (context, index) {
//                                         final msg = controller.oldChatListener[index];
//                                         Widget messageWidget = msg.messageType == 2
//                                             ? hostImageBubble(msg, controller)
//                                             : msg.messageType == 3
//                                                 ? msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
//                                                     ? SenderAudioUi(
//                                                         id: msg.id ?? "",
//                                                         audio: Api.baseUrl + (msg.audio ?? ""),
//                                                         time: CustomFormatChatTime.convert(
//                                                           (msg.createdAt ?? DateTime.now()).toString(),
//                                                         ))
//                                                     : ReceiverAudioUi(
//                                                         id: msg.id ?? "",
//                                                         audio: Api.baseUrl + (msg.audio ?? ""),
//                                                         time: CustomFormatChatTime.convert(
//                                                           (msg.createdAt ?? DateTime.now()).toString(),
//                                                         ))
//                                                 : hostTextBubble(msg, controller);
//
//                                         return Align(
//                                           alignment: msg.senderId == Database.fetchLoginUserProfileModel?.user?.listenerId
//                                               ? Alignment.centerRight
//                                               : Alignment.centerLeft,
//                                           child: messageWidget,
//                                         );
//                                       }),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const HostPersonalChatBottomView()
//             ],
//           ),
//         ),
//         Positioned(
//           top: 40,
//           child: GetBuilder<HostPersonalChatScreenController>(
//             id: Constant.idChangeAudioRecordingEvent,
//             builder: (controller) => Visibility(
//               visible: controller.isRecordingAudio,
//               child: Container(
//                 height: 40,
//                 width: 110,
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withValues(alpha: 0.3),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Image.asset(
//                       AppAsset.microPhoneIcon,
//                       color: AppColors.primary,
//                       width: 20,
//                     ),
//                     5.width,
//                     Text(
//                       CustomFormatAudioTime.convert(controller.countTime),
//                       style: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 13),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ));
//   }
// }

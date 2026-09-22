// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
// import 'package:talk_in/custom/listeners/listeners.dart';
// import 'package:talk_in/routes/app_routes.dart';
// import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
// import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
// import 'package:talk_in/ui/user_flow/top_listeners_view_all/widget/top_listeners_view_all_widget.dart';
// import 'package:talk_in/utils/app_asset.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/constant.dart';
// import 'package:talk_in/utils/database.dart';
//
// class TopListenersViewAllScreen extends StatelessWidget {
//   const TopListenersViewAllScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         flexibleSpace: const TopListenersViewAllAppBar(),
//       ),
//       body: GetBuilder<HomeScreenController>(
//         id: Constant.idGetListener,
//         builder: (controller) {
//           return controller.isLoading
//               ? Center(child: TopListenerShimmer().paddingSymmetric(horizontal: 14))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: RefreshIndicator(
//                         onRefresh: () async => controller.onRefresh(),
//                         child: SingleChildScrollView(
//                           controller: controller.scrollController,
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           child: Column(
//                             children: [
//                               ListView.builder(
//                                 shrinkWrap: true,
//                                 padding: EdgeInsets.zero,
//                                 physics: BouncingScrollPhysics(),
//                                 itemCount: controller.topListeners.length,
//                                 itemBuilder: (context, index) {
//                                   return CustomListeners(
//                                     statusTxtColor:
//                                         controller.topListeners[index].statusLabel == "Offline" ? AppColors.appTextColor : AppColors.white,
//                                     statusColor: controller.topListeners[index].statusLabel == "Available"
//                                         ? AppColors.green
//                                         : controller.topListeners[index].statusLabel == "On Call"
//                                             ? AppColors.red
//                                             : AppColors.lightGrey1,
//                                     statusImage: controller.topListeners[index].statusLabel == "Available"
//                                         ? Container(
//                                             // height: 12,
//                                             // width: 12,
//                                             decoration: BoxDecoration(
//                                               color: AppColors.white.withValues(alpha: 0.5),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Container(
//                                               height: 7,
//                                               width: 7,
//                                               decoration: BoxDecoration(
//                                                 color: AppColors.white,
//                                                 shape: BoxShape.circle,
//                                               ),
//                                             ).paddingAll(1.8),
//                                           ).paddingOnly(right: 4)
//                                         : controller.topListeners[index].statusLabel == "on call"
//                                             ? Image.asset(
//                                                 AppAsset.onCallIcon,
//                                                 height: 10,
//                                                 width: 10,
//                                               ).paddingOnly(right: 3)
//                                             : Container(
//                                                 // height: 12,
//                                                 // width: 12,
//                                                 decoration: BoxDecoration(
//                                                   color: AppColors.appTextColor.withValues(alpha: 0.3),
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                                 child: Container(
//                                                   height: 7,
//                                                   width: 7,
//                                                   decoration: BoxDecoration(
//                                                     color: AppColors.appTextColor,
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                 ).paddingAll(1.8),
//                                               ).paddingOnly(right: 4),
//                                     image: controller.topListeners[index].image ?? '',
//                                     status: controller.topListeners[index].statusLabel ?? '',
//                                     language: controller.topListeners[index].language?.join(', ') ?? '',
//                                     callCount: controller.topListeners[index].callCount ?? 0,
//                                     talkTopicName: controller.topListeners[index].talkTopics?.join(', ') ?? '',
//                                     talkTopicLength: controller.topListeners[index].talkTopics?.length ?? 0,
//                                     index: index,
//                                     name: controller.topListeners[index].name ?? '',
//                                     age: controller.topListeners[index].age == null ? "" : ",${controller.topListeners[index].age.toString()}",
//                                     viewProfileOnTap: () {
//                                       Get.toNamed(
//                                         AppRoutes.profileDetailScreenView,
//                                         arguments: controller.topListeners[index].id,
//                                       );
//                                     },
//                                     talkNowOnTap: () {
//                                       Get.bottomSheet(
//                                         TalkNowButtonBottomSheet(
//                                           callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
//                                               ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
//                                               : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
//                                           receiverId: controller.topListeners[index].id ?? '',
//                                           receiverName: controller.topListeners[index].name ?? '',
//                                           receiverImage: controller.topListeners[index].image ?? '',
//                                           callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
//                                           callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
//                                           // callType: "video",
//                                           callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
//                                           receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
//                                         ),
//                                         isScrollControlled: true,
//                                         backgroundColor: Colors.transparent,
//                                       );
//                                     },
//                                   ).paddingOnly(bottom: 12);
//                                 },
//                               ),
//                               GetBuilder<HomeScreenController>(
//                                 id: Constant.idPaginationListener,
//                                 builder: (controller) => Visibility(
//                                   visible: controller.isPaginationLoading,
//                                   child: CircularProgressIndicator(color: AppColors.primary),
//                                 ),
//                               ),
//                             ],
//                           ).paddingAll(16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/top_listeners_view_all/widget/top_listeners_view_all_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class TopListenersViewAllScreen extends StatelessWidget {
  const TopListenersViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const TopListenersViewAllAppBar(),
      ),
      body: TopListenersViewAllView(),
    );
  }
}

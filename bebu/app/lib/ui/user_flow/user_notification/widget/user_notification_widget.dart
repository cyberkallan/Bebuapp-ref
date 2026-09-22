import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/dialog/notification_clear_dialog.dart';
import 'package:talk_in/ui/host_flow/host_notification/shimmer/notification_shimmer.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationAppBar extends StatelessWidget {
  const UserNotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtNotification.name.tr,
        showLeadingIcon: true,
        action: [
          GetBuilder<UserNotificationController>(
              id: Constant.idUserNotification,
              builder: (controller) {
                return GestureDetector(
                  onTap: () {
                    Get.dialog(
                      barrierColor: AppColors.black.withValues(alpha: 0.8),
                      Dialog(
                        backgroundColor: AppColors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        child: NotificationClearDialog(onConfirm: controller.clearNotificationUser),
                      ),
                    );
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAsset.filterClearIcon,
                        height: 26,
                        width: 26,
                      ),
                    ),
                  ).paddingOnly(right: 18),
                );
              })
        ],
      ),
    );
  }
}

class UserNotificationView extends StatelessWidget {
  const UserNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserNotificationController>(
        id: Constant.idUserNotification,
        builder: (controller) {
          return controller.isLoading
              ? Expanded(child: NotificationShimmer())
              : controller.notificationList.isEmpty
                  ? Expanded(child: Image.asset(AppAsset.noNotificationFound).paddingAll(70))
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.onRefresh(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: controller.notificationList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.notificationList[index].title ?? '',
                                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
                                      ).paddingOnly(bottom: 3),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(controller.notificationList[index].message ?? '',
                                                style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.notificationTxt)),
                                          ),
                                          6.width,
                                          Text(controller.notificationList[index].date ?? '',
                                              style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.black))
                                        ],
                                      ).paddingOnly(bottom: 5),
                                      Divider(
                                        color: AppColors.lightGrey,
                                        height: 25,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
        });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/dialog/notification_clear_dialog.dart';
import 'package:talk_in/ui/host_flow/host_notification/controller/host_notification_controller.dart';
import 'package:talk_in/ui/host_flow/host_notification/shimmer/notification_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostNotificationAppBar extends StatelessWidget {
  const HostNotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtNotification.name.tr,
        showLeadingIcon: true,
        action: [
          GetBuilder<HostNotificationController>(
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
                        child: HostNotificationClearDialog(onConfirm: controller.clearNotificationListener),
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

class HostNotificationView extends StatelessWidget {
  const HostNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostNotificationController>(
        id: Constant.idUserNotification,
        builder: (controller) {
          return controller.isLoading
              ? Expanded(child: NotificationShimmer())
              : controller.hostNotificationList.isEmpty
                  ? Expanded(child: Image.asset(AppAsset.noNotificationFound).paddingAll(70))
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.onRefresh(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: controller.hostNotificationList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.hostNotificationList[index].title ?? '',
                                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
                                      ).paddingOnly(bottom: 3),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(controller.hostNotificationList[index].message ?? '',
                                                style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.notificationTxt)),
                                          ),
                                          6.width,
                                          Text(controller.hostNotificationList[index].date ?? '',
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

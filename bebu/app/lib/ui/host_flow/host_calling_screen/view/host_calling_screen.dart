import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/controller/host_calling_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/widget/host_calling_screen_widget.dart';
import 'package:talk_in/ui/user_flow/calling_screen/shimmer/calling_history_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class HostCallingScreen extends StatelessWidget {
  const HostCallingScreen({super.key});

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
          flexibleSpace: const HostCallingScreenAppBar(),
        ),
        body: GetBuilder<HostCallingScreenController>(
          id: Constant.idCallingHistory,
          builder: (controller) {
            return controller.isLoading
                ? CallingHistoryShimmer().paddingSymmetric(horizontal: 14, vertical: 12)
                : controller.callingHistory.isEmpty
                    ? Center(
                        child: Image.asset(
                          AppAsset.noHistoryFound,
                          height: 300,
                        ).paddingAll(90),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => controller.onRefresh(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: controller.scrollController,
                          child: Column(
                            children: [
                              controller.isLoading
                                  ? CallingHistoryShimmer().paddingSymmetric(horizontal: 14, vertical: 10)
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller.callingHistory.length,
                                      // padding: const EdgeInsets.only(top: 12),
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return HostCallingScreenItem(
                                          controller: controller,
                                          time: controller.callingHistory[index].date.toString(),
                                          callStatusText: controller.callingHistory[index].callStatusText.toString(),
                                          coin: controller.callingHistory[index].coin ?? 0,
                                          name: controller.callingHistory[index].fullName.toString(),
                                          image: controller.callingHistory[index].profilePic.toString(),
                                          index: index,
                                        ).paddingOnly(bottom: 12, top: index == 0 ? 12 : 0);
                                      },
                                    ),
                              GetBuilder<HostCallingScreenController>(
                                id: Constant.idPaginationListener,
                                builder: (controller) => Visibility(
                                  visible: controller.isPaginationLoading,
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
          },
        ),
      ),
    );
  }
}

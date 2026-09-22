import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/widget/host_home_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class HostHomeScreen extends GetView<HostHomeScreenController> {
  const HostHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

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
        body: GetBuilder<HostHomeScreenController>(builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async => controller.onRefresh(),
            child: Column(
              children: [
                HostTopHomeView().paddingSymmetric(horizontal: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HostImageView(),
                        // RandomCallView().paddingOnly(left: 16, right: 15),
                        PermissionView().paddingSymmetric(horizontal: 16),
                        NoteView().paddingSymmetric(horizontal: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// canPop: false,
// onPopInvoked: (bool didPop) {
// // Get.dialog(
// //   barrierColor: AppColors.black.withValues(alpha: 0.8),
// //   Dialog(
// //     backgroundColor: AppColors.transparent,
// //     shadowColor: Colors.transparent,
// //     surfaceTintColor: Colors.transparent,
// //     elevation: 0,
// //     child: const ExitAppDialog(),
// //   ),
// // );
// if (didPop) {
// return;
// }
// },

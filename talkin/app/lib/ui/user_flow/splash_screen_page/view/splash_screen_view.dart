import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<SplashScreenController>(
        builder: (controller) {
          return Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      AppAsset.splashBg,
                    ),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                Spacer(),
                Center(
                  child: Image.asset(
                    width: 170,
                    height: 170,
                    AppAsset.splashLogo,
                  ),
                ),
                Spacer(),
                Text(
                  "bebu",
                  style: AppFontStyle.fontStyleW600(fontSize: 29, fontColor: AppColors.black),
                ),
                Text(
                  "Connect & establish meaningful connections",
                  style: AppFontStyle.fontStyleW400(fontSize: 14, fontColor: AppColors.historyCallType),
                ).paddingOnly(bottom: 20),
                LoadingAnimationWidget.staggeredDotsWave(color: AppColors.black, size: 40),
                20.height,
              ],
            ),
          );
        },
      ),
      // body: Image.asset(
      //   AppAsset.imgSplashScreen,
      //   height: Get.height,
      //   width: Get.width,
      //   fit: BoxFit.cover,
      // ),
    );
  }
}

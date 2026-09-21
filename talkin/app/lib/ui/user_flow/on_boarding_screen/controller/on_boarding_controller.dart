import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class OnBoardingController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    // Database.onSetFillProfile(false);

    Database.onSetSeenOnboarding(false);
    log("init isSeenOnBoarding ::  ${Database.isSeenOnBoarding}");

    super.onInit();
  }

  PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;

  List title = [
    EnumLocale.txtRegisterTitle1.name.tr,
    EnumLocale.txtRegisterTitle2.name.tr,
    EnumLocale.txtRegisterTitle3.name.tr,
  ];
  List subTitle = [
    EnumLocale.txtRegisterSubTitle1.name.tr,
    EnumLocale.txtRegisterSubTitle2.name.tr,
    EnumLocale.txtRegisterSubTitle3.name.tr,
  ];

  List image = [
    AppAsset.onBoarding1,
    AppAsset.onBoarding2,
    AppAsset.onBoarding3,
  ];

  onPageScroll({required int currentPage}) {
    if (currentPage < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      log("isSeenOnBoarding ::${Database.isSeenOnBoarding}");

      Database.onSetSeenOnboarding(true);

      log("isSeenOnBoarding ::${Database.isSeenOnBoarding}");

      Get.offAllNamed(AppRoutes.main);
    }
    update([Constant.idOnBoarding]);
  }

  onPageChanged({required int page}) {
    currentPage = page;
    update([Constant.idOnBoarding]);
  }
}

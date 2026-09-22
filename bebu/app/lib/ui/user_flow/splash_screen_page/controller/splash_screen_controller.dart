import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/ip_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/aap_configuration_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/ip_api_response_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/appearance.dart';
import 'package:talk_in/utils/login_config.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

import '../api/aap_configuration_api.dart';

class SplashScreenController extends GetxController {
  SettingApiModel? settingApiModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  IpApiResponseModel? ipApiResponseModel;
  AppConfigurationModel? appConfigurationModel;

  @override
  void onInit() {
    log('Enter splash screen controller');
    init();
    super.onInit();
  }

  Future<void> init() async {
    /// for privacy policy link and app live key
    appConfigurationModel = await AppConfigurationApi.callApi();
    Database.appConfigurationModel = appConfigurationModel;
    // Sign-in methods, reward teaser and the admin theme are public, so the
    // sign-in screen is already branded and configured before any login.
    final cfg = appConfigurationModel?.data;
    if (cfg != null) {
      LoginConfig.remember(cfg.login);
      RewardTeaser.remember(cfg.toJson());
      if (cfg.appearance != null) Appearance.applyServer(cfg.appearance);
    }
    final token = await FirebaseAccessToken.onGet();

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    if (Database.settingApiModel?.data?.isApplicationLive == false) {
      log("Application is not live...");
      Get.dialog(
        barrierColor: AppColors.black.withValues(alpha: 0.8),
        Dialog(
          backgroundColor: AppColors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: const AppNotLiveDialog(),
        ),
      );
    }

    if (fetchLoginUserProfileModel?.status == false || fetchLoginUserProfileModel?.message == "User not found in the database." || token == null) {
      log("Login user not found, redirecting to main screen...");
      Get.offAllNamed(AppRoutes.main);
      return;
    }

    if (fetchLoginUserProfileModel?.user?.isListener == true) {
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
      Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
      if (fetchListenerProfileModel?.status == false) {
        Utils.showLog(fetchListenerProfileModel?.message ?? "");
      }
      Database.fetchListenerProfileModel = fetchListenerProfileModel;
    }

    ipApiResponseModel = await IpApi.callApi();
    Database.onSetSelectedCountryCode(ipApiResponseModel?.countryCode ?? '');
    log("Database.selectedCountryCode :: ${Database.selectedCountryCode}");
    Database.getDialCode();

    await splashScreen();
    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
    Appearance.applyServer(settingApiModel?.data?.appearance);
  }
}

Future<void> splashScreen() async {
  Timer(Duration(seconds: 2), () async {
    // Check User Is Login Or Not...

    log("isLogin :: ${Database.isLogin}");
    log("isFillProfile :: ${Database.isFillProfile}");
    log("isSeenOnBoarding :: ${Database.isSeenOnBoarding}");

    if (Database.settingApiModel?.data?.isApplicationLive == false) {
      log("Application is not live...");
      Get.dialog(
        barrierColor: AppColors.black.withValues(alpha: 0.8),
        Dialog(
          backgroundColor: AppColors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: const AppNotLiveDialog(),
        ),
      );
    } else {
      if (Database.isSeenOnBoarding == true) {
        if (Database.isLogin == true) {
          if (Database.isFillProfile == true) {
            if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
              Get.toNamed(AppRoutes.hostBottomBar);
            } else {
              Get.toNamed(AppRoutes.bottomBar);
            }
          } else {
            Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
              Database.loginUserName,
              Database.loginUserProfilePic,
              Database.loginUserEmail,
            ]);
          }
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      } else {
        Get.offAllNamed(AppRoutes.onBoarding);
      }
    }
  });
}

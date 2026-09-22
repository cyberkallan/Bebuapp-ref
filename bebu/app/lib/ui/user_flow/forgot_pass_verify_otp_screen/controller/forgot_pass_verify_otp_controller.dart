import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/check_user_exist_model.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class ForgotPassVerifyOtpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  dynamic args = Get.arguments;
  int countdown = 0;
  bool isOtpExpired = false;

  Timer? timer;
  String? mobileNumber;
  String? dialCode;
  bool isLoading = false;

  TextEditingController otpController = TextEditingController();
  MainScreenController mainScreenController = Get.find<MainScreenController>();

  String? verificationId;
  LoginModel? loginModel;
  CheckUserExistModel? checkUserExistModel;

  @override
  void onInit() async {
    await getDataFromArgs();
    startCountdown();

    super.onInit();
  }

  @override
  void dispose() {
    otpController.clear();
    super.dispose();
  }

  getDataFromArgs() {
    if (args != null) {
      if (args[0] != null) mobileNumber = args[0];
      if (args[1] != null) dialCode = args[1];
      if (args[2] != null) verificationId = args[2];

      log("Mobile Number :: $mobileNumber");
      log("Selected Country Code :: $dialCode");
      log("Verification ID :: $verificationId");
    }
  }

  Future<void> verifyOtp() async {
    final identity = (await MobileDeviceIdentifier().getDeviceId())!;
    final fcmToken = await FirebaseMessaging.instance.getToken();
    Database.onSetFcmToken(fcmToken ?? "");
    Database.onSetIdentity(identity);

    log("Database.identity :: ${Database.identity}");
    log("Database.fcmToken :: ${Database.fcmToken}");

    final smsCode = otpController.text.trim();

    if (smsCode.isEmpty) {
      Utils.showToast(Get.context!, "Please enter OTP");
      return;
    }

    if (isOtpExpired) {
      Utils.showToast(Get.context!, "OTP expired. Please request a new one.");
      return;
    }

    if (verificationId == null) {
      Utils.showToast(Get.context!, "Verification ID missing");
      return;
    }

    isLoading = true;
    update([Constant.idVerifyOtp]);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Success
      log("User logged in: ${userCredential.user?.uid}");

      if (userCredential.user?.uid != null) {
        Get.dialog(LoadingWidget(), barrierDismissible: false);

        loginModel = await LoginApi.callApi(
          countryCode: Database.selectedCountryCode,
          loginType: 3,
          identity: Database.identity,
          fcmToken: Database.fcmToken,
          mobileNumber: "$mobileNumber",
        );

        log("userCredential?.user?.id :::  ${userCredential.user?.uid}");
        log("loginModel?.status ${loginModel?.status}");
        log("loginModel?.signUp ${loginModel?.signUp}");

        if (loginModel?.status == true) {
          Database.onSetIsLogin(true);
          Database.onSetSeenOnboarding(true);
          Database.onSetFillProfile(true);

          Database.onSetLoginType(loginModel?.user?.loginType ?? 0);

          await mainScreenController.onGetProfile(
            loginUserId: userCredential.user!.uid,
            loginType: 3,
          );

          if (loginModel?.signUp == true) {
            Database.onSetFillProfile(false);

            log("Database.loginUserName  ${Database.loginUserName}");
            log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
            log("Database.loginUserEmail  ${Database.loginUserEmail}");

            Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
              Database.loginUserName,
              Database.loginUserProfilePic,
              Database.loginUserEmail,
            ]);
          } else {
            // get profile api

            Database.onSetFillProfile(true);
            await mainScreenController.onGetProfile(
              loginUserId: userCredential.user!.uid,
              loginType: 3,
            );
            if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
              Get.toNamed(AppRoutes.hostBottomBar);
            } else {
              Get.toNamed(AppRoutes.bottomBar);
            }
          }
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          Utils.showLog("mobile number Login Api Calling Failed !!");
        }

        // Get.back();
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("mobile number Login Failed !!");
      }
      // Navigate to main screen
      // Get.offAllNamed(AppRoutes.bottomBar);
    } on FirebaseAuthException catch (e) {
      Utils.showToast(Get.context!, e.message ?? "Invalid OTP");
    } catch (e) {
      Utils.showToast(Get.context!, "Something went wrong");
    } finally {
      isLoading = false;
      update();
    }
  }

  String get formattedCountdown {
    final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startCountdown() {
    countdown = 30;
    update([Constant.idResendOtp]);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        countdown--;
        update([Constant.idResendOtp]);
      } else {
        isOtpExpired = true;
        t.cancel();
        Constant.storage.write("isResendOtp", false);
        update([Constant.idResendOtp]);
      }
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}

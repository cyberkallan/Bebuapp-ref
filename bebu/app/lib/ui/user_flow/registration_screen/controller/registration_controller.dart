import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isObscure1 = true;
  bool isCheck = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  void onClickObscure1() {
    log("isObscure1 :: $isObscure1");
    isObscure1 = !isObscure1;
    update();
  }

  void onClickCheck() {
    log("isCheck:: $isCheck");
    isCheck = !isCheck;
    update([Constant.idAcceptTerms]);
  }

  bool validateRegistration() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return false;
    }

    Get.dialog(LoadingWidget(), barrierDismissible: false);
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final rePassword = confirmPassController.text.trim();

    if (name.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your full name");
      return false;
    }

    if (email.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your email");
      return false;
    }

    if (!isEmailValid(email)) {
      Utils.showToast(Get.context!, "Please enter a valid email address");
      return false;
    }

    if (password.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your password");
      return false;
    }

    if (password.length < 6) {
      Utils.showToast(Get.context!, "Password must be at least 6 characters");
      return false;
    }

    if (rePassword.isEmpty) {
      Utils.showToast(Get.context!, "Please re-enter your password");
      return false;
    }

    if (rePassword != password) {
      Utils.showToast(Get.context!, "Passwords do not match");
      return false;
    }
    Get.back();
    return true;
  }

  // Future<void> signUpWithEmailPassword() async {
  //   try {
  //     // Firebase signup
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //
  //     log("Signup successful! UID: ${userCredential.user?.uid}");
  //     log("Signup successful! email: ${userCredential.user?.email}");
  //
  //     // Get identity and FCM token
  //     final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  //     final fcmToken = await FirebaseMessaging.instance.getToken();
  //
  //     Database.onSetIdentity(identity);
  //     Database.onSetFcmToken(fcmToken ?? "");
  //
  //     log("Database.identity :: ${Database.identity}");
  //     log("Database.fcmToken :: ${Database.fcmToken}");
  //
  //     // Call your login API
  //     Get.dialog(LoadingWidget(), barrierDismissible: false);
  //     Database.onSetUserExist(false);
  //
  //     loginModel = await LoginApi.callApi(
  //       countryCode: Database.selectedCountryCode,
  //       loginType: 4, // Use 2 for email/password login
  //       email: userCredential.user?.email ?? "",
  //       identity: Database.identity,
  //       fcmToken: Database.fcmToken,
  //       userName: nameController.text,
  //       // password: passwordController.text,
  //       confirmPassword: confirmPassController.text,
  //     );
  //
  //     if (loginModel?.status == true) {
  //       Database.onSetIsLogin(true);
  //       Database.onSetSeenOnboarding(true);
  //       Database.onSetFillProfile(true);
  //
  //       Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
  //
  //       await onGetProfile(
  //         loginUserId: userCredential.user!.uid,
  //         loginType: 4,
  //       );
  //
  //       if (loginModel?.signUp == true) {
  //         Database.onSetFillProfile(false);
  //         Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
  //           Database.loginUserName,
  //           Database.loginUserProfilePic,
  //           Database.loginUserEmail,
  //         ]);
  //       } else {
  //         Database.onSetFillProfile(true);
  //         await onGetProfile(
  //           loginUserId: userCredential.user!.uid,
  //           loginType: 4,
  //         );
  //         // Get.toNamed(AppRoutes.bottomBar);
  //         if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
  //           Get.toNamed(AppRoutes.hostBottomBar);
  //         } else {
  //           Get.toNamed(AppRoutes.bottomBar);
  //         }
  //       }
  //     } else {
  //       Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
  //       Utils.showLog("Login Api Calling Failed !!");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       Utils.showToast(Get.context!, "This email is already in use.");
  //     } else if (e.code == 'weak-password') {
  //       Utils.showToast(Get.context!, "Password is too weak.");
  //     } else {
  //       Utils.showToast(Get.context!, "Registration failed: ${e.message}");
  //     }
  //   } catch (e) {
  //     log("Signup failed: $e");
  //     // log("Error: ${e.message}");
  //   }
  // }

  var isBusy = false;

  Future<void> signUpWithEmailPassword() async {
    if (isBusy) return;
    isBusy = true;

    // keyboard બંધ કરો (optional)
    FocusManager.instance.primaryFocus?.unfocus();

    // Loader – એક જ જગ્યા
    Get.dialog(LoadingWidget(), barrierDismissible: false);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final identity = (await MobileDeviceIdentifier().getDeviceId())!;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      Database.onSetIdentity(identity);
      Database.onSetFcmToken(fcmToken ?? "");

      Database.onSetUserExist(false);
      loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 4,
        email: userCredential.user?.email ?? "",
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: nameController.text,
        confirmPassword: confirmPassController.text,
      );

      if (loginModel?.status == true) {
        Database.onSetIsLogin(true);
        Database.onSetSeenOnboarding(true);
        Database.onSetFillProfile(true);

        Database.onSetLoginType(loginModel?.user?.loginType ?? 0);

        await onGetProfile(
          loginUserId: userCredential.user!.uid,
          loginType: 4,
        );

        if (loginModel?.signUp == true) {
          Database.onSetFillProfile(false);
          Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
            Database.loginUserName,
            Database.loginUserProfilePic,
            Database.loginUserEmail,
          ]);
        } else {
          Database.onSetFillProfile(true);
          await onGetProfile(
            loginUserId: userCredential.user!.uid,
            loginType: 4,
          );
          // Get.toNamed(AppRoutes.bottomBar);
          if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
            Get.toNamed(AppRoutes.hostBottomBar);
          } else {
            Get.toNamed(AppRoutes.bottomBar);
          }
        }
      } else {
        Utils.showToast(Get.context!, "Something went wrong");
        Utils.showLog("Login Api Calling Failed !!");
      }
    } on FirebaseAuthException catch (e) {
      Utils.showLog('>>>>>>>>>>>>>>>>>>>>>$e');

      // Loader બંધ
      if (Get.isDialogOpen ?? false) Get.back();

      // ✅ Client SDKમાં code: 'email-already-in-use'
      if (e.code == 'email-already-in-use') {
        Utils.showLog('......................................');

        Utils.showToast(Get.context!, "This email is already in use.");
      } else if (e.code == 'weak-password') {
        Utils.showToast(Get.context!, "Password is too weak.");
      } else {
        Utils.showToast(Get.context!, "Registration failed: ${e.message}");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, "Registration failed");
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      isBusy = false;
    }
  }

  Future<void> onGetProfile({required String loginUserId, required int loginType}) async {
    final token = await FirebaseAccessToken.onGet();

    // Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId, token: token ?? '');

    log("fetchLoginUserProfileModel?.user?.id  :: ${fetchLoginUserProfileModel?.user?.id}");

    if (loginUserId.trim().isNotEmpty && token!.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);
        log("fetchLoginUserProfileModel?.user?.Email  :: ${fetchLoginUserProfileModel?.user?.email}");

        Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
        Database.onSetLoginUserFirebaseId(fetchLoginUserProfileModel!.user!.firebaseId!);
        Database.onSetLoginUserProfilePic(fetchLoginUserProfileModel?.user?.profilePic ?? "");
        Database.onSetLoginUserName(fetchLoginUserProfileModel!.user!.fullName!);
        Database.onSetLoginUserNickName(fetchLoginUserProfileModel?.user?.nickName ?? "");
        Database.onSetLoginUserEmail(fetchLoginUserProfileModel!.user!.email!);
        Database.onSetLoginUserCountry(fetchLoginUserProfileModel!.user!.country!);
        Database.onSetLoginUserCountryFlag(fetchLoginUserProfileModel!.user!.countryFlag!);

        Database.onSetLoginUserBirthDate(fetchLoginUserProfileModel?.user?.birthDate ?? "");
        Database.onSetLoginUserGender(fetchLoginUserProfileModel?.user?.gender ?? "Male");
        Database.onSetLoginUserPhoneNumber(fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
        Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
        log("Database.loginUserEmail  ${Database.loginUserEmail}");
        log("Database.loginUserFirebaseId  ${Database.loginUserFirebaseId}");
        log("Database.image  ${Database.loginUserProfilePic}");
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Get Profile Api Calling Failed !!");
      }
    } else {
      Database.onLogOut();
    }
  }
}

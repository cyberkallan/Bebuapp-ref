import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/custom_web_view/web_view_screen.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/custom/random_name/random_name.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/check_user_exist_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/check_user_exist_model.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/anonymous_authentication.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/pro.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class MainScreenController extends GetxController {
  int? selectedValue;
  final formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isLoading = false;
  String randomName = '';
  String randomImage = '';
  GoogleSignInAccount? googleSignInAccountUser;
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  CheckUserExistModel? checkUserExistModel;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    passwordController.clear();
    emailController.clear();
    randomName = CustomFetchRandomName.onGet();
    randomImage = CustomFetchRandomImage.onGet();
    super.onInit();
  }

  onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void toggleValue(int value) {
    if (selectedValue == value) {
      selectedValue = null;
    } else {
      selectedValue = value;
    }
    update([Constant.radioButton]);
  }

  bool validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

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
    //
    // if (password.length < 6) {
    //   Utils.showToast(Get.context!, "Password must be at least 6 characters");
    //   return false;
    // }

    return true;
  }

  /// google log in api
  Future<void> onGoogleLogin() async {
    try {
      if (selectedValue != 1) {
        Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
        return;
      }

      final identity = (await MobileDeviceIdentifier().getDeviceId())!;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      Database.onSetFcmToken(fcmToken ?? "");
      Database.onSetIdentity(identity);

      log("Database.identity :: ${Database.identity}");
      log("Database.fcmToken :: ${Database.fcmToken}");

      UserCredential? userCredential = await signInWithGoogle();

      // Safely extract email, name, photo
      String? email = userCredential?.user?.email ?? (userCredential?.additionalUserInfo?.profile?['email'] as String?);

      String? displayName = userCredential?.user?.displayName ?? (userCredential?.additionalUserInfo?.profile?['name'] as String?);

      String? photoUrl = userCredential?.user?.photoURL ?? (userCredential?.additionalUserInfo?.profile?['picture'] as String?);

      log("Google Email :: $email");
      log("Google Name :: $displayName");
      log("Google Photo :: $photoUrl");

      if (email != null) {
        Get.dialog(LoadingWidget(), barrierDismissible: false);

        loginModel = await LoginApi.callApi(
          countryCode: Database.selectedCountryCode,
          loginType: 1,
          email: email,
          identity: Database.identity,
          fcmToken: Database.fcmToken,
          userName: displayName ?? "",
          profilePic: Database.loginUserProfilePic.isEmpty ? photoUrl : Database.loginUserProfilePic,
        );

        if (loginModel?.status == true) {
          Database.onSetIsLogin(true);
          Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
          Database.onSetSeenOnboarding(true);
          Database.onSetFillProfile(true);

          await onGetProfile(loginUserId: userCredential!.user!.uid, loginType: 1);

          if (loginModel?.signUp == true) {
            Database.onSetFillProfile(false);

            Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
              Database.loginUserName,
              Database.loginUserProfilePic,
              Database.loginUserEmail,
            ]);
          } else {
            Database.onSetFillProfile(true);
            await onGetProfile(loginUserId: userCredential.user!.uid, loginType: 1);

            if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
              Get.toNamed(AppRoutes.hostBottomBar);
            } else {
              Get.toNamed(AppRoutes.bottomBar);
            }
          }
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          Utils.showLog("Login Api Calling Failed !!");
        }

        // Get.back();
      } else {
        Utils.showToast(Get.context!, "Google Login Failed: No email found.");
        Utils.showLog("Google Login Failed !! Email missing in response");
      }
    } catch (e) {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Google Login Failed !! Error => $e");
    }
  }

  /// google sign in firebase

  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     Get.dialog(LoadingWidget(), barrierDismissible: false);
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
  //     final result = await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     Utils.showLog("Google Login Email => ${result.user?.email}");
  //     Utils.showLog("Google Login uid => ${result.user?.uid}");
  //
  //     Utils.showLog("Google Login isNewUser => ${result.additionalUserInfo?.isNewUser}");
  //     Get.back();
  //
  //     return result;
  //   } catch (error) {
  //     Get.back();
  //     Utils.showLog("Google Login Error => $error");
  //   }
  //   return null;
  // }

  Future<UserCredential?> signInWithGoogle() async {
    Get.dialog(LoadingWidget(), barrierDismissible: false);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Utils.showToast(Get.context!, "Google sign-in was canceled.");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        Utils.showToast(Get.context!, "Google sign-in failed: missing tokens.");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final result = await FirebaseAuth.instance.signInWithCredential(credential);
        return result;
      } on FirebaseAuthException catch (e) {
        Utils.showLog('......................................');

        if (e.code == 'invalid-credential') {
          Utils.showToast(Get.context!, "Sign-in failed: invalid or expired credential.");
        } else if (e.code == 'account-exists-with-different-credential') {
          Utils.showToast(Get.context!, "This email is linked with a different sign-in method.");
        } else if (e.code == 'network-request-failed') {
          Utils.showToast(Get.context!, "Network error. Please check your internet connection.");
        } else {
          Utils.showToast(Get.context!, "Sign-in failed: ${e.message}");
        }
        return null;
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Google sign-in error: $e");
      return null;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back(); // 6) loader ALWAYS closed
    }
  }

  /// user get profile

  Future<void> onGetProfile({required String loginUserId, required int loginType}) async {
    final token = await FirebaseAccessToken.onGet();

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserId, token: token ?? '');
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
    Pro.rememberUser(fetchLoginUserProfileModel?.user?.premiumStatus, fetchLoginUserProfileModel?.user?.activeStyle);

    log("fetchLoginUserProfileModel?.user?.id${fetchLoginUserProfileModel?.user?.id}");
    if (loginUserId.trim().isNotEmpty && token!.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);
        log("fetchLoginUserProfileModel?.user?.Email${fetchLoginUserProfileModel?.user?.email}");

        Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
        Database.onSetLoginUserFirebaseId(fetchLoginUserProfileModel!.user!.firebaseId!);
        Database.onSetLoginUserProfilePic(fetchLoginUserProfileModel?.user?.profilePic ?? "");
        Database.onSetLoginUserName(fetchLoginUserProfileModel!.user!.fullName!);
        Database.onSetLoginUserNickName(fetchLoginUserProfileModel?.user?.nickName ?? "");
        Database.onSetLoginUserBio(fetchLoginUserProfileModel?.user?.bio ?? "");
        Database.onSetLoginUserEmail(fetchLoginUserProfileModel!.user!.email!);
        Database.onSetLoginUserCountry(fetchLoginUserProfileModel!.user!.country!);
        Database.onSetLoginUserCountryFlag(fetchLoginUserProfileModel!.user!.countryFlag!);
        Database.onSetLoginUserBirthDate(fetchLoginUserProfileModel?.user?.birthDate ?? "");
        Database.onSetLoginUserGender(fetchLoginUserProfileModel?.user?.gender ?? "Male");
        Database.onSetLoginUserPhoneNumber(fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
        Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
        log("Database.loginUserId  ${Database.loginUserId}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");
        log("Database.loginUserFirebaseId  ${Database.loginUserFirebaseId}");
        log("Database.image  ${Database.loginUserProfilePic}");

        if (fetchLoginUserProfileModel?.user?.isListener == true) {
          fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
            loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
          );
          Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
          if (fetchListenerProfileModel?.status == false) {
            Utils.showLog(fetchListenerProfileModel?.message ?? "");
          }
          Database.fetchListenerProfileModel = fetchListenerProfileModel;
        }
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Get Profile Api Calling Failed !!");
      }
    } else {
      Database.onLogOut();
    }
  }

  /// QuickLogin

  void onQuickLogin() async {
    if (selectedValue != 1) {
      Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
      return;
    }
    final identity = (await MobileDeviceIdentifier().getDeviceId())!;
    final fcmToken = await FirebaseMessaging.instance.getToken();
    Database.onSetFcmToken(fcmToken ?? "");
    Database.onSetIdentity(identity);

    log("Database.identity :: ${Database.identity}");
    log("Database.fcmToken :: ${Database.fcmToken}");

    Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

    await AnonymousAuthentication.signInWithAnonymous(); // Anonymous Login...
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";

    Utils.showLog("Anonymous Login uid :: $uid");

    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: 2,
      email: Database.identity,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: randomName,
      profilePic: randomImage,
    );

    // Get.back(); // Stop Loading...

    if (loginModel?.status == true) {
      Database.onSetIsLogin(true);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);
      Database.onSetFillProfile(true);

      await onGetProfile(loginUserId: uid, loginType: 2);

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);

        log("Database.loginUserName  ${Database.loginUserName}");
        log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");

        Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [Database.loginUserName, Database.loginUserProfilePic, Database.loginUserEmail]);
      } else {
        // get profile api

        Database.onSetFillProfile(true);
        await onGetProfile(loginUserId: Database.loginUserFirebaseId, loginType: 2);
        // route bottom bar
        // Get.toNamed(AppRoutes.bottomBar);
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          Get.toNamed(AppRoutes.hostBottomBar);
        } else {
          Get.toNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      Utils.showLog(loginModel?.message ?? "");
      Utils.showLog(" login Api Calling Failed !!");
    }
  }

  /// email password login user

  Future<void> onClickSignIn() async {
    if (selectedValue != 1) {
      Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Utils.showLog("Email => ${emailController.text}");
    Utils.showLog("Password => ${passwordController.text}");
    final fcmToken = await FirebaseMessaging.instance.getToken();
    Database.onSetFcmToken(fcmToken ?? "");
    Utils.showLog("fcmToken => ${Database.fcmToken}");

    final identity = (await MobileDeviceIdentifier().getDeviceId())!;
    Database.onSetIdentity(identity);
    Utils.showLog("identity => ${Database.identity}");

    if (emailController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterEmail.name.tr);
      return;
    } else if (passwordController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterPassword.name.tr);
      return;
    }

    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);

      // Check if user exists first before trying Firebase login
      checkUserExistModel = await CheckUserExistApi.callApi(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        identity: Database.identity,
        loginType: 4.toString(),
      );

      Database.onSetUserExist(true);
      Utils.showLog("Database.userExist :: ${Database.userExist}");

      if (checkUserExistModel?.status == true && checkUserExistModel?.isLogin == true) {
        // User exists, proceed to Firebase login
        try {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

          final token = await FirebaseAccessToken.onGet();
          String? firebaseUID = userCredential.user?.uid;

          Utils.showLog("Firebase UID => $firebaseUID");
          Utils.showLog("Firebase Token => $token");

          // Now call the login API with the Firebase credentials
          loginModel = await LoginApi.callApi(
            countryCode: Database.selectedCountryCode,
            loginType: 4,
            email: emailController.text.trim(),
            // password: passwordController.text.trim(),
            identity: Database.identity,
            fcmToken: Database.fcmToken,
            authToken: token,
            authUid: firebaseUID,
          );

          if (loginModel?.status == true) {
            Database.onSetIsLogin(true);
            Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
            Database.onSetSeenOnboarding(true);
            Database.onSetFillProfile(true);

            Get.back(); // Stop loading

            if (loginModel?.signUp == true) {
              Database.onSetFillProfile(false);
              Get.offAllNamed(
                AppRoutes.fillProfileScreen,
                arguments: [Database.loginUserName, Database.loginUserProfilePic, Database.loginUserEmail],
              );
            } else {
              Database.onSetFillProfile(true);
              await onGetProfile(loginUserId: userCredential.user!.uid, loginType: 4);
              // Get.toNamed(AppRoutes.bottomBar);
              if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
                fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
                  loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                );
                Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
                if (fetchListenerProfileModel?.status == false) {
                  Utils.showLog(fetchListenerProfileModel?.message ?? "");
                }
                Database.fetchListenerProfileModel = fetchListenerProfileModel;

                Get.toNamed(AppRoutes.hostBottomBar);
              } else {
                Get.toNamed(AppRoutes.bottomBar);
              }
            }
          } else {
            Utils.showToast(Get.context!, loginModel?.message ?? EnumLocale.txtSomeThingWentWrong.name.tr);
            Utils.showLog("Login API call failed");
          }
        } catch (firebaseError) {
          // Firebase sign-in error handling
          Get.back();
          isLoading = false;
          Utils.showToast(Get.context!, "invalid or expired credential.");
          Utils.showLog("Firebase Sign-In Failed => $firebaseError");
        }
      } else {
        if (checkUserExistModel?.status == false && checkUserExistModel?.isLogin == false) {
          Get.back();
          Utils.showToast(Get.context!, checkUserExistModel?.message ?? "Password doesn't match for this user.");
        } else {
          Get.back();
          Utils.showToast(Get.context!, EnumLocale.txtYoumusthavesignup.name.tr);
          Get.toNamed(AppRoutes.register);
        }
      }
    } catch (e) {
      Get.back();
      isLoading = false;
      Utils.showToast(Get.context!, "Error: ${e.toString()}");
      Utils.showLog("Sign In Failed => $e");
    }
  }

  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl = Database.appConfigurationModel?.data?.userPrivacyPolicyUrl ?? '';

    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }
}

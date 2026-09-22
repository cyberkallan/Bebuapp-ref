import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/aap_configuration_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class Database {
  static final localStorage = GetStorage();
  static const String stripeUrl = "https://api.stripe.com/v1/payment_intents";

  static FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  static FetchListenerProfileModel? fetchListenerProfileModel;
  static SettingApiModel? settingApiModel;
  static AppConfigurationModel? appConfigurationModel;

  // static GetCountryModel? getCountryModel;

  static Future<void> init(String identity, String fcmToken) async {
    Utils.showLog("Local Database Initialize....");
    Utils.showLog("fcmToken $fcmToken");
    Utils.showLog("identity $identity");

    onSetFcmToken(fcmToken);
    onSetIdentity(identity);

    Utils.showLog("Stored fcmToken: $fcmToken");
    Utils.showLog("Stored identity: $identity");

    Utils.showLog("Is New User => $isNewUser");

    if (isNewUser == false) {
      final token = await FirebaseAccessToken.onGet();

      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: loginUserFirebaseId, token: token ?? '');
    }

    if (isListener) {
      // fetchSellerDetailsModel = await FetchSellerDetailsApi.callApi(sellerId: sellerId, userId: loginUserId);
      // Database.onSetSellerPayoutAmount(fetchSellerDetailsModel?.data?.payoutAmount ?? 0);
    }
  }

  // >>>>> >>>>> Get Language Database <<<<< <<<<<

  static String get selectedLanguage => localStorage.read("language") ?? Constant.languageEn;
  static String get languageCountryCode => localStorage.read("languageCountryCode") ?? Constant.countryCodeEn;

  // >>>>> >>>>> Get Login Database <<<<< <<<<<

  static String get fcmToken => localStorage.read("fcmToken") ?? "";
  static String get identity => localStorage.read("identity") ?? "";

  static bool get isSeenOnBoarding => localStorage.read("isSeenOnBoarding") ?? false;

  /// User preference: WhatsApp-style tones in chat (Settings → Conversation tones).
  static bool get chatTones => localStorage.read("chatTones") ?? true;
  static Future<void> onSetChatTones(bool on) => localStorage.write("chatTones", on);
  static bool get isNewUser => localStorage.read("isNewUser") ?? true;
  static bool get isLogin => localStorage.read("isLogin") ?? false;
  static bool get isFillProfile => localStorage.read("isFillProfile") ?? false;
  static bool get isListener => localStorage.read("isListener") ?? false;
  static bool get userExist => localStorage.read("userExist") ?? false;
  static bool get isListeners => localStorage.read("isListeners") ?? false;
  static int get loginType => localStorage.read("loginType") ?? 0;
  static String get loginUserId => localStorage.read("loginUserId") ?? "";
  static String get loginUserFirebaseId => localStorage.read("loginUserFirebaseId") ?? "";
  static String get loginUserProfilePic => localStorage.read("loginUserProfilePic") ?? "";
  static String get loginUserEmail => localStorage.read("loginUserEmail") ?? "";
  static String get country => localStorage.read("country") ?? "";
  static String get countryFlag => localStorage.read("countryFlag") ?? "";
  static String get loginUserName => localStorage.read("loginUserName") ?? "";
  static String get loginUserNickName => localStorage.read("loginUserNickName") ?? "";
  static String get loginUserPhoneNumber => localStorage.read("loginUserPhoneNumber") ?? "";
  static String get loginUserBirthDate => localStorage.read("loginUserBirthDate") ?? "";
  static String get loginUserGender => localStorage.read("loginUserGender") ?? "Male";
  static String get sellerId => localStorage.read("sellerId") ?? "";
  static num get sellerPayoutAmount => localStorage.read("sellerPayoutAmount") ?? 0;
  static String get selectedCountryCode => localStorage.read("countryCode") ?? "IN";

  static String get loginListenerId => localStorage.read("loginListenerId") ?? "";
  static String get userCoin => localStorage.read("userCoin") ?? 0.toString();
  static String get listenerCoin => localStorage.read("listenerCoin") ?? 0.toString();

  /// localization
  static int get languageIndex => localStorage.read("languageIndex") ?? 3;

  static List<String> get searchData {
    final data = localStorage.read("searchData");
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }
  // >>>>> >>>>> Video Call <<<<< <<<<<

  // >>>>> >>>>> Set Language Database <<<<< <<<<<

  static onSetSelectedLanguage(String language) async => await localStorage.write("language", language);
  static onSetSelectedLanguageCountryCode(String languageCountryCode) async => await localStorage.write("languageCountryCode", languageCountryCode);

  // >>>>> >>>>> Notification Database <<<<< <<<<<

  static bool get isShowNotification => localStorage.read("isShowNotification") ?? true;

  static onSetNotification(bool isShowNotification) async => localStorage.write("isShowNotification", isShowNotification);

  // >>>>> >>>>> Set Login Database <<<<< <<<<<

  static onSetFcmToken(String fcmToken) async => await localStorage.write("fcmToken", fcmToken);
  static onSetIdentity(String identity) async => await localStorage.write("identity", identity);
  static onSetSeenOnboarding(bool isSeenOnBoarding) async => await localStorage.write("isSeenOnBoarding", isSeenOnBoarding);
  static onSetIsNewUser(bool isNewUser) async => await localStorage.write("isNewUser", isNewUser);
  static onSetIsLogin(bool isLogin) async => await localStorage.write("isLogin", isLogin);
  static onSetFillProfile(bool isFillProfile) async => await localStorage.write("isFillProfile", isFillProfile);
  static onSetIsListener(bool isListener) async => await localStorage.write("isListener", isListener);
  static onSetLoginType(int loginType) async => localStorage.write("loginType", loginType);
  static onSetLoginUserId(String loginUserId) async => localStorage.write("loginUserId", loginUserId);
  static onSetLoginUserFirebaseId(String loginUserFirebaseId) async => localStorage.write("loginUserFirebaseId", loginUserFirebaseId);
  static onSetLoginUserProfilePic(String loginUserProfilePic) async => localStorage.write("loginUserProfilePic", loginUserProfilePic);
  static onSetLoginUserEmail(String loginUserEmail) async => localStorage.write("loginUserEmail", loginUserEmail);
  static onSetLoginUserCountryFlag(String countryFlag) async => localStorage.write("countryFlag", countryFlag);
  static onSetLoginUserCountry(String country) async => localStorage.write("country", country);
  static onSetLoginUserName(String loginUserName) async => localStorage.write("loginUserName", loginUserName);
  static onSetLoginUserNickName(String loginUserNickName) async => localStorage.write("loginUserNickName", loginUserNickName);
  static onSetLoginUserPhoneNumber(String loginUserPhoneNumber) async => localStorage.write("loginUserPhoneNumber", loginUserPhoneNumber);
  static onSetLoginUserBirthDate(String loginUserBirthDate) async => localStorage.write("loginUserBirthDate", loginUserBirthDate);
  static onSetLoginUserGender(String loginUserGender) async => localStorage.write("loginUserGender", loginUserGender);
  static onSetUserExist(bool userExist) async => localStorage.write("userExist", userExist);
  static onSetIsListeners(bool isListeners) async => localStorage.write("isListeners", isListeners);
  static onSetSelectedCountryCode(String countryCode) async => await localStorage.write("countryCode", countryCode);
  static onSetLoginListenerId(String loginListenerId) async => localStorage.write("loginListenerId", loginListenerId);
  static onSetUserCoin(String userCoin) async => localStorage.write("userCoin", userCoin);
  static onSetListenerCoin(String listenerCoin) async => localStorage.write("listenerCoin", listenerCoin);

  static onSetLanguageIndex(int languageIndex) async => localStorage.write("languageIndex", languageIndex);

  static Future<void> onSetSearchDataStore(List<String> searchData) async => await localStorage.write("searchData", searchData);

  // >>>>> >>>>> Video Call <<<<< <<<<<

  static String? dialCode;
  static String? countryCode;
  static getDialCode() {
    CountryCode getCountryDialCode(String countryCode) {
      return CountryCode.fromCountryCode(countryCode);
    }

    CountryCode country = getCountryDialCode(countryCode ?? "IN");
    log("country.Dial code :: ${country.dialCode}");

    dialCode = country.dialCode;
    log("Dial code :: $dialCode");
  }

  static Future<void> onLogOut() async {
    final identityDevice = identity;
    final fcmTokenFirebase = fcmToken;

    if (loginType == 1) {
      Utils.showLog("Google Logout Success");
      await GoogleSignIn().signOut();
    }

    localStorage.erase();

    log("logout app language $selectedLanguage");

    onSetFcmToken(fcmTokenFirebase);
    onSetIdentity(identityDevice);
    SocketService.socketDisConnect();

    Database.onSetLanguageIndex(3);
    Database.onSetSelectedLanguage(Constant.languageEn);
    Database.onSetSelectedLanguageCountryCode(Constant.countryCodeEn);
    Database.onSetSeenOnboarding(true);
    Get.offAllNamed(AppRoutes.main);

    // Update the UI
    Get.updateLocale(Locale(Constant.languageEn, Constant.countryCodeEn));
  }
}

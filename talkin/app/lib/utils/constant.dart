import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Constant {
  /// =================== Id For Refresh Widgets =================== ///
  static var idOnBoarding = 'idOnBoarding';
  static var radioButton = 'radioButton';
  static var idAcceptTerms = 'idAcceptTerms';
  static var idCheckMobile = 'idCheckMobile';
  static var idVerification = 'idVerification';
  static var idLoginOrSignUp = 'idLoginOrSignUp';
  static var idBottomBar = 'idBottomBar';
  static var idVideoCall = 'idVideoCall';
  static var idSpeakerOpen = 'idSpeakerOpen';
  static var idMicMute = 'idMicMute';
  static var idGenderSelect = 'idGenderSelect';
  static var idSwitchOn = 'idSwitchOn';
  static var idResendOtp = 'idResendOtp';
  static var idVerifyOtp = 'idVerifyOtp';
  static var idGetListener = 'idGetListener';
  static var idPaginationListener = 'idPaginationListener';
  static var idCallingHistory = 'idCallingHistory';
  static var idChangeAudioRecordingEvent = 'onChangeAudioRecordingEvent';
  static var idVideoTurn = 'idVideoTurn';
  static var idCameraTurn = 'idCameraTurn';
  static var idTabChange = 'idTabChange';
  static var idRating = 'idRating';
  static var idChangeCountry = 'idChangeCountry';
  static var onChangePaymentMethod = 'onChangePaymentMethod';
  static var idChangeLanguage = 'idChangeLanguage';
  static var onInitializeCamera = 'onInitializeCamera';
  static var idOnVideoCall = 'idOnVideoCall';
  static var idMuteMic = 'idMuteMic';
  static var idToggleCamera = 'idToggleCamera';
  static var idToggleVideo = 'idToggleVideo';
  static var initializeVideoPlayer = 'initializeVideoPlayer';

  /// =================== Id For Refresh API`s Response =================== ///
  static var idLogin = 'idLogin';
  static var idProfile = 'idProfile';
  static var idIdentityProof = 'idIdentityProof';
  static var idAllLanguage = 'idAllLanguage';
  static var idBecomeHost = 'idBecomeHost';
  static var idFAQListeners = 'idFAQListeners';
  static var idFAQUser = 'idFAQUser';
  static var listenerProfile = 'listenerProfile';
  static var talkAboutTopic = 'talkAboutTopic';
  static var idAllListener = 'idAllListener';
  static var idLanguageSection = 'idLanguageSection';
  static var idChatList = 'idChatList';
  static var idGetOldChat = 'idGetOldChat';
  static var idSendMsg = 'idSendMsg';
  static var idPagination = 'onPagination';
  static var idPaymentHistory = 'idPaymentHistory';
  static var idCoinHistory = 'idCoinHistory';
  static var idPaymentOption = 'idPaymentOption';
  static var idWithdrawRecord = 'idWithdrawRecord';
  static var idSearchListener = 'idSearchListener';
  static var idUserNotification = 'idUserNotification';
  static var idCoinUpdate = 'idCoinUpdate';
  static var idPhoneFieldUpdate = 'idPhoneFieldUpdate';
  static var idGetListenerReview = 'idGetListenerReview';

  /// =================== Id For Coin Plan =================== ///
  static var idGetCoinPlan = 'idGetCoinPlan';

  /// =================== Get Storage (Local Storage) =================== ///
  static final storage = GetStorage();

  /// =================== Localization =================== ///
  static const languageEn = "en";
  static const countryCodeEn = "US";

  /// =================== Stripe Merchant =================== ///
  static const stripeMerchantCountryCode = 'IN';

  /// =================== Country Name List =================== ///
  static List countryList = [
    {"country": "Arabic", "code": "ع", "id": "1"},
    {"country": "Bengali", "code": "ব", "id": "2"},
    {"country": "Chinese", "code": "中", "id": "3"},
    {"country": "English", "code": "E", "id": "4"},
    {"country": "French", "code": "F", "id": "5"},
    {"country": "German", "code": "D", "id": "6"},
    {"country": "Hindi", "code": "ह", "id": "7"},
    {"country": "Italian", "code": "B", "id": "8"},
    {"country": "Indonesian", "code": "I", "id": "9"},
    {"country": "Korean", "code": "한", "id": "10"},
    {"country": "Portuguese", "code": "P", "id": "11"},
    {"country": "Russian", "code": "Р", "id": "12"},
    {"country": "Spanish", "code": "S", "id": "13"},
    {"country": "Swahili", "code": "S", "id": "14"},
    {"country": "Turkish", "code": "த", "id": "15"},
    {"country": "Telugu", "code": "ట", "id": "16"},
    {"country": "Tamil", "code": "T", "id": "17"},
    {"country": "Urdu", "code": "ا", "id": "18"},
  ];

  /// =================== Shimmers =================== ///
  // static Color baseColor = AppColors.shimmerGrey.withValues(alpha: 0.6);
  static Color highlightColor = Colors.grey.withValues(alpha: 0.2);
  static Duration period = const Duration(milliseconds: 500);
}

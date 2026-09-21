import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_app_language_screen/binding/host_app_language_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_app_language_screen/view/host_app_language_screen.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/binding/host_bottom_bar_binding.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/view/host_bottom_bar_screen.dart';
import 'package:talk_in/ui/host_flow/host_chat_list_search_screen/binding/host_chat_list_search_binding.dart';
import 'package:talk_in/ui/host_flow/host_chat_list_search_screen/view/host_chat_list_search_view.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/binding/host_coin_history_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/view/host_coin_history_screen_view.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/binding/host_help_center_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/view/host_help_center_screen.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/binding/host_home_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/view/host_home_screen.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/binding/host_listeners_detail_binding.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/view/host_listeners_detail_screen.dart';
import 'package:talk_in/ui/host_flow/host_notification/binding/host_notification_binding.dart';
import 'package:talk_in/ui/host_flow/host_notification/view/host_notification.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/binding/host_personal_chat_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/view/host_personal_chat_screen.dart';
import 'package:talk_in/ui/host_flow/host_profile_detail_screen/binding/host_profile_detail_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_profile_detail_screen/view/host_profile_detail_screen_view.dart';
import 'package:talk_in/ui/host_flow/host_profile_screen/view/host_profile_screen_view.dart';
import 'package:talk_in/ui/host_flow/host_select_gender_screen/binding/host_select_gender_screen_binding.dart';
import 'package:talk_in/ui/host_flow/host_select_gender_screen/view/host_select_gender_screen.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/binding/host_setting_binding.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/view/host_setting_view.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/binding/host_withdraw_coin_binding.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/view/host_withdraw_coin_view.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/view/user_profile_detail_screen.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/binding/all_listeners_binding.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/view/all_listeners_screen.dart';
import 'package:talk_in/ui/user_flow/all_review_screen/binding/all_review_binding.dart';
import 'package:talk_in/ui/user_flow/all_review_screen/view/all_review_screen.dart';
import 'package:talk_in/ui/user_flow/app_language_screen/binding/app_language_screen_binding.dart';
import 'package:talk_in/ui/user_flow/app_language_screen/view/app_language_screen.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/binding/become_host_screen_binding.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/view/become_host_screen.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/binding/bottom_bar_binding.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/view/bottom_bar_screen.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/binding/call_cut_binding.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/view/call_cut_screen.dart';
import 'package:talk_in/ui/user_flow/chat_list_search_screen/binding/chat_list_search_binding.dart';
import 'package:talk_in/ui/user_flow/chat_list_search_screen/view/chat_list_search_view.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/binding/coin_history_screen_binding.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/view/coin_history_screen_view.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/binding/coin_purchase_screen_binding.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/view/coin_purchase_screen.dart';
import 'package:talk_in/ui/user_flow/create_new_password_screen/binding/create_new_password_binding.dart';
import 'package:talk_in/ui/user_flow/create_new_password_screen/view/create_new_password_screen.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/binding/edit_profile_screen_binding.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/view/edit_profile_screen_view.dart';
import 'package:talk_in/ui/user_flow/fake_audio_call_screen/binding/fake_audio_call_binding.dart';
import 'package:talk_in/ui/user_flow/fake_audio_call_screen/view/fake_audio_call_screen.dart';
import 'package:talk_in/ui/user_flow/fake_outgoing_call_screen/binding/fake_outgoing_call_binding.dart';
import 'package:talk_in/ui/user_flow/fake_outgoing_call_screen/view/fake_outgoing_call_screen.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/binding/fake_video_call_binding.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/view/fake_video_call_view.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/binding/fill_profile_screen_binding.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/view/fill_profile_screen_view.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/binding/forgot_password_binding.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/view/forgot_password_screen.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/binding/help_center_screen_binding.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/view/help_center_screen.dart';
import 'package:talk_in/ui/user_flow/home_screen/binding/home_screen_binding.dart';
import 'package:talk_in/ui/user_flow/home_screen/view/home_screen.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/binding/host_request_sent_successfully_binding.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/view/host_request_sent_successfully_screen.dart';
import 'package:talk_in/ui/user_flow/host_verification_listeners_detail_screen/view/host_verification_listeners_detail_screen.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/binding/host_verification_binding.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/view/host_verification_screen.dart';
import 'package:talk_in/ui/user_flow/incoming_call_screen/binding/incoming_call_binding.dart';
import 'package:talk_in/ui/user_flow/incoming_call_screen/view/incoming_call_screen.dart';
import 'package:talk_in/ui/user_flow/main_screen/binding/main_screen_binding.dart';
import 'package:talk_in/ui/user_flow/main_screen/view/main_screen.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/binding/mobile_number_binding.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/view/mobile_number_screen.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/binding/my_profile_screen_binding.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/view/my_profile_screen_view.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/binding/my_wallet_screen_binding.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/view/my_wallet_screen.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/binding/on_boarding_binding.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/view/onboarding_screen.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/binding/outgoing_call_binding.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/view/outgoing_audio_call_screen.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/view/outgoing_call_screen.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/binding/personal_chat_screen_binding.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/view/personal_chat_screen.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/binding/profile_detail_screen_binding.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/view/profile_detail_screen_view.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/binding/random_call_binding.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/widget/random_match_view.dart';
import 'package:talk_in/ui/user_flow/registration_screen/binding/registration_binding.dart';
import 'package:talk_in/ui/user_flow/registration_screen/view/registration_screen.dart';
import 'package:talk_in/ui/user_flow/search_screen/binding/search_screen_binding.dart';
import 'package:talk_in/ui/user_flow/search_screen/view/search_screen_view.dart';
import 'package:talk_in/ui/user_flow/select_gender_screen/binding/select_gender_screen_binding.dart';
import 'package:talk_in/ui/user_flow/select_gender_screen/view/select_gender_screen.dart';
import 'package:talk_in/ui/user_flow/setting_screen/binding/setting_binding.dart';
import 'package:talk_in/ui/user_flow/setting_screen/view/setting_view.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/binding/splash_screen_binding.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/view/splash_screen_view.dart';
import 'package:talk_in/ui/user_flow/top_listeners_view_all/binding/top_listeners_view_all_binding.dart';
import 'package:talk_in/ui/user_flow/top_listeners_view_all/view/top_listeners_view_all_screen.dart';
import 'package:talk_in/ui/user_flow/user_notification/binding/user_notification_binding.dart';
import 'package:talk_in/ui/user_flow/user_notification/view/user_notification.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/binding/verify_otp_binding.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/view/verify_otp_screen.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/binding/video_call_binding.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/view/video_call_screen.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/binding/voice_call_binding.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/view/voice_call_screen.dart';

class AppPages {
  static List<GetPage> list = [
    GetPage(
      name: AppRoutes.splashScreenPage,
      // page: () => MyApp(),
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.fillProfileScreen,
      page: () => FillProfileScreen(),
      binding: FillProfileScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.onBoarding,
      page: () => const OnBoardingScreen(),
      binding: OnBoardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: MainScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegistrationScreen(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: AppRoutes.mobileLogIn,
      page: () => const MobileNumberScreen(),
      binding: MobileNumberBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpScreen(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: AppRoutes.bottomBar,
      page: () => const BottomBarScreen(),
      binding: BottomBarBinding(),
    ),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
      binding: HomeScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.topListenersViewAll,
      page: () => TopListenersViewAllScreen(),
      binding: TopListenersViewAllBinding(),
    ),
    GetPage(
      name: AppRoutes.allListeners,
      page: () => const AllListenersScreen(),
      binding: AllListenersBinding(),
    ),
    GetPage(
      name: AppRoutes.searchScreen,
      page: () => const SearchScreenView(),
      binding: SearchScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.profileDetailScreenView,
      page: () => const ProfileDetailScreenView(),
      binding: ProfileDetailScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.personalChatScreen,
      page: () => PersonalChatScreen(),
      binding: PersonalChatScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.outgoingCallScreen,
      page: () => OutgoingCallScreen(),
      binding: OutgoingCallBinding(),
    ),
    GetPage(
      name: AppRoutes.outgoingAudioCallScreen,
      page: () => OutgoingAudioCallScreen(),
      binding: OutgoingCallBinding(),
    ),
    GetPage(
      name: AppRoutes.incomingCallScreen,
      page: () => IncomingCallScreen(),
      binding: IncomingCallBinding(),
    ),
    GetPage(
      name: AppRoutes.videoCallScreen,
      page: () => VideoCallScreen(),
      binding: VideoCallBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceCallScreen,
      page: () => VoiceCallScreen(),
      binding: VoiceCallBinding(),
    ),
    GetPage(
      name: AppRoutes.callCutScreen,
      page: () => CallCutScreen(),
      binding: CallCutBinding(),
    ),
    GetPage(
      name: AppRoutes.myProfileScreen,
      page: () => MyProfileScreen(),
      binding: MyProfileScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfileScreen,
      page: () => EditProfileScreen(),
      binding: EditProfileScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.selectGenderScreen,
      page: () => SelectGenderScreen(),
      binding: SelectGenderScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.myWalletScreen,
      page: () => MyWalletScreen(),
      binding: MyWalletScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.coinHistoryScreen,
      page: () => CoinHistoryScreen(),
      binding: CoinHistoryScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.settingScreen,
      page: () => SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: AppRoutes.helpCenterScreen,
      page: () => HelpCenterScreen(),
      binding: HelpCenterScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.becomeHostScreen,
      page: () => BecomeHostScreen(),
      binding: BecomeHostScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.appLanguageScreen,
      page: () => AppLanguageScreen(),
      binding: AppLanguageScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.hostVerificationScreen,
      page: () => HostVerificationScreen(),
      binding: HostVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.hostRequestSentSuccessfullyScreen,
      page: () => HostRequestSentSuccessfullyScreen(),
      binding: HostRequestSentSuccessfullyBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.createNewPassScreen,
      page: () => CreateNewPasswordScreen(),
      binding: CreateNewPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.randomMatchView,
      page: () => RandomMatchView(),
      binding: RandomCallBinding(),
    ),
    GetPage(
      name: AppRoutes.chatListSearchView,
      page: () => ChatListSearchView(),
      binding: ChatListSearchBinding(),
    ),
    GetPage(
      name: AppRoutes.fakeOutgoingCall,
      page: () => FakeOutgoingCallScreen(),
      binding: FakeOutgoingCallBinding(),
    ),
    GetPage(
      name: AppRoutes.fakeVideoCall,
      page: () => FakeVideoCallScreen(),
      binding: FakeVideoCallBinding(),
    ),
    GetPage(
      name: AppRoutes.fakeAudioCall,
      page: () => FakeAudioCallScreen(),
      binding: FakeAudioCallBinding(),
    ),
    GetPage(
      name: AppRoutes.allReviewScreen,
      page: () => AllReviewScreen(),
      binding: AllReviewBinding(),
    ),

    /// Listener
    GetPage(
      name: AppRoutes.hostHomeScreen,
      page: () => const HostHomeScreen(),
      binding: HostHomeScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.hostBottomBar,
      page: () => HostBottomBarScreen(),
      binding: HostBottomBarBinding(),
    ),

    GetPage(
      name: AppRoutes.hostPersonalChatScreen,
      page: () => HostPersonalChatScreen(),
      binding: HostPersonalChatScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.hostViewCoinHistory,
      page: () => HostCoinHistoryScreen(),
      binding: HostCoinHistoryScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.hostWithdrawCoinScreen,
      page: () => HostWithdrawCoinScreen(),
      binding: HostWithdrawCoinBinding(),
    ),

    GetPage(
      name: AppRoutes.hostSettingScreen,
      page: () => HostSettingScreen(),
      binding: HostSettingBinding(),
    ),
    GetPage(
      name: AppRoutes.hostHelpCenterScreen,
      page: () => HostHelpCenterScreen(),
      binding: HostHelpCenterScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.hostSelectGenderScreen,
      page: () => HostSelectGenderScreen(),
      binding: HostSelectGenderScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.hostAppLanguageScreen,
      page: () => HostAppLanguageScreen(),
      binding: HostAppLanguageScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.hostListenersDetailScreen,
      page: () => HostListenersDetailScreen(),
      binding: HostListenersDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.hostProfileDetailScreen,
      page: () => HostProfileDetailScreenView(),
      binding: HostProfileDetailScreenBinding(),
    ),

    GetPage(
      name: AppRoutes.userNotificationView,
      page: () => UserNotificationScreen(),
      binding: UserNotificationBinding(),
    ),

    GetPage(
      name: AppRoutes.hostVerificationListenersDetailScreen,
      page: () => HostVerificationListenersDetailScreen(),
      binding: VoiceCallBinding(),
    ),
    GetPage(
      name: AppRoutes.hostProfileScreen,
      page: () => HostProfileScreen(),
      binding: EditProfileScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.hostChatListSearchView,
      page: () => HostChatListSearchView(),
      binding: HostChatListSearchBinding(),
    ),
    GetPage(
      name: AppRoutes.hostNotificationView,
      page: () => HostNotificationScreen(),
      binding: HostNotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.userProfileDetailScreen,
      page: () => UserProfileDetailScreen(),
      binding: HostNotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.coinPurchaseScreen,
      page: () => CoinPurchaseScreen(),
      binding: CoinPurchaseScreenBinding(),
    ),
  ];
}

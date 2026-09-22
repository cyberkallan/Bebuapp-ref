import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:talk_in/custom/custom_web_view/web_view_screen.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/api/avatar_studio_api.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/controller/avatar_studio_controller.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// One step of the "complete your profile" checklist.
class ProfileStep {
  const ProfileStep(this.label, this.done, {this.studio = false});
  final String label;
  final bool done;

  /// Opens the avatar studio / photo picker instead of the edit form.
  final bool studio;
}

class MyProfileScreenController extends GetxController {
  static const idLook = 'profile.look';
  static const idStats = 'profile.stats';

  /// The user's saved studio look, when the studio avatar is their picture.
  StudioData? studio;
  bool loadingLook = true;

  bool get studioEnabled => studio?.settings.enabled ?? AvatarStudioController.enabledBySettings;
  bool get hasStudioLook => studioEnabled && studio?.active == true && studio?.equipped[StudioSlot.avatar] != null;

  Map<StudioSlot, AvatarItem?> get look => {for (final s in StudioSlot.values) s: studio?.byId(studio?.equipped[s])};

  @override
  void onInit() {
    super.onInit();
    refreshLook();
  }

  /// Re-reads the studio state (and the profile behind it). Cheap: one call.
  Future<void> refreshLook() async {
    loadingLook = true;
    update([idLook]);
    studio = await AvatarStudioApi.fetchStudio();
    loadingLook = false;
    update([idLook, idStats]);
  }

  /// Full profile reload after returning from edit / studio.
  Future<void> refreshProfile() async {
    final token = await FirebaseAccessToken.onGet();
    final m = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
    if (m?.user != null) {
      Database.fetchLoginUserProfileModel = m;
      final u = m!.user!;
      if ((u.profilePic ?? '').isNotEmpty) Database.onSetLoginUserProfilePic(u.profilePic!);
      if ((u.nickName ?? '').isNotEmpty) Database.onSetLoginUserNickName(u.nickName!);
      if ((u.fullName ?? '').isNotEmpty) Database.onSetLoginUserName(u.fullName!);
      Database.onSetUserCoin((u.coins ?? 0).toString());
    }
    await refreshLook();
    update();
  }

  List<ProfileStep> get steps {
    final u = Database.fetchLoginUserProfileModel?.user;
    final pic = Database.loginUserProfilePic;
    final hasPic = pic.isNotEmpty && !pic.endsWith('male.png') && !pic.endsWith('female.png');
    return [
      ProfileStep(studioEnabled ? 'Create your avatar' : 'Add a profile photo', hasPic || hasStudioLook, studio: true),
      ProfileStep('Choose a nickname', (u?.nickName ?? Database.loginUserNickName).trim().isNotEmpty),
      ProfileStep('Add your birthday', (u?.birthDate ?? Database.loginUserBirthDate).trim().isNotEmpty),
      ProfileStep('Set your gender', (u?.gender ?? Database.loginUserGender).trim().isNotEmpty),
      ProfileStep('Add a phone number', (u?.phoneNumber ?? Database.loginUserPhoneNumber).trim().isNotEmpty),
    ];
  }

  double get completeness {
    final s = steps;
    return s.where((e) => e.done).length / s.length;
  }

  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl = Database.settingApiModel?.data?.userPrivacyPolicyUrl.toString() ?? "";
    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  Future<void> onClickAboutUs() async {
    final String aboutUsUrl = Database.settingApiModel?.data?.aboutUsUrl.toString() ?? "";
    if (aboutUsUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(url: aboutUsUrl, screen: "About Us"));
    } else {
      log('Invalid About us URL');
    }
  }

  Future<void> onClickShare() async {
    Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse("https://play.google.com/store/apps/details?id=${Utils.playStoreId}");
    } else if (Platform.isIOS) {
      url = Uri.parse("https://apps.apple.com/app/${Utils.appStoreId}");
    } else {
      throw 'Unsupported platform';
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

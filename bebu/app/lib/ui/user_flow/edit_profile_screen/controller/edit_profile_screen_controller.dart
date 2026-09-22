import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/custom_country_picker/country_picker.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:talk_in/ui/user_flow/rewards/controller/rewards_controller.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

/// Edit-profile form state. The instance is long-lived (the profile screen
/// listens to it for [Constant.idProfile] broadcasts), so the form reloads
/// its fields from storage every time the screen opens via [load].
class EditProfileController extends GetxController {
  static const idForm = 'edit.form';

  final formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final nickNameCnt = TextEditingController();
  final nameCnt = TextEditingController();
  final bioCnt = TextEditingController();
  final emailCnt = TextEditingController();
  final genderCnt = TextEditingController();
  final mobileNumberCnt = TextEditingController();
  final flagController = TextEditingController();
  final countryController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  XFile? xFiles;
  int selectedIndex = 0; // 0 male, 1 female
  String? profilePic;
  String? pickImage;
  EditProfileModel? editProfileModel;
  String? dialCode;
  bool saving = false;

  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  @override
  void onInit() {
    load();
    super.onInit();
  }

  /// Copies the stored profile into the text fields (discarding unsaved edits).
  void load() {
    dateController.text = Database.loginUserBirthDate;
    nameCnt.text = Database.loginUserName;
    bioCnt.text = Database.loginUserBio;
    emailCnt.text = Database.loginUserEmail;
    nickNameCnt.text = Database.loginUserNickName;
    genderCnt.text = Database.loginUserGender;
    mobileNumberCnt.text = Database.loginUserPhoneNumber;
    countryController.text = Database.country;
    flagController.text = Database.countryFlag;
    profilePic = Database.loginUserProfilePic;
    dialCode = Database.dialCode;
    pickImage = null;
    xFiles = null;
    selectedIndex = Database.loginUserGender.toLowerCase() == 'female' ? 1 : 0;
    update([idForm, Constant.idGenderSelect, Constant.idChangeCountry]);
  }

  bool get isDirty =>
      pickImage != null ||
      dateController.text != Database.loginUserBirthDate ||
      nameCnt.text != Database.loginUserName ||
      bioCnt.text != Database.loginUserBio ||
      nickNameCnt.text != Database.loginUserNickName ||
      mobileNumberCnt.text != Database.loginUserPhoneNumber ||
      countryController.text != Database.country ||
      selectedGenderText.toLowerCase() != Database.loginUserGender.toLowerCase();

  List<Map<String, dynamic>> get gender => [
        {"txt": EnumLocale.txtMale.name.tr, "image": AppAsset.maleImage},
        {"txt": EnumLocale.txtFemale.name.tr, "image": AppAsset.femaleImage},
      ];

  String get selectedGenderText => selectedIndex == 1 ? 'Female' : 'Male';

  /// Gender is only persisted on save (used to write straight to storage).
  void selectGender(int index) {
    if (selectedIndex == index) return;
    selectedIndex = index;
    genderCnt.text = gender[index]['txt'];
    Sfx.tick();
    update([Constant.idGenderSelect, idForm]);
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime initial = DateTime(DateTime.now().year - 20);
    final parts = dateController.text.split('/').map((e) => e.trim()).toList();
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]), m = int.tryParse(parts[1]), y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) initial = DateTime(y, m, d);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Your birthday',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: (BebuTheme.isLight ? const ColorScheme.light() : const ColorScheme.dark()).copyWith(
            primary: BebuTheme.pink,
            onPrimary: Colors.white,
            surface: BebuTheme.surface,
            onSurface: BebuTheme.text,
          ),
          dialogTheme: DialogThemeData(backgroundColor: BebuTheme.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusLg))),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: BebuTheme.pink)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateController.text = "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      Sfx.tick();
      update([idForm]);
    }
  }

  Future<void> getImageFromGallery() => _pick(ImageSource.gallery);

  Future<void> takePhoto() => _pick(ImageSource.camera);

  Future<void> _pick(ImageSource source) async {
    xFiles = await imagePicker.pickImage(source: source, imageQuality: 88, maxWidth: 1600);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      Sfx.pop();
    }
    update([idForm]);
  }

  void onChangeCountry(BuildContext context) {
    CustomCountryPicker.pickCountry(context, false, (country) {
      flagController.text = country.flagEmoji;
      countryController.text = country.name;
      Sfx.tick();
      update([Constant.idChangeCountry, idForm]);
    });
  }

  /// Validates and saves. Returns true when the profile was updated.
  Future<bool> onSaveProfile() async {
    if (saving) return false;
    final ctx = Get.context!;
    if ((profilePic ?? '').isEmpty && pickImage == null) {
      Utils.showToast(ctx, EnumLocale.txtPleaseSelectProfileImage.name.tr);
      return false;
    }
    if (nickNameCnt.text.trim().isEmpty) {
      Utils.showToast(ctx, EnumLocale.txtPleaseEnterNickName.name.tr);
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      Utils.showToast(ctx, EnumLocale.txtPleaseSelectBirthDate.name.tr);
      return false;
    }
    if (mobileNumberCnt.text.trim().isEmpty) {
      Utils.showToast(ctx, EnumLocale.txtPleaseEnterMobileNumber.name.tr);
      return false;
    }
    Database.onSetFillProfile(true);
    saving = true;
    update([idForm]);
    final ok = await callEditApi();
    saving = false;
    update([idForm]);
    return ok;
  }

  Future<bool> callEditApi() async {
    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: dateController.text,
      image: pickImage,
      nickName: nickNameCnt.text.trim(),
      gender: selectedGenderText,
      phoneNumber: mobileNumberCnt.text.trim(),
      fullName: nameCnt.text.trim(),
      bio: bioCnt.text.trim(),
    );

    if (editProfileModel?.status != true) {
      Sfx.deny();
      Utils.showToast(Get.context!, editProfileModel?.message ?? EnumLocale.txtSomeThingWentWrong.name.tr);
      return false;
    }

    // The server now saves before responding, so one fetch is enough.
    final token = await FirebaseAccessToken.onGet();
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
    final u = fetchLoginUserProfileModel?.user;
    if (u != null) {
      await Database.onSetLoginUserProfilePic(u.profilePic ?? '');
      await Database.onSetLoginUserName(u.fullName ?? '');
      await Database.onSetLoginUserBio(u.bio ?? bioCnt.text.trim());
      await Database.onSetLoginUserNickName(u.nickName ?? '');
      await Database.onSetLoginUserEmail(u.email ?? '');
      await Database.onSetLoginUserCountry(u.country ?? '');
      await Database.onSetLoginUserCountryFlag(u.countryFlag ?? '');
      await Database.onSetLoginUserBirthDate(u.birthDate ?? '');
      await Database.onSetLoginUserGender(u.gender ?? selectedGenderText);
      await Database.onSetLoginUserPhoneNumber(u.phoneNumber ?? '');
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
    } else {
      // Offline fallback: keep what we sent.
      await Database.onSetLoginUserGender(selectedGenderText);
      await Database.onSetLoginUserNickName(nickNameCnt.text.trim());
      await Database.onSetLoginUserName(nameCnt.text.trim());
      await Database.onSetLoginUserBio(bioCnt.text.trim());
      await Database.onSetLoginUserBirthDate(dateController.text);
      await Database.onSetLoginUserPhoneNumber(mobileNumberCnt.text.trim());
      final pic = editProfileModel?.user?.profilePic;
      if (pic != null && pic.isNotEmpty) await Database.onSetLoginUserProfilePic(pic);
    }
    profilePic = Database.loginUserProfilePic;
    pickImage = null;
    final reward = editProfileModel?.reward;
    if (reward != null) {
      // Profile just became complete: the server granted the coins in the same call.
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) RewardsController.to.celebrate(ctx, reward);
    } else {
      Sfx.select();
    }
    update([Constant.idProfile, idForm]);
    return true;
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/custom_country_picker/country_picker.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/custom/random_name/random_name.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/login_config.dart';
import 'package:talk_in/utils/utils.dart';

class FillProfileScreenController extends GetxController {
  final formKey = GlobalKey<FormState>();
  XFile? xFiles;
  String? name;
  String? email;
  String? photo;
  String? pickImage;
  TextEditingController dateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  EditProfileModel? editProfileModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  int selectedIndex = 0; // Already hase
  String? dialCode;

  final ImagePicker imagePicker = ImagePicker();
  dynamic args = Get.arguments;

  @override
  void onInit() async {
    // await getDataFromArgs();
    // await setDataFromArgs();

    // Set default gender if not stored
    if (Database.loginUserGender.isEmpty) {
      selectedIndex = 0;
      final defaultGender = EnumLocale.txtMale.name.tr;
      genderController.text = defaultGender;
      Database.onSetLoginUserGender(defaultGender);
    } else {
      // Set textfield value from database
      genderController.text = Database.loginUserGender;
      selectedIndex = Database.loginUserGender.toLowerCase() == EnumLocale.txtFemale.name.tr.toLowerCase() ? 1 : 0;
    }
    nameController.text = Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
    emailController.text = Database.fetchLoginUserProfileModel?.user?.email ?? '';
    numberController.text = Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? '';
    photo = Database.fetchLoginUserProfileModel?.user?.profilePic ?? '';
    dialCode = Database.dialCode;
    // Guests get a random display name; Google users their account name.
    nickNameController.text = (Database.fetchLoginUserProfileModel?.user?.nickName ?? '').isNotEmpty ? Database.fetchLoginUserProfileModel!.user!.nickName! : (nameController.text.split(' ').firstOrNull ?? '');
    if (nickNameController.text.trim().isEmpty) nickNameController.text = CustomFetchRandomName.onGet();
    nickNameController.addListener(() => update([idForm]));
    _prefillCountry();

    super.onInit();
  }

  static const idForm = 'fillProfileForm';

  /// Suggest a fresh display name; a tap beats typing on a first-run screen.
  void shuffleName() {
    Sfx.tick();
    nickNameController.text = CustomFetchRandomName.onGet();
    nickNameController.selection = TextSelection.collapsed(offset: nickNameController.text.length);
    update([idForm]);
  }

  /// Steps done out of the three we ask for; drives the progress bar.
  int get completedSteps => (nickNameController.text.trim().length >= 2 ? 1 : 0) + 1 /* gender always has a value */ + (birthDate != null ? 1 : 0);

  /// Welcome coins the user will unlock the moment the profile is saved (0 hides the teaser).
  int get welcomeCoins => LoginConfig.current.showWelcomeBonus ? RewardTeaser.current.welcomeCoins : 0;

  /// Country comes from the IP lookup done on the splash screen; the user can still change it.
  void _prefillCountry() {
    if (countryController.text.isNotEmpty) return;
    final code = Database.selectedCountryCode.isEmpty ? 'IN' : Database.selectedCountryCode.toUpperCase();
    try {
      countryController.text = CountryCode.fromCountryCode(code).name ?? '';
    } catch (_) {
      countryController.text = '';
    }
    flagController.text = code.length == 2 ? String.fromCharCodes(code.codeUnits.map((u) => 0x1F1E6 + (u - 65))) : '';
  }

  /// Age in whole years for the picked birth date, or null.
  int? get age {
    final d = birthDate;
    if (d == null) return null;
    final now = DateTime.now();
    var a = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) a--;
    return a;
  }

  DateTime? birthDate;

  bool get canSubmit => nickNameController.text.trim().length >= 2 && dateController.text.trim().isNotEmpty;

  /// The picked file if any, else the photo we already have (Google / guest), else empty.
  String get displayPhoto => pickImage ?? photo ?? '';
  bool get hasPhoto => displayPhoto.isNotEmpty;

  List<Map<String, dynamic>> gender = [
    {
      "txt": EnumLocale.txtMale.name.tr,
      "image": AppAsset.maleImage,
    },
    {
      "txt": EnumLocale.txtFemale.name.tr,
      "image": AppAsset.femaleImage,
    },
  ];

  /// select gender
  void selectGender(int index) {
    selectedIndex = index;
    final selectedGenderText = gender[selectedIndex]['txt'] ?? 'Male';
    genderController.text = selectedGenderText;

    // Save selected gender locally
    Database.onSetLoginUserGender(selectedGenderText ?? 'Male');

    log("Database.loginUserGender :: ${Database.loginUserGender}");

    Sfx.tick();
    update([Constant.idGenderSelect, idForm]);
  }

  /// select date
  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();
    final adult = DateTime(now.year - 18, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(now.year - 22, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: adult,
      helpText: 'Your birthday',
      builder: (context, child) {
        final light = BebuTheme.isLight;
        final scheme = (light ? const ColorScheme.light() : const ColorScheme.dark()).copyWith(
          primary: BebuTheme.pink,
          onPrimary: Colors.white,
          surface: BebuTheme.surface,
          onSurface: BebuTheme.text,
        );
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme,
            dialogTheme: DialogThemeData(backgroundColor: BebuTheme.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusLg))),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: BebuTheme.pink)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      birthDate = picked;
      dateController.text = "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      Sfx.lightTap();
      update();
    }
  }

  /// Camera / gallery chooser styled like the rest of the app.
  void choosePhoto(BuildContext context) {
    Sfx.tick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
          decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg), border: Border.all(color: BebuTheme.border)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text('Profile photo', style: BebuTheme.title(size: 16)),
              const SizedBox(height: 6),
              _photoOption(Icons.photo_camera_rounded, 'Take a photo', () {
                Get.back();
                takePhoto();
              }),
              _photoOption(Icons.photo_library_rounded, 'Choose from gallery', () {
                Get.back();
                getImageFromGallery();
              }),
              if (hasPhoto)
                _photoOption(Icons.delete_outline_rounded, 'Remove photo', () {
                  Get.back();
                  pickImage = '';
                  photo = '';
                  update();
                }, danger: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? BebuTheme.red : BebuTheme.text;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusSm)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: BebuTheme.surface2, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(label, style: BebuTheme.label(size: 15, color: color)),
    );
  }

  /// Get image from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// Get image from camera
  takePhoto() async {
    xFiles = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Camera Image Path ::: $pickImage");
    }
    update();
  }

  /// save profile button on tap
  Future<void> onSaveProfile() async {
    Utils.showLog("Click On Save Profile => ${Database.loginUserId}");

    if (nickNameController.text.trim().length < 2) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterNickName.name.tr);
    } else if (dateController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseSelectBirthDate.name.tr);
    } else {
      Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

      await callEditApi();
      if (Get.isDialogOpen ?? false) Get.back();
      Database.onSetFillProfile(true);
    }
  }

  /// fill profile api
  Future<void> callEditApi({String? image}) async {
    final token = await FirebaseAccessToken.onGet();

    log('Database.countryCode  ::::  ${Database.selectedCountryCode}');
    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: dateController.text,
      image: pickImage == "" ? photo : pickImage,
      nickName: nickNameController.text,
      gender: Database.loginUserGender,
      phoneNumber: numberController.text,
      fullName: nameController.text,
      email: emailController.text,
    );

    if (editProfileModel?.status == true) {
      Database.fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.onSetLoginUserProfilePic(Database.fetchLoginUserProfileModel?.user?.profilePic ?? "");
      Database.onSetLoginUserName(Database.fetchLoginUserProfileModel!.user!.fullName!);
      Database.onSetLoginUserNickName(Database.fetchLoginUserProfileModel?.user?.nickName ?? "");
      Database.onSetLoginUserEmail(Database.fetchLoginUserProfileModel!.user!.email!);
      Database.onSetLoginUserCountry(Database.fetchLoginUserProfileModel!.user!.country!);
      Database.onSetLoginUserCountryFlag(Database.fetchLoginUserProfileModel!.user!.countryFlag!);
      Database.onSetLoginUserBirthDate(Database.fetchLoginUserProfileModel?.user?.birthDate ?? "");
      Database.onSetLoginUserGender(Database.fetchLoginUserProfileModel?.user?.gender ?? "Male");
      Database.onSetLoginUserPhoneNumber(Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      log(" loginUserProfilePic ::: ${Database.loginUserProfilePic}");

      update([Constant.idProfile]);

      log("${Database.fetchLoginUserProfileModel?.user}");
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      update();

      if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
        Get.offAllNamed(AppRoutes.hostBottomBar);
      } else {
        Get.offAllNamed(AppRoutes.bottomBar);
      }
    } else {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  /// Country select
  Future<void> onChangeCountry(BuildContext context) async {
    debugPrint("onChangeCountry Called");

    CustomCountryPicker.pickCountry(
      context,
      false,
      (country) {
        flagController.text = country.flagEmoji;
        countryController.text = country.name;
        update([Constant.idChangeCountry]);
        debugPrint("Country selected: ${country.name}, Flag: ${country.flagEmoji}");
        Utils.showLog("Selected Country => Flag: ${flagController.text}, Name: ${countryController.text}");
      },
    );

    update([Constant.idChangeCountry]);
  }
}

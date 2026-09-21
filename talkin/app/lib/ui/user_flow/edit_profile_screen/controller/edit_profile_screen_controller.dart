import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/custom_country_picker/country_picker.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController nickNameCnt = TextEditingController();
  TextEditingController nameCnt = TextEditingController();
  TextEditingController emailCnt = TextEditingController();
  TextEditingController genderCnt = TextEditingController();
  TextEditingController mobileNumberCnt = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  XFile? xFiles;
  final ImagePicker imagePicker = ImagePicker();
  int selectedIndex = 0; // Already hase
  String? profilePic;
  String? pickImage;
  EditProfileModel? editProfileModel;
  String? dialCode;

  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  @override
  void onInit() {
    log("Database.loginUserNickName  :: ${Database.loginUserNickName}");
    log("Database.loginUserBirthDate :: ${Database.loginUserBirthDate}");
    log("Database.loginUserEmail  :: ${Database.loginUserEmail}");
    log("Database.loginUserNickName  :: ${Database.loginUserNickName}");
    log("Database.loginUserGender  :: ${Database.loginUserGender}");
    log("Database.loginUserPhoneNumber  :: ${Database.loginUserPhoneNumber}");
    log("Database.loginUserProfilePic  ::  ${Database.loginUserProfilePic}");
    log("fetchLoginUserProfileModel?.user?.country  ::  ${fetchLoginUserProfileModel?.user?.country ?? ''}");
    log("fetchLoginUserProfileModel?.user?.countryFlag  ::  ${fetchLoginUserProfileModel?.user?.countryFlag ?? ''}");

    dateController.text = Database.loginUserBirthDate;
    nameCnt.text = Database.loginUserName;
    emailCnt.text = Database.loginUserEmail;
    nickNameCnt.text = Database.loginUserNickName;
    genderCnt.text = Database.loginUserGender;
    mobileNumberCnt.text = Database.loginUserPhoneNumber;
    countryController.text = Database.country;
    flagController.text = Database.countryFlag;
    profilePic = Database.loginUserProfilePic;
    dialCode = Database.dialCode;

    if (Database.loginUserGender.toLowerCase() == EnumLocale.txtFemale.name.tr.toLowerCase()) {
      selectedIndex = 1;
    } else {
      selectedIndex = 0;
    }

    super.onInit();
  }

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
    genderCnt.text = selectedGenderText;

    // Save selected gender locally
    Database.onSetLoginUserGender(selectedGenderText ?? 'Male');

    log("Database.loginUserGender :: ${Database.loginUserGender}");

    update([Constant.idGenderSelect]);
    // update();
  }

  /// select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.appColor,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 14,
                  fontColor: AppColors.appColor,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text = "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      update(); // For GetBuilder to update
    }
  }

  /// Image Picker from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// Take Photo
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
    Database.onSetFillProfile(true);

    Utils.showLog("Click On Save Profile => ${Database.loginUserId}");

    if (profilePic == "" && pickImage == null) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseSelectProfileImage.name.tr);
    } else if (nickNameCnt.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterNickName.name.tr);
    } else if (dateController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseSelectBirthDate.name.tr);
    } else if (mobileNumberCnt.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterMobileNumber.name.tr);
    } else {
      Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

      await callEditApi();
    }
  }

  /// edit profile api
  Future<void> callEditApi({String? image}) async {
    final token = await FirebaseAccessToken.onGet();

    log('Database.countryCode  ::::  ${Database.selectedCountryCode}');
    log('countryController.text  ::::  ${countryController.text}');
    log('flagController.text  ::::  ${flagController.text}');

    debugPrint("Calling EditProfileApi with following data:");
    debugPrint("country: ${countryController.text}");
    debugPrint("countryFlag: ${flagController.text}");
    debugPrint("countryCode: ${Database.selectedCountryCode}");
    debugPrint("uid: ${Database.loginUserFirebaseId}");
    debugPrint("birthDate: ${dateController.text}");
    debugPrint("image: ${pickImage == "" ? profilePic : pickImage}");
    debugPrint("nickName: ${nickNameCnt.text}");
    debugPrint("gender: ${Database.loginUserGender}");
    debugPrint("phoneNumber: ${mobileNumberCnt.text}");
    debugPrint("fullName: ${nameCnt.text}");

    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: dateController.text,
      image: pickImage == "" ? profilePic : pickImage,
      nickName: nickNameCnt.text,
      gender: Database.loginUserGender,
      phoneNumber: mobileNumberCnt.text,
      fullName: nameCnt.text,
    );

    debugPrint("Calling EditProfileApi with following data:");
    debugPrint("country: ${countryController.text}");
    debugPrint("countryFlag: ${flagController.text}");
    debugPrint("countryCode: ${Database.selectedCountryCode}");
    debugPrint("uid: ${Database.loginUserFirebaseId}");
    debugPrint("birthDate: ${dateController.text}");
    debugPrint("image: ${pickImage == "" ? profilePic : pickImage}");
    debugPrint("nickName: ${nickNameCnt.text}");
    debugPrint("gender: ${Database.loginUserGender}");
    debugPrint("phoneNumber: ${mobileNumberCnt.text}");
    debugPrint("fullName: ${nameCnt.text}");

    if (editProfileModel?.status == true) {
      Utils.showToast(Get.context!, EnumLocale.txtProfileUpdateSuccessfully.name.tr);
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');

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

      update([Constant.idProfile]);

      Get.close(2);
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      update();
    } else {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  /// Country
  Future<void> onChangeCountry(BuildContext context) async {
    CustomCountryPicker.pickCountry(
      context,
      false,
      (country) {
        flagController.text = country.flagEmoji;
        countryController.text = country.name;
        update([Constant.idChangeCountry]);
        debugPrint("Country selected: ${country.name}, Flag: ${country.flagEmoji}");
        log("Selected Country => Flag: ${flagController.text}, Name: ${countryController.text}");
      },
    );

    update([Constant.idChangeCountry]);
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/dialog/request_sent_dialog.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/api/listeners_request_check_api.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/model/listeners_request_check_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/become_host_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/identity_proof_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/become_host_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/identity_proof_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HostVerificationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // final TextEditingController requestIDController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController introCnt = TextEditingController();
  final TextEditingController experienceCnt = TextEditingController();
  final TextEditingController genderCnt = TextEditingController();
  final TextEditingController countryCnt = TextEditingController();
  int selectedTopic = 0;
  List<TalkTopic> talkTopic = [];
  TalkTopicsModel? talkTopicsModel;
  List<String> allLanguages = [];
  List<String> selectedLanguages = [];
  IdentityProofModel? identityProofModel;
  ListenersRequestCheckModel? listenersRequestCheckModel;
  BecomeHostModel? becomeHostModel;
  List<IdentityProof> identityProofList = [];
  IdentityProof? selectedIdentityProof;
  bool isIdentityExpanded = false;
  List<int> selectedTopics = [];

  String? personalPhoto;
  String? idProofPhoto1;
  String? idProofPhoto2;
  final ImagePicker imagePicker = ImagePicker();

  bool isLoading = false;

  @override
  void onInit() {
    loadAllLanguages();
    getIdentityProofApi();
    getTalkTopic();
    emailController.text = Database.fetchLoginUserProfileModel?.user?.email ?? '';
    nickNameController.text = Database.fetchLoginUserProfileModel?.user?.nickName ?? '';
    nameController.text = Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
    genderCnt.text = Database.fetchLoginUserProfileModel?.user?.gender ?? '';
    countryCnt.text = Database.fetchLoginUserProfileModel?.user?.country ?? '';
    super.onInit();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// validation
  void validateAndNext() {
    int? loginType = Database.fetchLoginUserProfileModel?.user?.loginType;

    if (loginType != 2) {
      if (emailController.text.isEmpty) {
        Utils.showToast(Get.context!, "Please enter your Email");
        return;
      }

      if (!isEmailValid(emailController.text)) {
        Utils.showToast(Get.context!, "Please enter a valid Email Address");
        return;
      }
    }

    if (addressController.text.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your Address");
      return;
    }

    if (ageController.text.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your Age");
      return;
    }

    int age = int.tryParse(ageController.text) ?? 0;
    if (age < 18) {
      Utils.showToast(Get.context!, "You must be at least 18 years old");
      return;
    }

    if (selectedIdentityProof == null) {
      Utils.showToast(Get.context!, "Please select an Identity Proof");
      return;
    }

    if (personalPhoto == null) {
      Utils.showToast(Get.context!, "Please upload your Image");
      return;
    }

    if (idProofPhoto1 == null) {
      Utils.showToast(Get.context!, "Please upload your ID Proof Photo");
      return;
    }

    if (idProofPhoto2 == null) {
      Utils.showToast(Get.context!, "Please upload your ID Proof Photo");
      return;
    }

    log("personalPhoto :::::  $personalPhoto");
    log("idProofPhoto111111 :::::  $idProofPhoto1");
    log("idProofPhoto222222 :::::  $idProofPhoto2");

    Get.toNamed(AppRoutes.hostVerificationListenersDetailScreen);
  }

  /// submit button on tap
  void validateAndSubmit() {
    if (nameController.text.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your Name");
      return;
    }

    if (introCnt.text.isEmpty) {
      Utils.showToast(Get.context!, "Please introduce yourself briefly");
      return;
    }

    if (selectedLanguages.isEmpty) {
      Utils.showToast(Get.context!, "Please select at least one language");
      return;
    }

    if (talkTopic.isEmpty || selectedTopic < 0 || selectedTopic >= talkTopic.length) {
      Utils.showToast(Get.context!, "Please select a Talk Topic");
      return;
    }
    if (talkTopic.isEmpty || selectedTopics.isEmpty) {
      Utils.showToast(Get.context!, "Please select at least one Talk Topic");
      return;
    }
    logControllerState(); // Log all values
    Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

    becomeHost();
  }

  void selectTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
    update();
  }

  /// select language
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
    update();
  }

  bool isSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// get all language
  Future<void> loadAllLanguages() async {
    try {
      final String response = await rootBundle.loadString('assets/all_language.json');
      final Map<String, dynamic> data = json.decode(response);

      allLanguages = data.values.map<String>((e) => e.toString()).toList();

      update(); // if using GetX
    } catch (e, st) {
      log('Error loading languages: $e\n$st');
    }
  }

  /// getIdentityProof Api

  void getIdentityProofApi() async {
    try {
      isLoading = true;
      update();
      var data = await IdentityProofApi.callApi();
      identityProofModel = data;

      //  Store the list of Datum in identityProofList
      identityProofList = data?.data ?? [];

      update([Constant.idIdentityProof]);
    } catch (e, st) {
      log('getIdentityProofApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.idIdentityProof]);
      log('getIdentityProofApi finally');
    }
  }

  void toggleIdentityExpansion() {
    isIdentityExpanded = !isIdentityExpanded;
    update([Constant.idIdentityProof]);
  }

  void selectIdentityProof(IdentityProof proof) {
    selectedIdentityProof = proof;
    isIdentityExpanded = false;
    update([Constant.idIdentityProof]);
    // Delay update to allow tile to collapse after tap
    Future.delayed(Duration(milliseconds: 100), () {
      update([Constant.idIdentityProof]);
    });
  }

  Future<void> pickImage({required bool isPersonalPhoto}) async {
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      if (isPersonalPhoto) {
        personalPhoto = pickedFile.path; // Store the selected personal photo path
        log("Selected personal photo path: $personalPhoto");
      } else if (idProofPhoto1 == null) {
        idProofPhoto1 = pickedFile.path; // Store first ID proof photo path
        log("Selected ID proof photo 1 path: $idProofPhoto1");
      } else {
        idProofPhoto2 = pickedFile.path; // Store second ID proof photo path
        log("Selected ID proof photo 2 path: $idProofPhoto2");
      }
      update([Constant.idIdentityProof]); // Update UI
    }
  }

  void getTalkTopic() async {
    try {
      isLoading = true;
      update();
      var data = await TalkTopicApi.callApi();
      talkTopicsModel = data;

      talkTopic = data?.talkTopics ?? [];

      update([Constant.idIdentityProof]);
    } catch (e, st) {
      log('getTalkTopicApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.idIdentityProof]);
      log('getTalkTopicApi finally');
    }
  }

  void logControllerState() {
    log("===== HostVerificationController State =====");
    // log("Request ID: ${requestIDController.text}");
    log("Name: ${nameController.text}");
    log("Email: ${emailController.text}");
    log("Address: ${addressController.text}");
    log("Intro: ${introCnt.text}");

    log("Selected Identity Proof: ${selectedIdentityProof?.title ?? 'None'}");
    log("idProofPhoto1 Photo Path: ${idProofPhoto1 ?? 'Not selected'}");
    log("idProofPhoto2 Photo Path: ${idProofPhoto2 ?? 'Not selected'}");

    log("Selected Languages (${selectedLanguages.length}): ${selectedLanguages.join(', ')}");

    if (talkTopic.isNotEmpty && selectedTopic >= 0 && selectedTopic < talkTopic.length) {
      log("Selected Talk Topic: ${talkTopic[selectedTopic].name}");
    } else {
      log("Selected Talk Topic: None");
    }

    log("===========================================");
  }

  Future<void> becomeHost({String? image}) async {
    List<String> identityProofList = [];
    if (idProofPhoto1 != null && idProofPhoto1!.isNotEmpty) {
      identityProofList.add(idProofPhoto1.toString()); // Add first ID proof photo to the list
    }
    if (idProofPhoto2 != null && idProofPhoto2!.isNotEmpty) {
      identityProofList.add(idProofPhoto2.toString()); // Add second ID proof photo to the list
    }
    log("Experience: ${experienceCnt.text}");
    log("Address: ${addressController.text}");
    log("Email: ${emailController.text}");
    log("Image: ${personalPhoto ?? ''}");
    log("Identity Proof List: $identityProofList");
    log("FCM Token: ${Database.fcmToken}");
    log("Identity Proof Type: ${selectedIdentityProof?.title ?? ''}");
    log("Language: ${selectedLanguages.join(', ').toString()}");
    log("Name: ${nameController.text}");
    log("Nick Name: ${nickNameController.text}");
    log("Self Introduction: ${introCnt.text}");
    log("Talk Topic: ${talkTopic[selectedTopic].name.toString()}");
    log("User ID: ${Database.loginUserFirebaseId}");
    log("Age: ${ageController.text}");
    log("Gender ::: ${genderCnt.text}");

    becomeHostModel = await BecomeHostApi.callApi(
      experience: experienceCnt.text,
      address: addressController.text,
      email: emailController.text,
      image: personalPhoto ?? '',
      identityProof: identityProofList,
      fcmToken: Database.fcmToken,
      identityProofType: selectedIdentityProof?.title ?? '',
      language: selectedLanguages.join(', ').toString(),
      name: nameController.text,
      nickName: nickNameController.text,
      selfIntro: introCnt.text,
      talkTopic: selectedTopics.map((i) => talkTopic[i].name).join(', '),
      uid: Database.loginUserFirebaseId,
      age: ageController.text,
      gender: genderCnt.text,
      country: countryCnt.text,
    );
    update([Constant.idBecomeHost]);
    // Get.toNamed(AppRoutes.bottomBar);
    Get.close(5);
    Get.dialog(
      barrierColor: AppColors.black.withValues(alpha: 0.8),
      Dialog(
        backgroundColor: AppColors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: RequestSentDialog(),
      ),
    );

    listenersRequestCheckModel = await ListenersRequestCheckApi.callApi();

    // Utils.showToast(Get.context!, becomeHostModel?.message ?? "");
  }
}

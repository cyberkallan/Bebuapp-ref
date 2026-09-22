import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/api/host_listener_profile_update_api.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/model/host_listener_profile_update_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class HostListenersDetailController extends GetxController {
  TextEditingController nameCnt = TextEditingController();
  TextEditingController nickNameCnt = TextEditingController();
  TextEditingController introCnt = TextEditingController();
  TextEditingController ratePrivateVideoCallCnt = TextEditingController();
  TextEditingController ratePrivateAudioCallCnt = TextEditingController();
  TextEditingController rateRandomVideoCallCnt = TextEditingController();
  TextEditingController rateRandomAudioCallCnt = TextEditingController();
  int selectedTopic = 0;
  List<String> allLanguages = [];
  List<String> selectedLanguages = [];
  List<TalkTopic> talkTopic = [];
  TalkTopicsModel? talkTopicsModel;
  bool isLoading = false;
  XFile? xFiles;
  final ImagePicker imagePicker = ImagePicker();
  String? pickImage;
  String? profilePic;
  String? selectedTopicName;
  HostListenerProfileUpdateModel? hostListenerProfileUpdateModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  List<int> selectedTopics = [];

  @override
  void onInit() {
    super.onInit();
    loadAllLanguages();

    nameCnt.text = Database.fetchListenerProfileModel?.data?.name ?? '';
    nickNameCnt.text = Database.fetchListenerProfileModel?.data?.nickName ?? '';
    introCnt.text = Database.fetchListenerProfileModel?.data?.selfIntro ?? '';
    rateRandomVideoCallCnt.text = Database.fetchListenerProfileModel?.data?.rateRandomVideoCall.toString() ?? '';
    rateRandomAudioCallCnt.text = Database.fetchListenerProfileModel?.data?.rateRandomAudioCall.toString() ?? '';
    ratePrivateAudioCallCnt.text = Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall.toString() ?? '';
    ratePrivateVideoCallCnt.text = Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall.toString() ?? '';
    profilePic = Database.fetchListenerProfileModel?.data?.image;

    final savedLanguages = Database.fetchListenerProfileModel?.data?.language;
    if (savedLanguages != null && savedLanguages.isNotEmpty) {
      selectedLanguages = List<String>.from(savedLanguages);
    } else {
      selectedLanguages = []; // empty if no saved languages
    }

    update([Constant.idLanguageSection]);

    getTalkTopic();
  }

  /// select talk topic
  void selectTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
    update([Constant.talkAboutTopic]);
  }

  /// select unselect language
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
      log("selectedLanguages ::: $selectedLanguages");
    }
    update([Constant.idLanguageSection]);
  }

  /// selected language
  bool isSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// all language
  Future<void> loadAllLanguages() async {
    try {
      final String response = await rootBundle.loadString('assets/all_language.json');
      final Map<String, dynamic> data = json.decode(response);

      allLanguages = data.values.map<String>((e) => e.toString()).toList();

      update([Constant.idLanguageSection]); // if using GetX
    } catch (e, st) {
      log('Error loading languages: $e\n$st');
    }
  }

  /// click photo
  takePhoto() async {
    xFiles = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Camera Image Path ::: $pickImage");
    }
    update();
  }

  /// pick image from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// get talk topic
  void getTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.talkAboutTopic]);

      var data = await TalkTopicApi.callApi();
      talkTopicsModel = data;
      talkTopic = data?.talkTopics ?? [];

      final savedTopics = Database.fetchListenerProfileModel?.data?.talkTopics ?? [];
      selectedTopics.clear(); // Reset selection
      for (var saved in savedTopics) {
        final matchIndex = talkTopic.indexWhere((element) => element.name == saved);
        if (matchIndex != -1) {
          selectedTopics.add(matchIndex);
        }
      }

      // /// ✅ Match saved topic name from database
      // final savedTopics = Database.fetchListenerProfileModel?.data?.talkTopics;
      // if (savedTopics != null && savedTopics.isNotEmpty) {
      //   final savedTopicName = savedTopics.first; // Assuming only one is saved
      //   final index = talkTopic.indexWhere((element) => element.name == savedTopicName);
      //   if (index != -1) {
      //     selectedTopic = index;
      //   }
      // }

      update([Constant.talkAboutTopic]);
    } catch (e, st) {
      log('getTalkTopicApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.talkAboutTopic]);
      log('getTalkTopicApi finally');
    }
  }

  /// save button on tap
  Future<void> onSaveProfile() async {
    Utils.showLog("Click On Save Profile => ${Database.fetchListenerProfileModel?.data?.id}");

    Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

    await callEditApi();
  }

  /// listener profile edit
  Future<void> callEditApi() async {
    final languageString =
        selectedLanguages.isNotEmpty ? selectedLanguages.join(',') : (Database.fetchListenerProfileModel?.data?.language?.join(',') ?? '');
    // String? talkTopics;
    // final selectedTopicNames = selectedTopics.map((i) => talkTopic[i].name).toList();
    // var talkTopics = selectedTopicNames.join(',');

    String talkTopics = selectedTopics.map((i) => talkTopic[i].name).join(',');

    if (selectedTopicName != null && selectedTopicName!.isNotEmpty) {
      talkTopics = selectedTopicName!;
    } else if (Database.fetchListenerProfileModel?.data?.talkTopics != null && Database.fetchListenerProfileModel!.data!.talkTopics!.isNotEmpty) {
      talkTopics = Database.fetchListenerProfileModel!.data!.talkTopics!.first;
    }

    hostListenerProfileUpdateModel = await HostListenerProfileUpdateApi.callApi(
      name: nameCnt.text,
      nickName: nickNameCnt.text,
      language: languageString,
      listenerId: Database.fetchListenerProfileModel?.data?.id,
      image: (pickImage == "") ? profilePic : pickImage,
      selfIntro: introCnt.text,
      ratePrivateAudioCall: ratePrivateAudioCallCnt.text,
      ratePrivateVideoCall: ratePrivateVideoCallCnt.text,
      rateRandomAudioCall: rateRandomAudioCallCnt.text,
      rateRandomVideoCall: rateRandomVideoCallCnt.text,
      talkTopics: selectedTopics.map((i) => talkTopic[i].name).join(','),
    );

    if (hostListenerProfileUpdateModel?.status == true) {
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      );
      Database.fetchListenerProfileModel = fetchListenerProfileModel;
      update();

      Get.close(2);
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      );
      Database.fetchListenerProfileModel = fetchListenerProfileModel;
      update();
    } else {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }
}

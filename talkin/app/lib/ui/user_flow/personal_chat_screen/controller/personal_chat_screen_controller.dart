import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/api/personal_chat_api.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/api/send_image_audio_api.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/send_image_audio_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

class PersonalChatScreenController extends GetxController {
  String? chatTopicId;
  String? receiverId;
  String? receiverName;
  String? receiverStatusLabel;
  String? receiverImage;
  String? ratePrivateAudioCall;
  String? ratePrivateVideoCall;
  String? fakeAudioUrl;
  List<dynamic>? fakeVideoUrl;
  bool? isFake;
  bool? availableForPrivateVideoCall;
  bool? availableForPrivateAudioCall;
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false;
  PersonalChatModel? personalChatModel;
  List<PersonalChat> oldChat = [];
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedImage;
  final ScrollController scrollController = ScrollController();
  SendImageAudioModel? sendImageAudioModel;
  AudioRecorder audioRecorder = AudioRecorder();
  bool isRecordingAudio = false;
  bool isPaginationLoading = false;
  bool isBackProfile = true;
  String? chatRoomId;
  bool isLoadingAudio = false;
  bool isLoadingImage = false;
  bool isMsgSeen = false;

  bool isSendingAudioFile = false;

  String currentPlayAudioId = "";
  Timer? timer;
  int countTime = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(onPagination);

    List args = Get.arguments ?? [];

    if (args.length >= 9) {
      receiverId = args[0]?.toString();
      receiverName = args[1]?.toString();
      receiverStatusLabel = args[2]?.toString();
      receiverImage = args[3]?.toString();
      ratePrivateAudioCall = args[4]?.toString();
      ratePrivateVideoCall = args[5]?.toString();
      isFake = args[6] is bool ? args[6] : args[6].toString().toLowerCase() == 'true';
      if (args[7] is String) {
        try {
          fakeVideoUrl = jsonDecode(args[7]) as List<dynamic>;
        } catch (_) {
          fakeVideoUrl = [];
        }
      } else if (args[7] is List) {
        fakeVideoUrl = args[7];
      } else {
        fakeVideoUrl = [];
      }
      availableForPrivateVideoCall = args[8] is bool ? args[8] : args[8].toString().toLowerCase() == 'true';
      availableForPrivateAudioCall = args[9] is bool ? args[9] : args[9].toString().toLowerCase() == 'true';
    }
    // getOldChats();
    init();
    Utils.showLog("Receiver ID: $receiverId");
    Utils.showLog("name: $receiverName");
    Utils.showLog("status label: $receiverStatusLabel");
    Utils.showLog("image: $receiverImage");
    Utils.showLog("chat topic id: ${personalChatModel?.chatTopicId}");
    Utils.showLog("ratePrivateAudioCall: $ratePrivateAudioCall");
    Utils.showLog("ratePrivateVideoCall: $ratePrivateVideoCall");
    Utils.showLog("availableForPrivateVideoCall: $availableForPrivateVideoCall");
    Utils.showLog("availableForPrivateAudioCall: $availableForPrivateAudioCall");
  }

  Future<void> init() async {
    if (receiverId != "") {
      chatRoomId = null;

      isLoading = true;
      update([Constant.idGetOldChat]);

      oldChat.clear();
      PersonalChatApi.startPagination = 1;

      await getOldChats();

      isLoading = false;
      update([Constant.idGetOldChat]);
    }
  }

  /// get all chats
  getOldChats() async {
    // isLoading = true;
    update([Constant.idGetOldChat]);

    personalChatModel = await PersonalChatApi.callApi(
      receiverId: receiverId.toString(),
    );
    oldChat.addAll(personalChatModel?.chat ?? []);

    chatTopicId = personalChatModel?.chatTopicId;

    Utils.showLog(" ::::: ${jsonEncode(oldChat)}");

    update([Constant.idGetOldChat]);

    if (chatRoomId == null) {
      chatRoomId = personalChatModel?.chatTopicId;
      if (oldChat.isNotEmpty) {
        // SocketEmit.onMessageSeen(messageId: oldChat.first.id ?? '', senderId: Database.fetchLoginUserProfileModel?.user?.id ?? '');
        SocketEmit.onMessageSeen({
          SocketParams.messageId: oldChat.last.id ?? '',
          SocketParams.senderId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
        });
        // socket?.onReadMessage(senderUserId: receiverUserId, messageId: SocketServices.userChats.last.id ?? "");
        onScrollDown();
      }
    }

    // onScrollDown();
  }

  String formatTimeFromDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsedDate = DateFormat('M/d/yyyy, hh:mm:ss a').parse(rawDate);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return ''; // fallback for invalid format
    }
  }

  Future<void> onPagination() async {
    if (scrollController.position.pixels == scrollController.position.minScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPagination]);
      await getOldChats();
      isPaginationLoading = false;
      update([Constant.idPagination]);
    }
  }

  /// send message
  void sendMessage() {
    String message = messageController.text.trim(); // ✅ Can now be reassigned

    if (message.isEmpty) {
      // Utils.showToast(Get.context!, "Message cannot be empty.");
      return;
    }

    if (containsDangerousScript(message)) {
      Utils.showToast(Get.context!, "Script tags are not allowed in the message.");
      messageController.clear();
      return;
    }

    message = sanitizeUserInput(message); // ✅ No error

    if (message.length > 1000) {
      Utils.showToast(Get.context!, "Message too long. Max 1000 characters.");
      return;
    }

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    /// 🔄 Insert Optimistic Message into UI
    oldChat.insert(
      0,
      PersonalChat(
        id: tempId,
        message: message,
        date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
        messageType: 1,
        senderId: Database.loginUserId,
      ),
    );

    update([Constant.idGetOldChat]);
    onScrollDown();

    final messageData = {
      SocketParams.senderRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
      SocketParams.receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
      SocketParams.chatTopicId: personalChatModel?.chatTopicId ?? "",
      SocketParams.senderId: Database.loginUserId,
      SocketParams.receiverId: receiverId,
      SocketParams.message: message,
      SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
      SocketParams.messageType: 1,
      SocketParams.name: Database.fetchLoginUserProfileModel?.user?.fullName,
      SocketParams.profilePic: Database.fetchLoginUserProfileModel?.user?.profilePic,
      SocketParams.ratePrivateVideoCall: '',
      SocketParams.ratePrivateAudioCall: '',
      SocketParams.isFake: isFake,
      SocketParams.video: fakeVideoUrl,
    };

    Utils.showLog("User message  :: $messageData");

    SocketEmit.sendMessage(messageData);

    messageController.clear();
    // onScrollDown();

    update([Constant.idSendMsg]);
  }

  String sanitizeUserInput(String input) {
    // Remove basic script-like or HTML characters
    input = input.replaceAll(RegExp(r'[<>\"\"&]'), '');
    input = input.replaceAll(RegExp(r'[^\x20-\x7E]'), ''); // printable only
    input = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return input;
  }

  /// script validation
  bool containsDangerousScript(String input) {
    final scriptTagRegex = RegExp(r'<\s*script[^>]*>', caseSensitive: false);
    return scriptTagRegex.hasMatch(input);
  }

  /// send image event
  Future<void> sendImageMessage() async {
    if (pickedImage == null || receiverId == null) {
      Utils.showToast(Get.context!, "No image selected or receiver ID is missing");
      return;
    }

    try {
      Utils.showLog("Sending image to API...");

      final hostSendImageAudioModel = await SendImageAudioApi.callApi(
        messageType: 2, //  2 = image
        chatTopicId: chatTopicId ?? '',
        receiverId: receiverId ?? '',
        imagePath: pickedImage!.path, //  Correct: use file path
      );

      if (hostSendImageAudioModel != null && hostSendImageAudioModel.chat != null) {
        final messageData = {
          SocketParams.senderRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
          SocketParams.receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
          SocketParams.chatTopicId: chatTopicId ?? '',
          SocketParams.senderId: Database.loginUserId,
          SocketParams.receiverId: receiverId,
          SocketParams.message: hostSendImageAudioModel.chat?.message ?? '',
          SocketParams.messageType: 2,
          SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
          SocketParams.image: hostSendImageAudioModel.chat?.image ?? '',
          SocketParams.name: Database.fetchLoginUserProfileModel?.user?.fullName,
          SocketParams.profilePic: Database.fetchLoginUserProfileModel?.user?.profilePic,
          SocketParams.ratePrivateVideoCall: '',
          SocketParams.ratePrivateAudioCall: '',
          SocketParams.isFake: isFake,
          SocketParams.video: fakeVideoUrl,
        };

        Utils.showLog("Image message socket emit :: $messageData");

        SocketEmit.sendMessage(messageData);

        pickedImage = null;
        onScrollDown();

        update();
        onScrollDown();
      } else {
        Utils.showToast(Get.context!, "Failed to send image.");
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Error sending image: $e");
      log("Error in sendImageMessage: $e");
    }
  }

  /// pick image camera
  Future<bool> pickImageFromCamera() async {
    pickedImage = await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 100);
    update();
    return pickedImage != null;
  }

  /// pick image gallery
  Future<bool> pickImageFromGallery() async {
    pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    update();
    return pickedImage != null;
  }

  /// show dialog image picker
  Future<void> showImagePickerDialog() async {
    Get.defaultDialog(
      backgroundColor: AppColors.white,
      title: EnumLocale.changeYourImage.name.tr,
      titlePadding: const EdgeInsets.only(top: 30),
      titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appColor),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              thickness: 1,
              color: Colors.grey.shade100,
            ),
          ),
          GestureDetector(
              onTap: () async {
                Get.back();
                bool didPick = await pickImageFromCamera();
                if (didPick) await sendImageMessage();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image(
                        color: AppColors.appColor,
                        image: AssetImage(AppAsset.cameraFlipIcon),
                        height: 20,
                      ),
                    ),
                    Text(
                      EnumLocale.txtTakeAphoto.name.tr,
                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                    )
                  ],
                ),
              )),
          GestureDetector(
              onTap: () async {
                Get.back();
                bool didPick = await pickImageFromGallery();
                if (didPick) await sendImageMessage();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image(
                        color: AppColors.appColor,
                        image: AssetImage(AppAsset.chatImageIcon),
                        height: 20,
                      ),
                    ),
                    Text(
                      EnumLocale.txtChooseFromYourFile.name.tr,
                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// audio playing and sending
  Future<void> onStartAudioRecording() async {
    Utils.showLog("Audio Recording Start");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp4";

    await audioRecorder.start(const RecordConfig(), path: filePath);

    isRecordingAudio = true;
    update([Constant.idChangeAudioRecordingEvent]);

    onChangeTimer();
  }

  Future<void> onLongPressStartMic() async {
    FocusManager.instance.primaryFocus?.unfocus();
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      PermissionStatus request = await Permission.microphone.request();

      if (request == PermissionStatus.denied) {
        Utils.showToast(Get.context!, EnumLocale.txtPleaseAllowPermission.name.tr);
      }
    } else {
      Utils.showLog("Audio Recording Started...");
      onStartAudioRecording();
    }
  }

  Future<void> onLongPressEndMic() async {
    PermissionStatus status = await Permission.microphone.status;

    if (isRecordingAudio && status.isGranted) {
      onStopAudioRecording();
    }
  }

  Future<void> onStopAudioRecording() async {
    try {
      Utils.showLog("Audio Recording Stop");

      isLoadingAudio = true;
      isSendingAudioFile = true;

      final audioPath = await audioRecorder.stop();

      isRecordingAudio = false;
      update([Constant.idChangeAudioRecordingEvent]);
      onChangeTimer();

      Utils.showLog("Recording Audio Path => $audioPath");
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      if (audioPath != null) {
        // Show audio in chat immediately
        oldChat.insert(
          0,
          PersonalChat(
            id: tempId,
            messageType: 3,
            createdAt: DateTime.now(),
            senderId: Database.loginUserId,
            audio: audioPath,
          ),
        );
        isLoadingAudio = true;
        update([Constant.idGetOldChat]);
        onScrollDown();

        // Upload actual audio
        sendImageAudioModel = await SendImageAudioApi.callApi(
          chatTopicId: personalChatModel?.chatTopicId ?? '',
          receiverId: receiverId.toString(),
          messageType: 3,
          filePath: audioPath,
        );

        // Replace optimistic with real audio
        final index = oldChat.indexWhere((c) => c.id == tempId);
        if (index != -1 && sendImageAudioModel?.chat?.audio != null) {
          oldChat[index] = PersonalChat(
            id: sendImageAudioModel?.chat?.id,
            audio: sendImageAudioModel?.chat?.audio,
            date: formatTime(),
            messageType: 3,
            senderId: Database.loginUserId,
          );
          update([Constant.idGetOldChat]);

          final messageData = {
            SocketParams.senderRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
            SocketParams.receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
            SocketParams.chatTopicId: chatTopicId ?? '',
            SocketParams.senderId: Database.loginUserId,
            SocketParams.receiverId: receiverId,
            SocketParams.message: sendImageAudioModel?.chat?.message ?? '',
            SocketParams.messageType: 3,
            SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
            SocketParams.audio: sendImageAudioModel?.chat?.audio ?? '',
            SocketParams.name: Database.fetchLoginUserProfileModel?.user?.fullName,
            SocketParams.profilePic: Database.fetchLoginUserProfileModel?.user?.profilePic,
            SocketParams.ratePrivateVideoCall: '',
            SocketParams.ratePrivateAudioCall: '',
            SocketParams.isFake: isFake,
            SocketParams.video: fakeVideoUrl,
          };

          Utils.showLog("Image message socket emit :: $messageData");

          SocketEmit.sendMessage(messageData);
        }
      }
      isSendingAudioFile = false;
      updateAudioUI();
    } catch (e) {
      isSendingAudioFile = false;
      Utils.showLog("Audio Recording Stop Failed => $e");
    }
  }

  Future<void> updateAudioUI() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay
    update([Constant.idChangeAudioRecordingEvent]);
  }

  Future<void> onChangeTimer() async {
    if (isRecordingAudio && countTime == 0) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          countTime++;
          update([Constant.idChangeAudioRecordingEvent]);
          if (isRecordingAudio == false) {
            countTime = 0;
            this.timer?.cancel();
            update([Constant.idChangeAudioRecordingEvent]);
          }
        },
      );
    } else {
      countTime = 0;
      timer?.cancel();
      update([Constant.idChangeAudioRecordingEvent]);
    }
  }

  Future<void> onScrollDown() async {
    try {
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      await 10.milliseconds.delay();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {
      Utils.showLog("Scroll Down Failed => $e");
    }
  }

  String formatTime() {
    try {
      String formattedTime;
      formattedTime = DateFormat('hh:mm a').format(DateTime.now());
      return formattedTime;
    } catch (e) {
      Utils.showLog("Error in format time :: $e");
      return "";
    }
  }
}

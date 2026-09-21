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
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/api/host_personal_chat_api.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/api/host_send_image_audio_api.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_send_image_audio_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

class HostPersonalChatScreenController extends GetxController {
  String? chatTopicId;
  String? receiverId;
  String? receiverName;
  String? receiverStatusLabel;
  String? receiverImage;
  XFile? pickedImage;
  String? chatRoomId;
  bool isMsgSeen = false;

  final TextEditingController messageController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  ScrollController scrollController = ScrollController();
  AudioRecorder audioRecorder = AudioRecorder();
  Timer? timer;

  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isRecordingAudio = false;
  bool isSendingAudioFile = false;
  bool isLoadingAudio = false;

  List<ListenerChat> oldChatListener = [];
  HostSendImageAudioModel? hostSendImageAudioModel;
  int countTime = 0;

  HostPersonalChatModel? hostPersonalChatModel;

  String currentPlayAudioId = "";

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(onPagination);

    final args = Get.arguments as List<dynamic>?;

    if (args != null && args.length >= 4) {
      receiverId = args[0]?.toString();
      receiverName = args[1]?.toString();
      receiverStatusLabel = args[2]?.toString();
      receiverImage = args[3]?.toString();
    }
    // getOldChats();
    init();
    Utils.showLog("Receiver ID: $receiverId");
    Utils.showLog("name: $receiverName");
    Utils.showLog("status label: $receiverStatusLabel");
    Utils.showLog("image: $receiverImage");
    Utils.showLog("chat topic id: ${hostPersonalChatModel?.chatTopic}");
  }

  @override
  void onClose() {
    chatRoomId = null;
    oldChatListener.clear();
    scrollController.removeListener(onPagination);
    Utils.showLog("Chat Controller Dispose Success");
    super.onClose();
  }

  Future<void> init() async {
    if (receiverId != "") {
      chatRoomId = null;

      isLoading = true;
      update([Constant.idGetOldChat]);

      oldChatListener.clear();
      HostPersonalChatApi.startPagination = 1;

      await getOldChats();

      isLoading = false;
      update([Constant.idGetOldChat]);
    }
  }

  /// get all chats
  getOldChats() async {
    update([Constant.idGetOldChat]);

    hostPersonalChatModel = await HostPersonalChatApi.callApi(
      receiverId: receiverId.toString(),
      senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
    );

    oldChatListener.addAll(hostPersonalChatModel?.chat ?? []);
    chatTopicId = hostPersonalChatModel?.chatTopic;

    Utils.showLog(" ::::: ${jsonEncode(oldChatListener)}");

    update([Constant.idGetOldChat]);

    if (chatRoomId == null) {
      chatRoomId = hostPersonalChatModel?.chatTopic;
      if (oldChatListener.isNotEmpty) {
        SocketEmit.onMessageSeen({
          SocketParams.messageId: oldChatListener.last.id ?? '',
          SocketParams.senderId: Database.fetchListenerProfileModel?.data?.id ?? '',
        });
        onScrollDown();
      } else {
        HostPersonalChatApi.startPagination--;
      }
    }
  }

  String formatTimeFromDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsedDate = DateFormat('M/d/yyyy, hh:mm:ss a').parse(rawDate);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  /// chat pagination
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
    oldChatListener.insert(
      0,
      ListenerChat(
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
      SocketParams.chatTopicId: hostPersonalChatModel?.chatTopic ?? '',
      SocketParams.senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
      SocketParams.receiverId: receiverId,
      SocketParams.message: message,
      SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
      SocketParams.messageType: 1,
      SocketParams.name: Database.fetchListenerProfileModel?.data?.name,
      SocketParams.profilePic: Database.fetchListenerProfileModel?.data?.image,
      SocketParams.ratePrivateVideoCall: Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall,
      SocketParams.ratePrivateAudioCall: Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall,
    };

    Utils.showLog("Listener message  :: $messageData");

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

  /// send image
  Future<void> sendImageMessage() async {
    if (pickedImage == null || receiverId == null) {
      Utils.showToast(Get.context!, "No image selected or receiver ID is missing");
      return;
    }

    try {
      Utils.showLog("Sending image to API...");

      hostSendImageAudioModel = await HostSendImageAudioApi.callApi(
        senderId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
        messageType: 2, //  2 = image
        chatTopicId: chatTopicId ?? '',
        receiverId: receiverId ?? '',
        imagePath: pickedImage!.path,
      );
      onScrollDown();
      if (hostSendImageAudioModel != null && hostSendImageAudioModel?.chat != null) {
        final messageData = {
          SocketParams.senderRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
          SocketParams.receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
          SocketParams.chatTopicId: chatTopicId ?? '',
          SocketParams.senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
          SocketParams.receiverId: receiverId,
          SocketParams.message: hostSendImageAudioModel?.chat?.message ?? '',
          SocketParams.messageType: 2,
          SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
          SocketParams.image: hostSendImageAudioModel?.chat?.image ?? '',
          SocketParams.name: Database.fetchListenerProfileModel?.data?.name,
          SocketParams.profilePic: Database.fetchListenerProfileModel?.data?.image,
          SocketParams.ratePrivateVideoCall: Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall,
          SocketParams.ratePrivateAudioCall: Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall,
        };

        Utils.showLog("Image message socket emit :: $messageData");

        SocketEmit.sendMessage(messageData);
        pickedImage = null;
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

  /// audio recording start
  Future<void> onStartAudioRecording() async {
    Utils.showLog("Audio Recording Start");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp4";

    await audioRecorder.start(const RecordConfig(), path: filePath);

    isRecordingAudio = true;
    update([Constant.idChangeAudioRecordingEvent]);

    onChangeTimer();
  }

  /// audio long press start mic
  Future<void> onLongPressEndMic() async {
    PermissionStatus status = await Permission.microphone.status;

    if (isRecordingAudio && status.isGranted) {
      onStopAudioRecording();
    }
  }

  /// audio long press end mic
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

  /// audio recording stop
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
        oldChatListener.insert(
          0,
          ListenerChat(
            id: tempId,
            messageType: 3,
            createdAt: DateTime.now(),
            senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
            audio: audioPath,
          ),
        );
        isLoadingAudio = true;
        update([Constant.idGetOldChat]);
        onScrollDown();

        // Upload actual audio
        hostSendImageAudioModel = await HostSendImageAudioApi.callApi(
          senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
          chatTopicId: hostPersonalChatModel?.chatTopic ?? '',
          receiverId: receiverId.toString(),
          messageType: 3,
          filePath: audioPath,
        );

        // Replace optimistic with real audio
        final index = oldChatListener.indexWhere((c) => c.id == tempId);
        if (index != -1 && hostSendImageAudioModel?.chat?.audio != null) {
          oldChatListener[index] = ListenerChat(
            id: hostSendImageAudioModel?.chat?.id,
            audio: hostSendImageAudioModel?.chat?.audio,
            date: formatTime(),
            messageType: 3,
            senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
          );
          update([Constant.idGetOldChat]);

          final messageData = {
            SocketParams.senderRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
            SocketParams.receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
            SocketParams.chatTopicId: chatTopicId ?? '',
            SocketParams.senderId: Database.fetchLoginUserProfileModel?.user?.listenerId,
            SocketParams.receiverId: receiverId,
            SocketParams.message: hostSendImageAudioModel?.chat?.message ?? '',
            SocketParams.messageType: 3,
            SocketParams.date: DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now()),
            SocketParams.image: hostSendImageAudioModel?.chat?.image ?? '',
            SocketParams.audio: hostSendImageAudioModel?.chat?.audio ?? '',
            SocketParams.name: Database.fetchListenerProfileModel?.data?.name,
            SocketParams.profilePic: Database.fetchListenerProfileModel?.data?.image,
            SocketParams.ratePrivateVideoCall: Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall,
            SocketParams.ratePrivateAudioCall: Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall,
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

  /// scroll chat
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
